using System.ComponentModel.DataAnnotations;

namespace MarketingTaskAPI.Models
{
    public class Employee
    {
        [Key]
        public int EmployeeId { get; set; }
        
        [Required]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [StringLength(50)]
        public string? Contact { get; set; }
        
        [StringLength(100)]
        public string? Designation { get; set; }
        
        [StringLength(200)]
        public string? Email { get; set; }
        
        [StringLength(50)]
        public string? EmployeeCode { get; set; }
        
        public bool IsActive { get; set; } = true;
        
        // Navigation properties
        public virtual ICollection<UserTask> Tasks { get; set; } = new List<UserTask>();
        public virtual ICollection<EmployeeFeedback> EmployeeFeedback { get; set; } = new List<EmployeeFeedback>();
    }

    public class EmployeeDto
    {
        public int EmployeeId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Contact { get; set; } = string.Empty;
        public string Designation { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string EmployeeCode { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
    }

    public class EmployeeSummaryDto
    {
        public string EmployeeName { get; set; } = string.Empty;
        public string Designation { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public int TotalTasks { get; set; }
        public int TotalEstimatedHours { get; set; }
        public int NotStarted { get; set; }
        public int InProgress { get; set; }
        public int Completed { get; set; }
        public int Postponed { get; set; }
        public int HighPriorityTasks { get; set; }
        public int OverdueTasks { get; set; }
    }
}