using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MarketingTaskAPI.Data;

namespace MarketingTaskAPI.Controllers
{
    [ApiController]
    [Route("api/tasktypes")]
    public class TaskTypesController : ControllerBase
    {
        private readonly MarketingTaskDbContext _context;

        public TaskTypesController(MarketingTaskDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetTaskTypes()
        {
            try
            {
                var data = await _context.TaskTypes
                    .AsNoTracking()
                    .OrderBy(t => t.TypeName)
                    .Select(t => new { id = t.TaskTypeId, name = t.TypeName })
                    .ToListAsync();
                return Ok(data);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, error = ex.Message });
            }
        }
    }
}
