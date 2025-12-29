using Microsoft.EntityFrameworkCore;
using MarketingTaskAPI.Data;
using MarketingTaskAPI.Models;
using Microsoft.Data.SqlClient;
using System.Data;

namespace MarketingTaskAPI.Services
{
    public class EmployeeService : IEmployeeService
    {
        private readonly MarketingTaskDbContext _context;
        private readonly string _connectionString;

        public EmployeeService(MarketingTaskDbContext context, IConfiguration configuration)
        {
            _context = context;
            _connectionString = configuration.GetConnectionString("DefaultConnection") ?? throw new ArgumentNullException("Connection string not found");
        }

        public async Task<IEnumerable<EmployeeDto>> GetAllEmployeesAsync()
        {
            var employees = new List<EmployeeDto>();
            
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_GetEmployees", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@IsActive", true);
                    
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            employees.Add(new EmployeeDto
                            {
                                EmployeeId = reader.GetInt32("EmployeeId"),
                                Name = reader.GetString("Name"),
                                Contact = reader.GetString("Contact"),
                                Designation = reader.GetString("Designation"),
                                Email = reader.GetString("Email"),
                                CreatedAt = reader.GetDateTime("CreatedAt")
                            });
                        }
                    }
                }
            }
            
            return employees;
        }

        public async Task<EmployeeDto?> GetEmployeeByIdAsync(int employeeId)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_GetEmployees", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@IsActive", true);
                    
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            if (reader.GetInt32("EmployeeId") == employeeId)
                            {
                                return new EmployeeDto
                                {
                                    EmployeeId = reader.GetInt32("EmployeeId"),
                                    Name = reader.GetString("Name"),
                                    Contact = reader.GetString("Contact"),
                                    Designation = reader.GetString("Designation"),
                                    Email = reader.GetString("Email"),
                                    CreatedAt = reader.GetDateTime("CreatedAt")
                                };
                            }
                        }
                    }
                }
            }
            
            return null;
        }

        public async Task<EmployeeDto> CreateEmployeeAsync(EmployeeDto employeeDto)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_InsertEmployee", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@Name", employeeDto.Name);
                    command.Parameters.AddWithValue("@Contact", employeeDto.Contact);
                    command.Parameters.AddWithValue("@Designation", employeeDto.Designation);
                    command.Parameters.AddWithValue("@Email", employeeDto.Email);
                    
                    var employeeId = await command.ExecuteScalarAsync();
                    employeeDto.EmployeeId = Convert.ToInt32(employeeId);
                    employeeDto.CreatedAt = DateTime.UtcNow;
                }
            }
            
            return employeeDto;
        }

        public async Task<EmployeeDto> UpdateEmployeeAsync(int employeeId, EmployeeDto employeeDto)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_UpdateEmployee", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@EmployeeId", employeeId);
                    command.Parameters.AddWithValue("@Name", employeeDto.Name);
                    command.Parameters.AddWithValue("@Contact", employeeDto.Contact);
                    command.Parameters.AddWithValue("@Designation", employeeDto.Designation);
                    command.Parameters.AddWithValue("@Email", employeeDto.Email);
                    
                    await command.ExecuteNonQueryAsync();
                }
            }
            
            employeeDto.EmployeeId = employeeId;
            return employeeDto;
        }

        public async Task<bool> DeleteEmployeeAsync(int employeeId)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_DeleteEmployee", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@EmployeeId", employeeId);
                    
                    var rowsAffected = await command.ExecuteNonQueryAsync();
                    return rowsAffected > 0;
                }
            }
        }

        // New method for employee summary reporting
        public async Task<IEnumerable<EmployeeSummaryDto>> GetEmployeeSummaryAsync()
        {
            var summaries = new List<EmployeeSummaryDto>();
            
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("GetEmployeeSummary", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            summaries.Add(new EmployeeSummaryDto
                            {
                                EmployeeName = reader.GetString("EmployeeName"),
                                Designation = reader.GetString("Designation"),
                                Email = reader.GetString("Email"),
                                TotalTasks = reader.GetInt32("TotalTasks"),
                                TotalEstimatedHours = reader.IsDBNull("TotalEstimatedHours") ? 0 : reader.GetInt32("TotalEstimatedHours"),
                                NotStarted = reader.GetInt32("NotStarted"),
                                InProgress = reader.GetInt32("InProgress"),
                                Completed = reader.GetInt32("Completed"),
                                Postponed = reader.GetInt32("Postponed"),
                                HighPriorityTasks = reader.GetInt32("HighPriorityTasks"),
                                OverdueTasks = reader.GetInt32("OverdueTasks")
                            });
                        }
                    }
                }
            }
            
            return summaries;
        }
    }
} 