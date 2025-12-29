using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Text.Json;

namespace MarketingForm.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class LocationController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly string _connectionString;

        public LocationController(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("DefaultConnection") ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        // GET: api/location/localities
        [HttpGet("localities")]
        public async Task<IActionResult> GetAllLocalities()
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                var query = @"
                    SELECT DISTINCT 
                        LocalityName,
                        Pincode,
                        AreaId
                    FROM Pincodes 
                    WHERE IsActive = 1 
                    ORDER BY LocalityName";

                using var command = new SqlCommand(query, connection);
                using var reader = await command.ExecuteReaderAsync();

                var localities = new List<object>();
                while (await reader.ReadAsync())
                {
                    localities.Add(new
                    {
                        localityName = reader["LocalityName"].ToString(),
                        pincode = reader["Pincode"].ToString(),
                        areaId = reader["AreaId"]
                    });
                }

                return Ok(new
                {
                    success = true,
                    data = localities,
                    message = $"Found {localities.Count} localities"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Error loading localities: " + ex.Message
                });
            }
        }

        // GET: api/location/localities/by-city?cityId=1
        [HttpGet("localities/by-city")]
        public async Task<IActionResult> GetLocalitiesByCity([FromQuery] int cityId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                var query = @"SELECT DISTINCT LocalityName FROM Localities WHERE CityId = @cityId ORDER BY LocalityName";
                using var command = new SqlCommand(query, connection);
                command.Parameters.AddWithValue("@cityId", cityId);

                var localities = new List<string>();
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    localities.Add(reader["LocalityName"].ToString() ?? "");
                }
                return Ok(new { data = localities });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Error loading localities by city: " + ex.Message
                });
            }
        }

        // GET: api/location/localities/search?term=searchTerm
        [HttpGet("localities/search")]
        public async Task<IActionResult> SearchLocalities([FromQuery] string term)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(term))
                {
                    return await GetAllLocalities();
                }

                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                var query = @"
                    SELECT DISTINCT 
                        LocalityName,
                        Pincode,
                        AreaId
                    FROM Pincodes 
                    WHERE IsActive = 1 
                    AND LocalityName LIKE @searchTerm
                    ORDER BY LocalityName";

                using var command = new SqlCommand(query, connection);
                command.Parameters.AddWithValue("@searchTerm", $"%{term}%");
                using var reader = await command.ExecuteReaderAsync();

                var localities = new List<object>();
                while (await reader.ReadAsync())
                {
                    localities.Add(new
                    {
                        localityName = reader["LocalityName"].ToString(),
                        pincode = reader["Pincode"].ToString(),
                        areaId = reader["AreaId"]
                    });
                }

                return Ok(new
                {
                    success = true,
                    data = localities,
                    message = $"Found {localities.Count} localities matching '{term}'"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Error searching localities: " + ex.Message
                });
            }
        }

        // GET: api/location/pincodes
        [HttpGet("pincodes")]
        public async Task<IActionResult> GetAllPincodes()
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                var query = @"
                    SELECT 
                        PincodeId,
                        Pincode,
                        AreaId,
                        LocalityName,
                        IsActive
                    FROM Pincodes 
                    WHERE IsActive = 1 
                    ORDER BY Pincode, LocalityName";

                using var command = new SqlCommand(query, connection);
                using var reader = await command.ExecuteReaderAsync();

                var pincodes = new List<object>();
                while (await reader.ReadAsync())
                {
                    pincodes.Add(new
                    {
                        pincodeId = reader["PincodeId"],
                        pincode = reader["Pincode"].ToString(),
                        areaId = reader["AreaId"],
                        localityName = reader["LocalityName"].ToString(),
                        isActive = reader["IsActive"]
                    });
                }

                return Ok(new
                {
                    success = true,
                    data = pincodes,
                    message = $"Found {pincodes.Count} pincodes"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Error loading pincodes: " + ex.Message
                });
            }
        }

        // GET: api/location/pincodes/search?term=searchTerm
        [HttpGet("pincodes/search")]
        public async Task<IActionResult> SearchPincodes([FromQuery] string term)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(term))
                {
                    return await GetAllPincodes();
                }

                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                var query = @"
                    SELECT 
                        PincodeId,
                        Pincode,
                        AreaId,
                        LocalityName,
                        IsActive
                    FROM Pincodes 
                    WHERE IsActive = 1 
                    AND (Pincode LIKE @searchTerm OR LocalityName LIKE @searchTerm)
                    ORDER BY Pincode, LocalityName";

                using var command = new SqlCommand(query, connection);
                command.Parameters.AddWithValue("@searchTerm", $"%{term}%");
                using var reader = await command.ExecuteReaderAsync();

                var pincodes = new List<object>();
                while (await reader.ReadAsync())
                {
                    pincodes.Add(new
                    {
                        pincodeId = reader["PincodeId"],
                        pincode = reader["Pincode"].ToString(),
                        areaId = reader["AreaId"],
                        localityName = reader["LocalityName"].ToString(),
                        isActive = reader["IsActive"]
                    });
                }

                return Ok(new
                {
                    success = true,
                    data = pincodes,
                    message = $"Found {pincodes.Count} pincodes matching '{term}'"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Error searching pincodes: " + ex.Message
                });
            }
        }

        // GET: api/location/pincodes/by-locality?locality=localityName
        [HttpGet("pincodes/by-locality")]
        public async Task<IActionResult> GetPincodesByLocality([FromQuery] string locality)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(locality))
                {
                    return BadRequest(new
                    {
                        success = false,
                        message = "Locality parameter is required"
                    });
                }

                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                var query = @"
                    SELECT 
                        PincodeId,
                        Pincode,
                        AreaId,
                        LocalityName,
                        IsActive
                    FROM Pincodes 
                    WHERE IsActive = 1 
                    AND LocalityName LIKE @locality
                    ORDER BY Pincode";

                using var command = new SqlCommand(query, connection);
                command.Parameters.AddWithValue("@locality", $"%{locality}%");
                using var reader = await command.ExecuteReaderAsync();

                var pincodes = new List<object>();
                while (await reader.ReadAsync())
                {
                    pincodes.Add(new
                    {
                        pincodeId = reader["PincodeId"],
                        pincode = reader["Pincode"].ToString(),
                        areaId = reader["AreaId"],
                        localityName = reader["LocalityName"].ToString(),
                        isActive = reader["IsActive"]
                    });
                }

                return Ok(new
                {
                    success = true,
                    data = pincodes,
                    message = $"Found {pincodes.Count} pincodes for locality '{locality}'"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Error loading pincodes for locality: " + ex.Message
                });
            }
        }

        // GET: api/location/pincode-locality-table
        [HttpGet("pincode-locality-table")]
        public async Task<IActionResult> GetPincodeLocalityMaster()
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();
                var query = @"SELECT PincodeId, Pincode, AreaId, LocalityName, IsActive, CreatedAt FROM Pincodes ORDER BY PincodeId";
                using var command = new SqlCommand(query, connection);
                using var reader = await command.ExecuteReaderAsync();
                var result = new List<object>();
                while (await reader.ReadAsync())
                {
                    result.Add(new {
                        pincodeId = reader["PincodeId"],
                        pincode = reader["Pincode"].ToString(),
                        areaId = reader["AreaId"],
                        localityName = reader["LocalityName"].ToString(),
                        isActive = reader["IsActive"],
                        createdAt = reader["CreatedAt"]
                    });
                }
                return Ok(new { success = true, data = result });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        // POST: api/location/bulk-fix-pincodes
        [HttpPost("bulk-fix-pincodes")]
        public async Task<IActionResult> BulkFixPincodes([FromBody] List<PincodeLocalityFixDto> fixes)
        {
            if (fixes == null || fixes.Count == 0) return BadRequest(new { success = false, message = "No data provided" });
            int fixCount = 0;
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();
                foreach (var fix in fixes) {
                    var cmd = new SqlCommand("UPDATE Pincodes SET LocalityName = @LocalityName WHERE Pincode = @Pincode", connection);
                    cmd.Parameters.AddWithValue("@LocalityName", fix.LocalityName ?? "");
                    cmd.Parameters.AddWithValue("@Pincode", fix.Pincode ?? "");
                    fixCount += await cmd.ExecuteNonQueryAsync();
                }
                return Ok(new { success = true, updated = fixCount });
            }
            catch (Exception ex) {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }
        public class PincodeLocalityFixDto {
            public string Pincode { get; set; } = string.Empty;
            public string LocalityName { get; set; } = string.Empty;
        }

        // GET: api/location/states
        [HttpGet("states")]
        public async Task<IActionResult> GetAllStates()
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                var query = @"
                    SELECT 
                        StateId,
                        StateName,
                        StateCode
                    FROM States 
                    WHERE IsActive = 1 
                    ORDER BY StateName";

                using var command = new SqlCommand(query, connection);
                using var reader = await command.ExecuteReaderAsync();

                var states = new List<object>();
                while (await reader.ReadAsync())
                {
                    states.Add(new
                    {
                        stateId = reader["StateId"],
                        stateName = reader["StateName"].ToString(),
                        stateCode = reader["StateCode"].ToString()
                    });
                }

                return Ok(new
                {
                    success = true,
                    data = states,
                    message = $"Found {states.Count} states"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Error loading states: " + ex.Message
                });
            }
        }

        // GET: api/location/cities?stateId=stateId
        [HttpGet("cities")]
        public async Task<IActionResult> GetCitiesByState([FromQuery] int stateId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                var query = @"
                    SELECT 
                        CityId,
                        CityName,
                        StateId
                    FROM Cities 
                    WHERE IsActive = 1 
                    AND StateId = @stateId
                    ORDER BY CityName";

                using var command = new SqlCommand(query, connection);
                command.Parameters.AddWithValue("@stateId", stateId);
                using var reader = await command.ExecuteReaderAsync();

                var cities = new List<object>();
                while (await reader.ReadAsync())
                {
                    cities.Add(new
                    {
                        cityId = reader["CityId"],
                        cityName = reader["CityName"].ToString(),
                        stateId = reader["StateId"]
                    });
                }

                return Ok(new
                {
                    success = true,
                    data = cities,
                    message = $"Found {cities.Count} cities for state {stateId}"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Error loading cities: " + ex.Message
                });
            }
        }
    }
} 