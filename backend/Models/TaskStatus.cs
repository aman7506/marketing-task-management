using System.ComponentModel.DataAnnotations;

namespace MarketingTaskAPI.Models
{
    public class TaskStatusEntity
    {
        [Key]
        public int StatusId { get; set; }

        [Required]
        [StringLength(50)]
        public string StatusName { get; set; } = string.Empty;

        [Required]
        [StringLength(20)]
        public string StatusCode { get; set; } = string.Empty;

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
    
    public class TaskStatusDto
    {
        public int StatusId { get; set; }
        public string StatusName { get; set; } = string.Empty;
        public string StatusCode { get; set; } = string.Empty;
        public bool IsActive { get; set; }
    }
}