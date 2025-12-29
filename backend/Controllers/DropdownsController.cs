using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;
using MarketingTaskAPI.Data;
using System.Data.Common;
using Microsoft.EntityFrameworkCore;
using System;

namespace MarketingTaskAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DropdownsController : ControllerBase
    {
        private readonly MarketingTaskDbContext _db;

        public DropdownsController(MarketingTaskDbContext db)
        {
            _db = db;
        }

        private async Task<List<object>> QueryIdNameAsync(string sql, params (string name, object value)[] parameters)
        {
            var results = new List<object>();
            var conn = _db.Database.GetDbConnection();
            try
            {
                if (conn.State != System.Data.ConnectionState.Open)
                    await conn.OpenAsync();

                using var cmd = conn.CreateCommand();
                cmd.CommandText = sql;

                foreach (var (name, value) in parameters)
                {
                    var p = cmd.CreateParameter();
                    p.ParameterName = name;
                    p.Value = value ?? System.DBNull.Value;
                    cmd.Parameters.Add(p);
                }

                using var reader = await cmd.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    var id = reader.IsDBNull(0) ? null : reader.GetValue(0);
                    var name = reader.FieldCount > 1 && !reader.IsDBNull(1) ? reader.GetValue(1)?.ToString() : null;
                    results.Add(new { id, name });
                }

                return results;
            }
            catch
            {
                return results;
            }
            finally
            {
                if (conn.State == System.Data.ConnectionState.Open)
                    await conn.CloseAsync();
            }
        }

        [HttpGet("employees")]
        public async Task<IActionResult> GetEmployees()
        {
            // Employees table: EmployeeId, Name
            var data = await _db.Employees
                .AsNoTracking()
                .OrderBy(e => e.Name)
                .Select(e => new { id = e.EmployeeId, name = e.Name })
                .ToListAsync();
            return Ok(data);
        }

        [HttpGet("priorities")]
        public IActionResult GetPriorities()
        {
            var data = new[] {
                new { id = 1, name = "Low" },
                new { id = 2, name = "Medium" },
                new { id = 3, name = "High" }
            };
            return Ok(data);
        }

        [HttpGet("states")]
        public async Task<IActionResult> GetStates()
        {
            var data = await _db.States
                .AsNoTracking()
                .OrderBy(s => s.StateName)
                .Select(s => new { id = s.StateId, name = s.StateName })
                .ToListAsync();
            return Ok(new { success = true, data });
        }

        [HttpGet("areas")]
        public async Task<IActionResult> GetAreas([FromQuery] int cityId)
        {
            var data = await _db.Areas
                .AsNoTracking()
                .Where(a => a.CityId == cityId)
                .OrderBy(a => a.AreaName)
                .Select(a => new { id = a.AreaId, name = a.AreaName })
                .ToListAsync();
            return Ok(new { success = true, data });
        }

        [HttpGet("pincodes")]
        public async Task<IActionResult> GetPincodes([FromQuery] int areaId)
        {
            var data = await _db.Pincodes
                .AsNoTracking()
                .Where(p => p.AreaId == areaId)
                .OrderBy(p => p.PincodeValue)
                .Select(p => new { id = p.PincodeId, name = p.PincodeValue })
                .ToListAsync();
            return Ok(new { success = true, data });
        }

        [HttpGet("statuses")]
        public IActionResult GetStatuses()
        {
            var data = new[] {
                new { id = 1, name = "Not Started" },
                new { id = 2, name = "In Progress" },
                new { id = 3, name = "Completed" },
                new { id = 4, name = "Postponed" },
                new { id = 5, name = "Partial Close" }
            };
            return Ok(data);
        }

        [HttpGet("task-types")]
        public async Task<IActionResult> GetTaskTypes()
        {
            var data = await _db.TaskTypes
                .AsNoTracking()
                .Where(t => t.IsActive)
                .OrderBy(t => t.TypeName)
                .Select(t => new { id = t.TaskTypeId, name = t.TypeName })
                .ToListAsync();
            return Ok(data);
        }

        [HttpGet("locations")]
        public async Task<IActionResult> GetLocations()
        {
            var data = await _db.Locations
                .AsNoTracking()
                .OrderBy(l => l.LocationName)
                .Select(l => new { id = l.LocationId, name = l.LocationName })
                .ToListAsync();
            return Ok(data);
        }

        [HttpGet("departments")]
        public IActionResult GetDepartments()
        {
            var data = new[] {
                new { id = 1, name = "Marketing" },
                new { id = 2, name = "Operations" },
                new { id = 3, name = "Business Development" },
                new { id = 4, name = "Customer Service" },
                new { id = 5, name = "Analytics" }
            };
            return Ok(data);
        }
    }
}
