using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MarketingTaskAPI.Models
{
    public class UserTask
    {
        public int TaskId { get; set; }

        public int AssignedByUserId { get; set; }
        public int? EmployeeId { get; set; }
        
        [NotMapped]
        public string? EmployeeName { get; set; }
        
        public int? LocationId { get; set; }

        [StringLength(100)]
        public string? CustomLocation { get; set; }

        [Required]
        [StringLength(500)]
        public string Description { get; set; } = string.Empty;

        [Required]
        [StringLength(10)]
        public string Priority { get; set; } = string.Empty;

        public DateTime TaskDate { get; set; }
        public DateTime Deadline { get; set; }

        [Required]
        [StringLength(20)]
        public string Status { get; set; } = "Not Started";

        // Extra fields
        [StringLength(50)]
        public string? TaskType { get; set; } = "General";

        [StringLength(100)]
        public string? Department { get; set; } = "Marketing";

        [StringLength(200)]
        public string? ClientName { get; set; }

        [StringLength(100)]
        public string? ProjectCode { get; set; }

        [StringLength(50)]
        public string? EmployeeIdNumber { get; set; }

        public decimal? EstimatedHours { get; set; }
        public decimal? ActualHours { get; set; }

        [StringLength(50)]
        public string? TaskCategory { get; set; } = "Field Work";

        [StringLength(1000)]
        public string? AdditionalNotes { get; set; }

        [StringLength(1000)]
        public string? ConsultantFeedback { get; set; }

        [StringLength(50)]
        public string? EmployeeCode { get; set; }

        [StringLength(100)]
        public string? ConsultantName { get; set; }

        [StringLength(50)]
        public string? CampCode { get; set; }

        public bool IsUrgent { get; set; } = false;

        // Location hierarchy
        public int? StateId { get; set; }

        [StringLength(100)]
        public string? StateName { get; set; }

        public int? CityId { get; set; }

        [StringLength(100)]
        public string? CityName { get; set; }

        public int? AreaId { get; set; }

        [NotMapped]
        [StringLength(100)]
        public string? AreaName { get; set; }

        [StringLength(500)]
        public string? AreaIds { get; set; } // JSON array of area IDs

        [StringLength(1000)]
        public string? AreaNames { get; set; } // JSON array of area names

        public int? PincodeId { get; set; }

        [StringLength(10)]
        public string? PincodeValue { get; set; }

        [StringLength(200)]
        public string? LocalityName { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        [ForeignKey("AssignedByUserId")]
        public virtual User AssignedByUser { get; set; } = null!;
        
        [ForeignKey("EmployeeId")]
        public virtual Employee Employee { get; set; } = null!;
        public virtual Location? Location { get; set; }
        public virtual State? StateNavigation { get; set; }
        public virtual City? CityNavigation { get; set; }
        public virtual Area? AreaNavigation { get; set; }
        public virtual ICollection<TaskStatusHistory> StatusHistory { get; set; } = new List<TaskStatusHistory>();
        public virtual ICollection<TaskTaskType> TaskTaskTypes { get; set; } = new List<TaskTaskType>();
        public virtual ICollection<TaskLocation> TaskLocations { get; set; } = new List<TaskLocation>();
        public virtual ICollection<EmployeeFeedback> EmployeeFeedback { get; set; } = new List<EmployeeFeedback>();
    }

    // Complete TaskDto with all properties
    public class TaskDto
    {
        public int TaskId { get; set; }
        public int EmployeeId { get; set; }
        public string? EmployeeName { get; set; }
        public string? EmployeeContact { get; set; }
        public string? EmployeeDesignation { get; set; }
        public int? LocationId { get; set; }
        public string? LocationName { get; set; }
        public string? CustomLocation { get; set; }
        public string? Description { get; set; }
        public string? Priority { get; set; }
        public DateTime TaskDate { get; set; }
        public DateTime Deadline { get; set; }
        public string? Status { get; set; }
        public int AssignedByUserId { get; set; }
        public string? AssignedByUserName { get; set; }

        // Additional fields
        public string? TaskType { get; set; }
        public string? Department { get; set; }
        public string? ClientName { get; set; }
        public string? ProjectCode { get; set; }
        public decimal? EstimatedHours { get; set; }
        public decimal? ActualHours { get; set; }
        public string? TaskCategory { get; set; }
        public string? AdditionalNotes { get; set; }
        public string? ConsultantFeedback { get; set; }
        public bool IsUrgent { get; set; }
        public string? StateName { get; set; }

        // Location hierarchy
        public int? StateId { get; set; }
        public int? CityId { get; set; }
        public string? CityName { get; set; }
        public int? AreaId { get; set; }
        public string? AreaName { get; set; }
        public int? PincodeId { get; set; }
        public string? PincodeValue { get; set; }

        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    // Complete CreateTaskRequest
    public class CreateTaskRequest
    {
        public int? EmployeeId { get; set; }
        public string? Status { get; set; }
        public int? LocationId { get; set; }
        public string? CustomLocation { get; set; }
        public string Description { get; set; } = string.Empty;
        public string Priority { get; set; } = "Medium";
        public DateTime TaskDate { get; set; }
        public DateTime Deadline { get; set; }

        // Optional fields
        public string? TaskType { get; set; }
        public string? Department { get; set; }
        public string? ClientName { get; set; }
        public string? ProjectCode { get; set; }
        public decimal? EstimatedHours { get; set; }
        public string? TaskCategory { get; set; }
        public string? AdditionalNotes { get; set; }
        public bool IsUrgent { get; set; } = false;

        // Location hierarchy
        public int? StateId { get; set; }
        public string? StateName { get; set; }  // Added for location names
        public int? CityId { get; set; }
        public string? CityName { get; set; }  // Added for location names
        public int? PincodeId { get; set; }
        public int? AreaId { get; set; }  // Added back for compatibility
        public string? AreaName { get; set; }  // Added for location names
        public string? State { get; set; }  // Added for location names
        public string? City { get; set; }
        public string? Area { get; set; }
        public List<int>? AreaIds { get; set; }  // Multiple areas support
        public List<string>? AreaNames { get; set; }  // Multiple area names support
        public string? PincodeValue { get; set; }  // Added for pincode value

        public string? Pincode { get; set; }
        public string? LocalityName { get; set; }
        public string? EmployeeCode { get; set; }
        public string? ConsultantName { get; set; }
        public string? ConsultantFeedback { get; set; }
        public string? CampCode { get; set; }
        
        // Multiple task types and locations
        public List<int>? TaskTypeIds { get; set; }
        public List<int>? LocationIds { get; set; }
        
        // Marketing-specific fields
        public string? ExpectedReach { get; set; }
        public string? ConversionGoal { get; set; }
        public string? Kpis { get; set; }
        public string? MarketingMaterials { get; set; }
        public bool ApprovalRequired { get; set; } = false;
        public string? ApprovalContact { get; set; }
        public string? BudgetCode { get; set; }
        public string? DepartmentCode { get; set; }
    }

    // Complete UpdateTaskStatusRequest
    public class UpdateTaskStatusRequest
    {
        public string Status { get; set; } = string.Empty;
        public string? Remarks { get; set; }
    }

    // Complete UpdateTaskRequest with all fields
    public class UpdateTaskRequest
    {
        public int? EmployeeId { get; set; }
        public int? LocationId { get; set; }
        public string? CustomLocation { get; set; }
        public string? Description { get; set; }
        public string? Priority { get; set; }
        public DateTime? TaskDate { get; set; }
        public DateTime? Deadline { get; set; }
        public string? Status { get; set; }
        
        // Additional fields
        public string? TaskType { get; set; }
        public string? Department { get; set; }
        public string? ClientName { get; set; }
        public string? ProjectCode { get; set; }
        public string? EmployeeIdNumber { get; set; }
        public decimal? EstimatedHours { get; set; }
        public decimal? ActualHours { get; set; }
        public string? TaskCategory { get; set; }
        public string? AdditionalNotes { get; set; }
        public bool? IsUrgent { get; set; }

        // Location hierarchy
        public int? StateId { get; set; }
        public string? StateName { get; set; }
        public int? CityId { get; set; }
        public string? CityName { get; set; }
        public int? AreaId { get; set; }
        public string? AreaName { get; set; }
        public int? PincodeId { get; set; }
        public string? PincodeValue { get; set; }
        public string? LocalityName { get; set; }
        
        // Additional fields
        public string? EmployeeCode { get; set; }
        public string? ConsultantName { get; set; }
        public string? CampCode { get; set; }
        public string? ConsultantFeedback { get; set; }
    }

    // Complete HighPriorityTaskDto
    public class HighPriorityTaskDto
    {
        public int TaskId { get; set; }
        public string? AssignedTo { get; set; }
        public string? Designation { get; set; }
        public string? EmployeeEmail { get; set; }
        public string? Description { get; set; }
        public string? Priority { get; set; }
        public string? TaskType { get; set; }
        public string? Department { get; set; }
        public string? Location { get; set; }
        public decimal? EstimatedHours { get; set; }
        public DateTime Deadline { get; set; }
        public string? Status { get; set; }
        public string? AssignedBy { get; set; }
        public string? UrgencyStatus { get; set; }
        public DateTime CreatedAt { get; set; }
        public string? EmployeeName { get; set; }
    }

    // Complete TaskStatusHistoryDto
    public class TaskStatusHistoryDto
    {
        public int HistoryId { get; set; }
        public int TaskId { get; set; }
        public string? EmployeeName { get; set; }
        public string? Designation { get; set; }
        public string? TaskDescription { get; set; }
        public string Status { get; set; } = string.Empty;
        public string? Remarks { get; set; }
        public DateTime ChangedAt { get; set; }
        public string? ChangedByUser { get; set; }
        public int TaskStatusHistoryId { get; set; }
    }
}
