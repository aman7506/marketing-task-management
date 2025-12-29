using System.ComponentModel.DataAnnotations;

namespace MarketingTaskAPI.Models
{
    public class TaskType
    {
        public int TaskTypeId { get; set; }
        
        [Required]
        [StringLength(50)]
        public string TypeName { get; set; } = string.Empty;
        
        [StringLength(200)]
        public string? Description { get; set; }
        
        public bool IsActive { get; set; } = true;
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        // Navigation properties
        public virtual ICollection<TaskTaskType> TaskTaskTypes { get; set; } = new List<TaskTaskType>();
    }

    public class TaskLocation
    {
        public int TaskLocationId { get; set; }
        
        [Required]
        public int TaskId { get; set; }
        
        [Required]
        public int LocationId { get; set; }
        
        [StringLength(100)]
        public string? CustomLocation { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        // Navigation properties
        public virtual UserTask Task { get; set; } = null!;
        public virtual Location Location { get; set; } = null!;
    }

    public class TaskTaskType
    {
        public int TaskTaskTypeId { get; set; }
        
        [Required]
        public int TaskId { get; set; }
        
        [Required]
        public int TaskTypeId { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        // Navigation properties
        public virtual UserTask Task { get; set; } = null!;
        public virtual TaskType TaskType { get; set; } = null!;
    }

    public class TaskTypeDto
    {
        public int TaskTypeId { get; set; }
        public string TypeName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public bool IsActive { get; set; }
    }

    public class TaskLocationDto
    {
        public int TaskLocationId { get; set; }
        public int TaskId { get; set; }
        public int LocationId { get; set; }
        public string LocationName { get; set; } = string.Empty;
        public string? CustomLocation { get; set; }
    }
}