using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MarketingTaskAPI.Data;

namespace MarketingTaskAPI.Controllers
{
    [ApiController]
    [Route("api/pincodes")]
    public class PincodesController : ControllerBase
    {
        private readonly MarketingTaskDbContext _context;

        public PincodesController(MarketingTaskDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetPincodes([FromQuery] int? areaId = null)
        {
            try
            {
                var query = _context.Pincodes.AsNoTracking();
                if (areaId.HasValue)
                    query = query.Where(p => p.AreaId == areaId.Value);
                var data = await query
                    .OrderBy(p => p.PincodeValue ?? string.Empty)
                    .Select(p => new { id = p.PincodeId, value = p.PincodeValue ?? string.Empty, areaId = p.AreaId, localityName = p.LocalityName ?? string.Empty })
                    .ToListAsync();
                return Ok(new { success = true, data });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, error = ex.Message });
            }
        }
        
        [HttpGet("with-localities")]
        public async Task<IActionResult> GetPincodesWithLocalities()
        {
            try
            {
                var data = await _context.Pincodes
                    .Include(p => p.Area)
                    .ThenInclude(a => a.City)
                    .ThenInclude(c => c.State)
                    .AsNoTracking()
                    .Where(p => p.IsActive)
                    .OrderBy(p => p.PincodeValue ?? string.Empty)
                    .Select(p => new { 
                        pincode = p.PincodeValue ?? string.Empty, 
                        locality_name = p.LocalityName ?? string.Empty,
                        pincodeId = p.PincodeId,
                        areaId = p.AreaId,
                        areaName = p.Area.AreaName ?? string.Empty,
                        cityId = p.Area.City.CityId,
                        cityName = p.Area.City.CityName ?? string.Empty,
                        stateId = p.Area.City.State.StateId,
                        stateName = p.Area.City.State.StateName ?? string.Empty
                    })
                    .ToListAsync();
                    
                return Ok(data);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in GetPincodesWithLocalities: {ex.Message}");
                return StatusCode(500, new { success = false, error = ex.Message });
            }
        }
        
        [HttpGet("validate")]
        public async Task<IActionResult> ValidatePincodeLocality([FromQuery] string pincode, [FromQuery] string localityName)
        {
            try
            {
                var exists = await _context.Pincodes
                    .AsNoTracking()
                    .AnyAsync(p => p.PincodeValue == pincode && p.LocalityName == localityName);
                    
                return Ok(new { valid = exists });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, error = ex.Message });
            }
        }

        [HttpGet("dropdowns")]
        public async Task<IActionResult> GetPincodeLocalityDropdowns()
        {
            try
            {
                // Get unique pincodes
                var pincodes = await _context.Pincodes
                    .AsNoTracking()
                    .Where(p => p.IsActive)
                    .Select(p => p.PincodeValue)
                    .Distinct()
                    .OrderBy(p => p)
                    .ToListAsync();

                // Get unique locality names
                var localities = await _context.Pincodes
                    .AsNoTracking()
                    .Where(p => p.IsActive && !string.IsNullOrEmpty(p.LocalityName))
                    .Select(p => p.LocalityName)
                    .Distinct()
                    .OrderBy(l => l)
                    .ToListAsync();

                return Ok(new { 
                    pincodes = pincodes,
                    localities = localities
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in GetPincodeLocalityDropdowns: {ex.Message}");
                return StatusCode(500, new { success = false, error = ex.Message });
            }
        }

        [HttpGet("distinct")]
        public async Task<IActionResult> GetDistinctPincodes()
        {
            try
            {
                var pincodes = await _context.Pincodes
                    .AsNoTracking()
                    .Where(p => p.IsActive)
                    .Select(p => p.PincodeValue)
                    .Distinct()
                    .OrderBy(p => p)
                    .Select(p => new { pincode = p })
                    .ToListAsync();

                return Ok(pincodes);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in GetDistinctPincodes: {ex.Message}");
                return StatusCode(500, new { success = false, error = ex.Message });
            }
        }

        [HttpGet("{pincode}/localities")]
        public async Task<IActionResult> GetLocalitiesByPincode(string pincode)
        {
            try
            {
                var localities = await _context.Pincodes
                    .AsNoTracking()
                    .Where(p => p.PincodeValue == pincode && p.IsActive && !string.IsNullOrEmpty(p.LocalityName))
                    .Select(p => p.LocalityName)
                    .Distinct()
                    .OrderBy(l => l)
                    .ToListAsync();

                return Ok(localities);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in GetLocalitiesByPincode: {ex.Message}");
                return StatusCode(500, new { success = false, error = ex.Message });
            }
        }

        [HttpGet("all-data")]
        public async Task<IActionResult> GetAllPincodeData()
        {
            try
            {
                var data = await _context.Pincodes
                    .AsNoTracking()
                    .Where(p => p.IsActive)
                    .OrderBy(p => p.PincodeValue ?? string.Empty)
                    .Select(p => new { 
                        pincodeId = p.PincodeId,
                        pincode = p.PincodeValue ?? string.Empty,
                        areaId = p.AreaId,
                        localityName = p.LocalityName ?? string.Empty,
                        isActive = p.IsActive,
                        createdAt = p.CreatedAt
                    })
                    .ToListAsync();

                return Ok(new { success = true, data = data });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in GetAllPincodeData: {ex.Message}");
                return StatusCode(500, new { success = false, error = ex.Message });
            }
        }

        [HttpGet("by-locality")]
        public async Task<IActionResult> GetPincodesByLocality([FromQuery] string localityName, [FromQuery] int? areaId = null)
        {
            try
            {
                if (string.IsNullOrEmpty(localityName))
                    return BadRequest(new { success = false, error = "Locality name is required" });

                var query = _context.Pincodes.AsNoTracking().Where(p => p.IsActive && 
                    (p.LocalityName != null && p.LocalityName.ToLower().Contains(localityName.ToLower())));

                if (areaId.HasValue)
                    query = query.Where(p => p.AreaId == areaId.Value);

                var data = await query
                    .OrderBy(p => p.PincodeValue ?? string.Empty)
                    .Select(p => new { 
                        pincodeId = p.PincodeId,
                        pincode = p.PincodeValue ?? string.Empty,
                        areaId = p.AreaId,
                        localityName = p.LocalityName ?? string.Empty
                    })
                    .ToListAsync();

                return Ok(new { success = true, data = data });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in GetPincodesByLocality: {ex.Message}");
                return StatusCode(500, new { success = false, error = ex.Message });
            }
        }

        [HttpGet("search-localities")]
        public async Task<IActionResult> SearchLocalities([FromQuery] string? searchTerm = null, [FromQuery] int? areaId = null)
        {
            try
            {
                var query = _context.Pincodes.AsNoTracking().Where(p => p.IsActive);

                if (areaId.HasValue)
                    query = query.Where(p => p.AreaId == areaId.Value);

                if (!string.IsNullOrEmpty(searchTerm))
                {
                    query = query.Where(p => 
                        (p.LocalityName != null && p.LocalityName.ToLower().Contains(searchTerm.ToLower())));
                }

                var data = await query
                    .Where(p => !string.IsNullOrEmpty(p.LocalityName))
                    .GroupBy(p => p.LocalityName)
                    .Select(g => new { 
                        localityName = g.Key
                    })
                    .OrderBy(p => p.localityName)
                    .ToListAsync();

                return Ok(new { success = true, data = data });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in SearchLocalities: {ex.Message}");
                return StatusCode(500, new { success = false, error = ex.Message });
            }
        }

        [HttpGet("search")]
        public async Task<IActionResult> SearchPincodes([FromQuery] string? searchTerm = null, [FromQuery] int? areaId = null)
        {
            try
            {
                var query = _context.Pincodes.AsNoTracking().Where(p => p.IsActive);

                if (areaId.HasValue)
                    query = query.Where(p => p.AreaId == areaId.Value);

                if (!string.IsNullOrEmpty(searchTerm))
                {
                    query = query.Where(p => 
                        (p.PincodeValue != null && p.PincodeValue.Contains(searchTerm)) || 
                        (p.LocalityName != null && p.LocalityName.Contains(searchTerm)));
                }

                var data = await query
                    .OrderBy(p => p.PincodeValue ?? string.Empty)
                    .Select(p => new { 
                        pincodeId = p.PincodeId,
                        pincode = p.PincodeValue ?? string.Empty,
                        areaId = p.AreaId,
                        localityName = p.LocalityName ?? string.Empty
                    })
                    .ToListAsync();

                return Ok(new { success = true, data = data });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in SearchPincodes: {ex.Message}");
                return StatusCode(500, new { success = false, error = ex.Message });
            }
        }
    }
}
