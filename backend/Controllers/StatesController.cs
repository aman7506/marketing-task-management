using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MarketingTaskAPI.Data;
using MarketingTaskAPI.Models;

namespace MarketingTaskAPI.Controllers
{
    [ApiController]
    [Route("api/states")]
    public class StatesController : ControllerBase
    {
        private readonly MarketingTaskDbContext _context;

        public StatesController(MarketingTaskDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetStates()
        {
            try
            {
                var data = await _context.States
                    .Where(s => s.IsActive)
                    .AsNoTracking()
                    .Select(s => new { id = s.StateId, name = s.StateName })
                    .OrderBy(s => s.name)
                    .ToListAsync();

                return Ok(data);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetStateById(int id)
        {
            try
            {
                var state = await _context.States
                    .AsNoTracking()
                    .FirstOrDefaultAsync(s => s.StateId == id);

                if (state == null)
                {
                    return NotFound(new { success = false, error = "State not found" });
                }

                return Ok(new { success = true, data = new { id = state.StateId, name = state.StateName, code = state.StateCode } });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, error = ex.Message });
            }
        }
    }
}