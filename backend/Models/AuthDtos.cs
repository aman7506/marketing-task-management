using System.ComponentModel.DataAnnotations;

namespace MarketingTaskAPI.Models
{
    public class AuthLoginRequest
    {
        [Required]
        [EmailAddress]
        public string Username { get; set; } = string.Empty;

        [Required]
        public string Password { get; set; } = string.Empty;
    }

    public class AuthLoginResponse
    {
        public string Token { get; set; } = string.Empty;
        public AuthUserDto User { get; set; } = new AuthUserDto();
    }

    public class AuthUserDto
    {
        public int UserId { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
        public int? EmployeeId { get; set; }
        public string? EmployeeName { get; set; }
    }
}