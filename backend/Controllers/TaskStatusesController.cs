using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MarketingTaskAPI.Data;
using MarketingTaskAPI.Models;

namespace MarketingTaskAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TaskStatusesController : ControllerBase
    {
        private readonly MarketingTaskDbContext _context;

        public TaskStatusesController(MarketingTaskDbContext context)
        {
            _context = context;
        }

        // GET: api/TaskStatuses
        [HttpGet]
        public async Task<ActionResult<IEnumerable<TaskStatusEntity>>> GetTaskStatuses()
        {
            try
            {
                var taskStatuses = await _context.TaskStatus
                    .OrderBy(ts => ts.StatusName)
                    .ToListAsync();
                
                return Ok(taskStatuses);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        // GET: api/TaskStatuses/5
        [HttpGet("{id}")]
        public async Task<ActionResult<TaskStatusEntity>> GetTaskStatus(int id)
        {
            var taskStatus = await _context.TaskStatus.FindAsync(id);

            if (taskStatus == null)
            {
                return NotFound();
            }

            return taskStatus;
        }

        // POST: api/TaskStatuses
        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<TaskStatusEntity>> CreateTaskStatus(CreateTaskStatusDto createTaskStatusDto)
        {
            if (_context.TaskStatus.Any(ts => ts.StatusName == createTaskStatusDto.StatusName))
            {
                return BadRequest("A task status with this name already exists.");
            }

            var taskStatus = new TaskStatusEntity
            {
                StatusName = createTaskStatusDto.StatusName,
                StatusCode = createTaskStatusDto.StatusCode,
                CreatedAt = DateTime.UtcNow
            };

            _context.TaskStatus.Add(taskStatus);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetTaskStatus), new { id = taskStatus.StatusId }, taskStatus);
        }

        // PUT: api/TaskStatuses/5
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UpdateTaskStatus(int id, UpdateTaskStatusDto updateTaskStatusDto)
        {
            var taskStatus = await _context.TaskStatus.FindAsync(id);

            if (taskStatus == null)
            {
                return NotFound();
            }

            if (_context.TaskStatus.Any(ts => ts.StatusId != id && ts.StatusName == updateTaskStatusDto.StatusName))
            {
                return BadRequest("A task status with this name already exists.");
            }

            taskStatus.StatusName = updateTaskStatusDto.StatusName;
            taskStatus.StatusCode = updateTaskStatusDto.StatusCode;

            _context.Entry(taskStatus).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!TaskStatusExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // DELETE: api/TaskStatuses/5
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeleteTaskStatus(int id)
        {
            var taskStatus = await _context.TaskStatus.FindAsync(id);
            if (taskStatus == null)
            {
                return NotFound();
            }

            _context.TaskStatus.Remove(taskStatus);

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!TaskStatusExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        private bool TaskStatusExists(int id)
        {
            return _context.TaskStatus.Any(e => e.StatusId == id);
        }
    }
}
