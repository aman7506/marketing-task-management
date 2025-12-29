using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MarketingTaskAPI.Models;
using MarketingTaskAPI.Services;
using System.ComponentModel.DataAnnotations;

namespace MarketingTaskAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class TaskTypeController : ControllerBase
    {
        private readonly ITaskTypeService _taskTypeService;

        public TaskTypeController(ITaskTypeService taskTypeService)
        {
            _taskTypeService = taskTypeService;
        }

        /// <summary>
        /// Get all active task types
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<TaskTypeDto>>> GetAllTaskTypes()
        {
            try
            {
                var taskTypes = await _taskTypeService.GetAllTaskTypesAsync();
                return Ok(taskTypes);
            }
            catch (Exception ex)
            {
                // Log error here if logger available
                return StatusCode(500, new { success = false, error = ex.Message });
            }
        }

        /// <summary>
        /// Get task type by ID
        /// </summary>
        [HttpGet("{taskTypeId}")]
        public async Task<ActionResult<TaskTypeDto>> GetTaskTypeById(int taskTypeId)
        {
            var taskType = await _taskTypeService.GetTaskTypeByIdAsync(taskTypeId);
            if (taskType == null)
            {
                return NotFound();
            }

            return Ok(taskType);
        }

        /// <summary>
        /// </summary>
        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<TaskTypeDto>> CreateTaskType([FromBody] CreateTaskTypeRequest request)
        {
            try
            {
                var taskType = await _taskTypeService.CreateTaskTypeAsync(request.TypeName, request.Description);
                return CreatedAtAction(nameof(GetTaskTypeById), new { taskTypeId = taskType.TaskTypeId }, taskType);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        /// <summary>
        /// </summary>
        [HttpPut("{taskTypeId}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<TaskTypeDto>> UpdateTaskType(int taskTypeId, [FromBody] UpdateTaskTypeRequest request)
        {
            try
            {
                var taskType = await _taskTypeService.UpdateTaskTypeAsync(taskTypeId, request.TypeName, request.Description);
                if (taskType == null)
                {
                    return NotFound();
                }

                return Ok(taskType);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        /// <summary>
        /// </summary>
        [HttpDelete("{taskTypeId}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> DeleteTaskType(int taskTypeId)
        {
            var result = await _taskTypeService.DeleteTaskTypeAsync(taskTypeId);
            if (!result)
            {
                return NotFound();
            }

            return NoContent();
        }

        /// <summary>
        /// </summary>
        [HttpPatch("{taskTypeId}/toggle-status")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> ToggleTaskTypeStatus(int taskTypeId)
        {
            var result = await _taskTypeService.ToggleTaskTypeStatusAsync(taskTypeId);
            if (!result)
            {
                return NotFound();
            }

            return NoContent();
        }
    }

    public class CreateTaskTypeRequest
    {
        [Required]
        [StringLength(50)]
        public string TypeName { get; set; } = string.Empty;
        
        [StringLength(200)]
        public string? Description { get; set; }
    }

    public class UpdateTaskTypeRequest
    {
        [Required]
        [StringLength(50)]
        public string TypeName { get; set; } = string.Empty;
        
        [StringLength(200)]
        public string? Description { get; set; }
    }
}
