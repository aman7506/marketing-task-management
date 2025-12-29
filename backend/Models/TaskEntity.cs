using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace MarketingTaskAPI.Models
{
    public class TaskEntity
    {
        public int TaskId { get; set; }

        public int AssignedByUserId { get; set; }
        
        public int EmployeeId { get; set; }
        
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
        
        public DateTime CreatedAt { get; set; }
        
        public DateTime UpdatedAt { get; set; }
        
        [StringLength(50)]
        public string? TaskType { get; set; }
        
        [StringLength(100)]
        public string? Department { get; set; }
        
        [StringLength(200)]
        public string? ConsultantName { get; set; }
        
        [StringLength(100)]
        public string? CampCode { get; set; }
        
        public decimal? EstimatedHours { get; set; }
        
        public decimal? ActualHours { get; set; }
        
        [StringLength(50)]
        public string? TaskCategory { get; set; }
        
        [StringLength(1000)]
        public string? AdditionalNotes { get; set; }
        
        public bool IsUrgent { get; set; }
        
        [StringLength(50)]
        public string? EmployeeCode { get; set; }
        
        public int? StateId { get; set; }
        
        [StringLength(100)]
        public string? StateName { get; set; }
        
        public int? CityId { get; set; }
        
        [StringLength(100)]
        public string? CityName { get; set; }
        
        public int? AreaId { get; set; }
        
        [StringLength(500)]
        public string? AreaIds { get; set; }
        
        [StringLength(1000)]
        public string? AreaNames { get; set; }
        
        [StringLength(200)]
        public string? LocalityName { get; set; }
        
        public int? PincodeId { get; set; }
        
        [StringLength(10)]
        public string? PincodeValue { get; set; }
        
        [StringLength(1000)]
        public string? ConsultantFeedback { get; set; }
        
        public int UserId { get; set; }
        
        
        // Navigation Properties - these are computed from joins, not database columns
        [JsonIgnore]
        [NotMapped]
        public virtual User? AssignedByUser { get; set; }
        
        [JsonIgnore]
        [NotMapped]
        public virtual Employee? Employee { get; set; }
        
        [JsonIgnore]
        [NotMapped]
        public virtual Location? Location { get; set; }
        
        [JsonIgnore]
        [NotMapped]
        public virtual State? StateNavigation { get; set; }
        
        [JsonIgnore]
        [NotMapped]
        public virtual City? CityNavigation { get; set; }
        
        [JsonIgnore]
        [NotMapped]
        public virtual Area? AreaNavigation { get; set; }
        
        [NotMapped]
        public virtual ICollection<TaskStatusHistory> StatusHistory { get; set; } = new List<TaskStatusHistory>();
        
        [NotMapped]
        public virtual ICollection<TaskTaskType> TaskTaskTypes { get; set; } = new List<TaskTaskType>();
        
        [NotMapped]
        public virtual ICollection<TaskLocation> TaskLocations { get; set; } = new List<TaskLocation>();
    }
}