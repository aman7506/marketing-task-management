using System.ComponentModel.DataAnnotations;

namespace MarketingTaskAPI.Models
{
    public class CreateTaskStatusDto
    {
        [Required(ErrorMessage = "Status name is required.")]
        [StringLength(50, ErrorMessage = "Status name cannot exceed 50 characters.")]
        public string StatusName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Status code is required.")]
        [StringLength(20, ErrorMessage = "Status code cannot exceed 20 characters.")]
        public string StatusCode { get; set; } = string.Empty;
    }

    public class UpdateTaskStatusDto
    {
        [Required(ErrorMessage = "Status name is required.")]
        [StringLength(50, ErrorMessage = "Status name cannot exceed 50 characters.")]
        public string StatusName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Status code is required.")]
        [StringLength(20, ErrorMessage = "Status code cannot exceed 20 characters.")]
        public string StatusCode { get; set; } = string.Empty;

        public bool IsActive { get; set; }
    }
}
