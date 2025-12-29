using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MarketingTaskAPI.Data;
using MarketingTaskAPI.Models;

namespace MarketingTaskAPI.Controllers
{
    [ApiController]
    [Route("api/locations")]
    public class LocationsController : ControllerBase
    {
        private readonly MarketingTaskDbContext _context;

        public LocationsController(MarketingTaskDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetLocations()
        {
            try
            {
                var data = await _context.Locations
                    .Include(l => l.StateNavigation)
                    .Include(l => l.CityNavigation)
                    .Include(l => l.AreaNavigation)
                    .Include(l => l.PincodeNavigation)
                    .AsNoTracking()
                    .Select(l => new LocationDto
                    {
                        LocationId = l.LocationId,
                        LocationName = l.LocationName,
                        State = l.State,
                        StateId = l.StateId,
                        StateName = l.StateNavigation != null ? l.StateNavigation.StateName : null,
                        CityId = l.CityId,
                        CityName = l.CityNavigation != null ? l.CityNavigation.CityName : null,
                        AreaId = l.AreaId,
                        AreaName = l.AreaNavigation != null ? l.AreaNavigation.AreaName : null,
                        PincodeId = l.PincodeId,
                        PincodeValue = l.PincodeNavigation != null ? l.PincodeNavigation.PincodeValue : null,
                        CreatedAt = l.CreatedAt
                    })
                    .OrderBy(l => l.LocationName)
                    .ToListAsync();

                return Ok(data);
            }
            catch (Exception ex)
            {
                // Log error here if logger available
                return StatusCode(500, new { success = false, error = ex.Message });
            }
        }

        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetLocationById(int id)
        {
            try
            {
                var l = await _context.Locations
                    .AsNoTracking()
                    .FirstOrDefaultAsync(x => x.LocationId == id);
                if (l == null)
                {
                    return NotFound(new { success = false, error = "Location not found" });
                }
                var dto = new LocationDto
                {
                    LocationId = l.LocationId,
                    LocationName = l.LocationName,
                    State = l.State,
                    StateId = l.StateId,
                    StateName = l.StateNavigation != null ? l.StateNavigation.StateName : null,
                    CityId = l.CityId,
                    CityName = l.CityNavigation != null ? l.CityNavigation.CityName : null,
                    AreaId = l.AreaId,
                    AreaName = l.AreaNavigation != null ? l.AreaNavigation.AreaName : null,
                    PincodeId = l.PincodeId,
                    PincodeValue = l.PincodeNavigation != null ? l.PincodeNavigation.PincodeValue : null,
                    CreatedAt = l.CreatedAt
                };
                return Ok(dto);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, error = ex.Message });
            }
        }

        [HttpGet("states")]
        public async Task<IActionResult> GetStates()
        {
            try
            {
                var data = await _context.States
                    .AsNoTracking()
                    .Select(s => new { id = s.StateId, name = s.StateName })
                    .OrderBy(s => s.name)
                    .ToListAsync();

                return Ok(data);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, error = ex.Message });
            }
        }

        [HttpGet("cities")]
        public async Task<IActionResult> GetCities(int? stateId = null)
        {
            try
            {
                var query = _context.Cities.AsNoTracking();

                if (stateId.HasValue)
                {
                    query = query.Where(c => c.StateId == stateId.Value);
                }

                var data = await query
                    .Select(c => new { id = c.CityId, name = c.CityName })
                    .OrderBy(c => c.name)
                    .ToListAsync();

                return Ok(data);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, error = ex.Message });
            }
        }

        [HttpGet("localities")]
        public async Task<IActionResult> GetLocalities(int? cityId = null)
        {
            try
            {
                var query = _context.Areas.Where(a => a.IsActive).AsNoTracking();

                if (cityId.HasValue)
                {
                    query = query.Where(a => a.CityId == cityId.Value);
                }

                var data = await query
                    .Select(a => new { id = a.AreaId, name = a.AreaName })
                    .OrderBy(a => a.name)
                    .ToListAsync();

                return Ok(data);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [HttpGet("pincodes")]
        public async Task<IActionResult> GetPincodes(int? localityId = null)
        {
            try
            {
                var query = _context.Pincodes.Where(p => p.IsActive).AsNoTracking();

                if (localityId.HasValue)
                {
                    query = query.Where(p => p.AreaId == localityId.Value);
                }

                var data = await query
                    .Select(p => new { id = p.PincodeId, value = p.PincodeValue, localityName = p.LocalityName })
                    .OrderBy(p => p.value)
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