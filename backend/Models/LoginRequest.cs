using System.ComponentModel.DataAnnotations;

namespace MarketingTaskAPI.Models
{
    public class UserLoginRequest
    {
        [Required]
        [EmailAddress]
        public string Username { get; set; } = string.Empty;

        [Required]
        public string Password { get; set; } = string.Empty;
    }
}