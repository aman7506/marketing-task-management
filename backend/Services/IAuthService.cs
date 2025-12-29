using MarketingTaskAPI.Models;

namespace MarketingTaskAPI.Services
{
    public interface IAuthService
    {
        Task<AuthLoginResponse?> LoginAsync(AuthLoginRequest request);
        Task<bool> ValidateTokenAsync(string token);
        Task<User?> GetUserByUsernameAsync(string username);
        string GenerateJwtToken(User user);
        Task<User?> AuthenticateAsync(string username, string password);
    }
}