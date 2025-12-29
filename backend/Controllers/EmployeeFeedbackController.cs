using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MarketingTaskAPI.Models;
using MarketingTaskAPI.Services;
using System.Security.Claims;

namespace MarketingTaskAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class EmployeeFeedbackController : ControllerBase
    {
        private readonly IEmployeeFeedbackService _feedbackService;

        public EmployeeFeedbackController(IEmployeeFeedbackService feedbackService)
        {
            _feedbackService = feedbackService;
        }

        /// <summary>
        /// Get all feedback for the current employee
        /// </summary>
        [HttpGet("my-feedback")]
        public async Task<ActionResult<IEnumerable<EmployeeFeedbackDto>>> GetMyFeedback()
        {
            var employeeIdClaim = User.FindFirst("EmployeeId")?.Value;
            if (string.IsNullOrEmpty(employeeIdClaim) || !int.TryParse(employeeIdClaim, out int employeeId))
            {
                return BadRequest("Employee ID not found in token");
            }

            var feedback = await _feedbackService.GetFeedbackByEmployeeIdAsync(employeeId);
            return Ok(feedback);
        }

        /// <summary>
        /// </summary>
        [HttpGet("task/{taskId}")]
        public async Task<ActionResult<IEnumerable<EmployeeFeedbackDto>>> GetFeedbackByTask(int taskId)
        {
            var feedback = await _feedbackService.GetFeedbackByTaskIdAsync(taskId);
            return Ok(feedback);
        }

        /// <summary>
        /// Get feedback by ID
        /// </summary>
        [HttpGet("{feedbackId}")]
        public async Task<ActionResult<EmployeeFeedbackDto>> GetFeedbackById(int feedbackId)
        {
            var feedback = await _feedbackService.GetFeedbackByIdAsync(feedbackId);
            if (feedback == null)
            {
                return NotFound();
            }

            return Ok(feedback);
        }

        /// <summary>
        /// </summary>
        [HttpPost]
        [Authorize(Roles = "Employee")]
        public async Task<ActionResult<EmployeeFeedbackDto>> CreateFeedback([FromBody] CreateEmployeeFeedbackRequest request)
        {
            var employeeIdClaim = User.FindFirst("EmployeeId")?.Value;
            if (string.IsNullOrEmpty(employeeIdClaim) || !int.TryParse(employeeIdClaim, out int employeeId))
            {
                return BadRequest("Employee ID not found in token");
            }

            try
            {
                var feedback = await _feedbackService.CreateFeedbackAsync(employeeId, request);
                return CreatedAtAction(nameof(GetFeedbackById), new { feedbackId = feedback.FeedbackId }, feedback);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        /// <summary>
        /// </summary>
        [HttpPut("{feedbackId}")]
        [Authorize(Roles = "Employee")]
        public async Task<ActionResult<EmployeeFeedbackDto>> UpdateFeedback(int feedbackId, [FromBody] UpdateEmployeeFeedbackRequest request)
        {
            var employeeIdClaim = User.FindFirst("EmployeeId")?.Value;
            if (string.IsNullOrEmpty(employeeIdClaim) || !int.TryParse(employeeIdClaim, out int employeeId))
            {
                return BadRequest("Employee ID not found in token");
            }

            var feedback = await _feedbackService.UpdateFeedbackAsync(feedbackId, employeeId, request);
            if (feedback == null)
            {
                return NotFound();
            }

            return Ok(feedback);
        }

        /// <summary>
        /// </summary>
        [HttpDelete("{feedbackId}")]
        [Authorize(Roles = "Employee")]
        public async Task<ActionResult> DeleteFeedback(int feedbackId)
        {
            var employeeIdClaim = User.FindFirst("EmployeeId")?.Value;
            if (string.IsNullOrEmpty(employeeIdClaim) || !int.TryParse(employeeIdClaim, out int employeeId))
            {
                return BadRequest("Employee ID not found in token");
            }

            var result = await _feedbackService.DeleteFeedbackAsync(feedbackId, employeeId);
            if (!result)
            {
                return NotFound();
            }

            return NoContent();
        }

        /// <summary>
        /// </summary>
        [HttpGet("employee/{employeeId}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<IEnumerable<EmployeeFeedbackDto>>> GetFeedbackByEmployee(int employeeId)
        {
            var feedback = await _feedbackService.GetFeedbackByEmployeeIdAsync(employeeId);
            return Ok(feedback);
        }
    }
}
