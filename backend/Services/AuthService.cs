using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using MarketingTaskAPI.Data;
using MarketingTaskAPI.Models;
using Microsoft.Data.SqlClient;   
using System.Data;                
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Identity;

namespace MarketingTaskAPI.Services
{
    public class AuthService(MarketingTaskDbContext context, IConfiguration configuration, ILogger<AuthService> logger) : IAuthService
    {
        private readonly MarketingTaskDbContext _context = context;
        private readonly IConfiguration _configuration = configuration;
        private readonly ILogger<AuthService> _logger = logger;

        public async Task<AuthLoginResponse?> LoginAsync(AuthLoginRequest request)
        {
            // Authenticate using the robust AuthenticateAsync implementation
            var user = await AuthenticateAsync(request.Username, request.Password);
            if (user == null)
            {
                return null;
            }

            var token = GenerateJwtToken(user);
            return new AuthLoginResponse
            {
                Token = token,
                User = new AuthUserDto
                {
                    UserId = user.UserId,
                    Username = user.Username,
                    Role = user.Role,
                    EmployeeId = user.EmployeeId,
                    EmployeeName = user.Employee?.Name
                }
            };
        }

        public Task<bool> ValidateTokenAsync(string token)
        {
            try
            {
                var tokenHandler = new JwtSecurityTokenHandler();
                var key = Encoding.ASCII.GetBytes(_configuration["Jwt:Key"]!);

                tokenHandler.ValidateToken(token, new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(key),
                    ValidateIssuer = true,
                    ValidIssuer = _configuration["Jwt:Issuer"],
                    ValidateAudience = true,
                    ValidAudience = _configuration["Jwt:Audience"],
                    ClockSkew = TimeSpan.Zero
                }, out SecurityToken validatedToken);

                return Task.FromResult(true);
            }
            catch
            {
                return Task.FromResult(false);
            }
        }

        public async Task<User?> GetUserByUsernameAsync(string username)
        {
            using (var connection = new SqlConnection(_context.Database.GetConnectionString()))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_GetUserByUsername", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@Username", username);

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            return new User
                            {
                                UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                                Username = reader.GetString(reader.GetOrdinal("Username")),
                                PasswordHash = reader.GetString(reader.GetOrdinal("PasswordHash")),
                                Role = reader.GetString(reader.GetOrdinal("Role")),
                                EmployeeId = reader.IsDBNull(reader.GetOrdinal("EmployeeId"))
                                    ? null
                                    : reader.GetInt32(reader.GetOrdinal("EmployeeId")),
                                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                                IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive")),
                                Employee = reader.IsDBNull(reader.GetOrdinal("EmployeeId"))
                                    ? null
                                    : new Employee
                                    {
                                        EmployeeId = reader.GetInt32(reader.GetOrdinal("EmployeeId")),
                                        Name = reader.GetString(reader.GetOrdinal("EmployeeName"))
                                    }
                            };
                        }
                    }
                }
            }

            return null;
        }

        public string GenerateJwtToken(User user)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.ASCII.GetBytes(_configuration["Jwt:Key"]!);

            var claims = new List<Claim>
            {
                new(ClaimTypes.NameIdentifier, user.UserId.ToString()),
                new(ClaimTypes.Name, user.Username),
                new(ClaimTypes.Role, user.Role)
            };

            if (user.EmployeeId.HasValue)
            {
                claims.Add(new Claim("EmployeeId", user.EmployeeId.Value.ToString()));
            }

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.UtcNow.AddHours(Convert.ToDouble(_configuration["Jwt:ExpirationHours"])),
                Issuer = _configuration["Jwt:Issuer"],
                Audience = _configuration["Jwt:Audience"],
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }

        private static bool VerifyPassword(string password, User user)
        {
            if (user.Role == "Admin" && password == "Admin123!")
            {
                return true;
            }

            if (user.Role == "Employee" && password == "Employee123!")
            {
                return true;
            }

            return false;
        }

        public async Task<User?> AuthenticateAsync(string username, string password)
        {
            // DEVELOPMENT-ONLY fallback: hardcoded admin credential that will be created in DB if missing.
            // Remove or disable this in production.
            const string devAdminUser = "admin@actionmedical.com";
            const string devAdminPass = "Admin123!";

            if (string.Equals(username, devAdminUser, StringComparison.OrdinalIgnoreCase) && password == devAdminPass)
            {
                var existingAdmin = await _context.Users.FirstOrDefaultAsync(u => u.Username == username);
                if (existingAdmin != null)
                {
                    return existingAdmin;
                }

                // Create a new admin user in the database with an ASP.NET Identity hashed password
                var newAdmin = new User
                {
                    Username = devAdminUser,
                    Role = "Admin",
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true
                };

                var hasher = new PasswordHasher<User>();
                newAdmin.PasswordHash = hasher.HashPassword(newAdmin, devAdminPass);

                _context.Users.Add(newAdmin);
                await _context.SaveChangesAsync();

                return newAdmin;
            }

            // Fetch user from the database
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == username);

            if (user == null)
            {
                return null;
            }

            var hash = user.PasswordHash ?? string.Empty;

            if (string.IsNullOrEmpty(hash))
            {
                return null;
            }

            if (hash.StartsWith("$2"))
            {
                try
                {
                    if (BCrypt.Net.BCrypt.Verify(password, hash))
                    {
                        return user;
                    }
                    return null;
                }
                catch
                {
                    return null;
                }
            }

            // This must be done BEFORE calling PasswordHasher to avoid Base-64 exceptions
            if (hash == password)
            {
                var hasher = new PasswordHasher<User>();
                user.PasswordHash = hasher.HashPassword(user, password);
                _context.Users.Update(user);
                await _context.SaveChangesAsync();
                return user;
            }

            try
            {
                var hasher = new PasswordHasher<User>();
                var result = hasher.VerifyHashedPassword(user, hash, password);
                if (result == PasswordVerificationResult.Success || result == PasswordVerificationResult.SuccessRehashNeeded)
                {
                    if (result == PasswordVerificationResult.SuccessRehashNeeded)
                    {
                        user.PasswordHash = hasher.HashPassword(user, password);
                        _context.Users.Update(user);
                        await _context.SaveChangesAsync();
                    }

                    return user;
                }

                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error verifying password for user {Username}.", username);
                return null;
            }
        }
    }
}
