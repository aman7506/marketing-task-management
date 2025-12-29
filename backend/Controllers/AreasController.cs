using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MarketingTaskAPI.Data;

namespace MarketingTaskAPI.Controllers
{
    [ApiController]
    [Route("api/areas")]
    public class AreasController : ControllerBase
    {
        private readonly MarketingTaskDbContext _context;

        public AreasController(MarketingTaskDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAreas([FromQuery] int? cityId = null)
        {
            try
            {
                var query = _context.Areas.AsNoTracking();

                if (cityId.HasValue)
                {
                    query = query.Where(a => a.CityId == cityId.Value);
                }

                var data = await query
                    .Include(a => a.City)
                    .OrderBy(a => a.AreaName)
                    .Select(a => new { id = a.AreaId, name = a.AreaName, cityId = a.CityId, cityName = a.City.CityName })
                    .ToListAsync();

                return Ok(new { success = true, data });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, error = ex.Message });
            }
        }
    }
}
