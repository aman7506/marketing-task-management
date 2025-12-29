using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MarketingTaskAPI.Models
{
    // State model for hierarchical location system
    public class State
    {
        public int StateId { get; set; }

        [Required]
        [StringLength(100)]
        public string StateName { get; set; } = string.Empty;

        [Required]
        [StringLength(10)]
        public string StateCode { get; set; } = string.Empty;

        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual ICollection<City> Cities { get; set; } = new List<City>();
        public virtual ICollection<Location> Locations { get; set; } = new List<Location>();
    }

    // City model for hierarchical location system
    public class City
    {
        public int CityId { get; set; }

        [Required]
        [StringLength(100)]
        public string CityName { get; set; } = string.Empty;

        public int StateId { get; set; }
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual State State { get; set; } = null!;
        public virtual ICollection<Area> Areas { get; set; } = new List<Area>();
        public virtual ICollection<Location> Locations { get; set; } = new List<Location>();
    }

    // Area model for hierarchical location system
    public class Area
    {
        public int AreaId { get; set; }

        [Required]
        [StringLength(100)]
        public string AreaName { get; set; } = string.Empty;

        public int CityId { get; set; }
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual City City { get; set; } = null!;
        public virtual ICollection<Pincode> Pincodes { get; set; } = new List<Pincode>();
        public virtual ICollection<Location> Locations { get; set; } = new List<Location>();
    }

    // Pincode model for hierarchical location system
    public class Pincode
    {
        public int PincodeId { get; set; }
        
        [Required]
        [StringLength(10)]
        [Column("Pincode")]
        public string PincodeValue { get; set; } = string.Empty;
        
        public int AreaId { get; set; }
        
        [StringLength(200)]
        public string? LocalityName { get; set; }
        
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        // Navigation properties
        public virtual Area Area { get; set; } = null!;
        public virtual ICollection<Location> Locations { get; set; } = new List<Location>();
    }

    // Updated Location model with hierarchical support
    public class Location
    {
        public int LocationId { get; set; }
        
        [Required]
        [StringLength(100)]
        public string LocationName { get; set; } = string.Empty;
        
        // Legacy field for backward compatibility
        [StringLength(50)]
        public string? State { get; set; }
        
        // New hierarchical fields
        public int? StateId { get; set; }
        public int? CityId { get; set; }
        public int? AreaId { get; set; }
        public int? PincodeId { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public bool IsActive { get; set; } = true;
        
        // Navigation properties
        public virtual State? StateNavigation { get; set; }
        public virtual City? CityNavigation { get; set; }
        public virtual Area? AreaNavigation { get; set; }
        public virtual Pincode? PincodeNavigation { get; set; }
        public virtual ICollection<UserTask> Tasks { get; set; } = new List<UserTask>();
    }

    // Task Reschedule model
    public class TaskReschedule
    {
        public int RescheduleId { get; set; }
        public int TaskId { get; set; }
        public DateTime OriginalTaskDate { get; set; }
        public DateTime OriginalDeadline { get; set; }
        public DateTime NewTaskDate { get; set; }
        public DateTime NewDeadline { get; set; }
        
        [StringLength(500)]
        public string? RescheduleReason { get; set; }
        
        public int RescheduledByUserId { get; set; }
        public DateTime RescheduledAt { get; set; } = DateTime.UtcNow;
        
        // Navigation properties
        public virtual UserTask Task { get; set; } = null!;
        public virtual User RescheduledByUser { get; set; } = null!;
    }

    // DTOs for API responses
    public class StateDto
    {
        public int StateId { get; set; }
        public string StateName { get; set; } = string.Empty;
        public string StateCode { get; set; } = string.Empty;
        public bool IsActive { get; set; }
    }

    public class AreaDto
    {
        public int AreaId { get; set; }
        public string AreaName { get; set; } = string.Empty;
        public int CityId { get; set; }
        public string CityName { get; set; } = string.Empty;
        public bool IsActive { get; set; }
    }

    public class PincodeDto
    {
        public int PincodeId { get; set; }
        public string PincodeValue { get; set; } = string.Empty;
        public int AreaId { get; set; }
        public string AreaName { get; set; } = string.Empty;
        public string? LocalityName { get; set; }
        public bool IsActive { get; set; }
    }

    public class HierarchicalLocationDto
    {
        public int LocationId { get; set; }
        public string LocationName { get; set; } = string.Empty;
        public int? StateId { get; set; }
        public string? StateName { get; set; }
        public string? StateCode { get; set; }
        public int? CityId { get; set; }
        public string? CityName { get; set; }
        public int? AreaId { get; set; }
        public string? AreaName { get; set; }
        public int? PincodeId { get; set; }
        public string? PincodeValue { get; set; }
        public string? LocalityName { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class LocationDto
    {
        public int LocationId { get; set; }
        public string LocationName { get; set; } = string.Empty;
        public string? State { get; set; } = string.Empty;
        public int? StateId { get; set; }
        public string? StateName { get; set; }
        public int? CityId { get; set; }
        public string? CityName { get; set; }
        public int? AreaId { get; set; }
        public string? AreaName { get; set; }
        public int? PincodeId { get; set; }
        public string? PincodeValue { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class CreateLocationRequest
    {
        [Required]
        [StringLength(100)]
        public string LocationName { get; set; } = string.Empty;
        
        // Legacy field for backward compatibility
        [StringLength(50)]
        public string? State { get; set; }
        
        // New hierarchical fields
        public int? StateId { get; set; }
        public int? CityId { get; set; }
        public int? AreaId { get; set; }
        public int? PincodeId { get; set; }
    }

    public class TaskRescheduleRequest
    {
        [Required]
        public DateTime NewTaskDate { get; set; }
        
        [Required]
        public DateTime NewDeadline { get; set; }
        
        [StringLength(500)]
        public string? RescheduleReason { get; set; }
    }

    public class TaskRescheduleDto
    {
        public int RescheduleId { get; set; }
        public int TaskId { get; set; }
        public DateTime OriginalTaskDate { get; set; }
        public DateTime OriginalDeadline { get; set; }
        public DateTime NewTaskDate { get; set; }
        public DateTime NewDeadline { get; set; }
        public string? RescheduleReason { get; set; }
        public int RescheduledByUserId { get; set; }
        public string RescheduledByUserName { get; set; } = string.Empty;
        public DateTime RescheduledAt { get; set; }
    }
}