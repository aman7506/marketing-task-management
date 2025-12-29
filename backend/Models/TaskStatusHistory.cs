using System.ComponentModel.DataAnnotations;

namespace MarketingTaskAPI.Models
{
    public class TaskStatusHistory
    {
        public int HistoryId { get; set; }
        
        public int TaskId { get; set; }
        
        [Required]
        [StringLength(20)]
        public string Status { get; set; } = string.Empty;
        
        [StringLength(500)]
        public string? Remarks { get; set; }
        
        public int ChangedByUserId { get; set; }
        public DateTime ChangedAt { get; set; } = DateTime.UtcNow;
        
        // Navigation properties
        public virtual UserTask Task { get; set; } = null!;
        public virtual User ChangedByUser { get; set; } = null!;
    }
}