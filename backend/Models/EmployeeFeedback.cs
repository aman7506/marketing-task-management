using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MarketingTaskAPI.Models
{
    public class EmployeeFeedback
    {
        [Key]
        public int FeedbackId { get; set; }
        
        [Required]
        public int TaskId { get; set; }
        
        [Required]
        public int EmployeeId { get; set; }
        
        [StringLength(200)]
        public string? ConsultantName { get; set; }
        
        [Required]
        [StringLength(2000)]
        public string FeedbackText { get; set; } = string.Empty;
        
        [StringLength(1000)]
        public string? Remarks { get; set; }
        
        public DateTime? MeetingDate { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
        
        // Navigation properties
        public virtual UserTask Task { get; set; } = null!;
        public virtual Employee Employee { get; set; } = null!;
    }

    public class EmployeeFeedbackDto
    {
        public int FeedbackId { get; set; }
        public int TaskId { get; set; }
        public string TaskDescription { get; set; } = string.Empty;
        public int EmployeeId { get; set; }
        public string EmployeeName { get; set; } = string.Empty;
        public string? ConsultantName { get; set; }
        public string FeedbackText { get; set; } = string.Empty;
        public string? Remarks { get; set; }
        public DateTime? MeetingDate { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class CreateEmployeeFeedbackRequest
    {
        [Required]
        public int TaskId { get; set; }
        
        [StringLength(200)]
        public string? ConsultantName { get; set; }
        
        [Required]
        [StringLength(2000)]
        public string FeedbackText { get; set; } = string.Empty;
        
        [StringLength(1000)]
        public string? Remarks { get; set; }
        
        public DateTime? MeetingDate { get; set; }
    }

    public class UpdateEmployeeFeedbackRequest
    {
        [StringLength(200)]
        public string? ConsultantName { get; set; }
        
        [Required]
        [StringLength(2000)]
        public string FeedbackText { get; set; } = string.Empty;
        
        [StringLength(1000)]
        public string? Remarks { get; set; }
        
        public DateTime? MeetingDate { get; set; }
    }
}