using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MarketingTaskAPI.Data;
using MarketingTaskAPI.Models;

namespace MarketingTaskAPI.Controllers
{
    [ApiController]
    [Route("api/cities")]
    public class CitiesController : ControllerBase
    {
        private readonly MarketingTaskDbContext _context;

        public CitiesController(MarketingTaskDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetCities([FromQuery] int? stateId = null)
        {
            try
            {
                var query = _context.Cities.Where(c => c.IsActive).AsNoTracking();

                if (stateId.HasValue)
                {
                    query = query.Where(c => c.StateId == stateId.Value);
                }

                var data = await query
                    .OrderBy(c => c.CityName)
                    .Select(c => new { id = c.CityId, name = c.CityName })
                    .ToListAsync();

                return Ok(data);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }
    }
}