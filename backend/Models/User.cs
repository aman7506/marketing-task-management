using System.ComponentModel.DataAnnotations;

namespace MarketingTaskAPI.Models
{
    public class User
    {
        public int UserId { get; set; }
        
        [Required]
        [StringLength(100)]
        public string Username { get; set; } = string.Empty;
        
        [Required]
        [StringLength(256)]
        public string PasswordHash { get; set; } = string.Empty;
        
        [Required]
        [StringLength(20)]
        public string Role { get; set; } = string.Empty;
        
        public int? EmployeeId { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public bool IsActive { get; set; } = true;
        
        // Navigation properties
        public virtual Employee? Employee { get; set; }
        public virtual ICollection<UserTask> AssignedTasks { get; set; } = new List<UserTask>();
        public virtual ICollection<TaskStatusHistory> StatusChanges { get; set; } = new List<TaskStatusHistory>();
    }

    public class LoginRequest
    {
        [Required]
        [EmailAddress]
        public string Username { get; set; } = string.Empty;
        
        [Required]
        public string Password { get; set; } = string.Empty;
    }

    public class UserDto
    {
        public int UserId { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
        public int? EmployeeId { get; set; }
        public string? EmployeeName { get; set; }
    }

    public class LoginResponse
    {
        public string Token { get; set; } = string.Empty;
        public UserDto User { get; set; } = new();
    }
} 