using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MarketingForm.Controllers
{
    [ApiController]
    [Route("api/localities")]
    public class LocalitiesController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly string _connectionString;

        public LocalitiesController(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("DefaultConnection") ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        // GET: api/localities/by-city?cityId=1
        [HttpGet("by-city")]
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
    }
}
