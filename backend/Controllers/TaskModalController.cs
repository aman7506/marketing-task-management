using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using MarketingTaskAPI.Data;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;

namespace MarketingTaskAPI.Controllers
{
    [ApiController]
    [Route("api/task-modal")]
    public class TaskModalController : ControllerBase
    {
        private readonly MarketingTaskDbContext _db;

        public TaskModalController(MarketingTaskDbContext db)
        {
            _db = db;
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetTask(int id)
        {
            var conn = _db.Database.GetDbConnection();
            try
            {
                if (conn.State != System.Data.ConnectionState.Open)
                    await conn.OpenAsync();

                using var cmd = conn.CreateCommand();
                cmd.CommandText = @"SELECT Id, Title, Description, AssignedEmployeeId, PriorityId, StateId, CityId, AreaId, PincodeId, StatusId, ClassificationId, CategoryId, DepartmentId, CreatedAt, DueDate
                                    FROM Tasks WHERE Id = @id";
                var p = cmd.CreateParameter();
                p.ParameterName = "@id";
                p.Value = id;
                cmd.Parameters.Add(p);

                using var reader = await cmd.ExecuteReaderAsync();
                if (!await reader.ReadAsync()) return NotFound();

                var result = new Dictionary<string, object?>();
                for (int i = 0; i < reader.FieldCount; i++)
                {
                    var name = reader.GetName(i);
                    var value = reader.IsDBNull(i) ? null : reader.GetValue(i);
                    result[name] = value;
                }

                return Ok(result);
            }
            catch (System.Exception ex)
            {
                return Problem(ex.Message);
            }
            finally
            {
                if (conn.State == System.Data.ConnectionState.Open)
                    await conn.CloseAsync();
            }
        }

        public class TaskUpdateDto
        {
            public string? Title { get; set; }
            public string? Description { get; set; }
            public int? AssignedEmployeeId { get; set; }
            public int? PriorityId { get; set; }
            public int? StateId { get; set; }
            public int? CityId { get; set; }
            public int? AreaId { get; set; }
            public int? PincodeId { get; set; }
            public int? StatusId { get; set; }
            public int? ClassificationId { get; set; }
            public int? CategoryId { get; set; }
            public int? DepartmentId { get; set; }
            public System.DateTime? DueDate { get; set; }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateTask(int id, [FromBody] TaskUpdateDto dto)
        {
            if (dto == null) return BadRequest();

            var updates = new List<string>();
            var parameters = new List<(string name, object value)>();

            void AddUpdate(string column, object? value)
            {
                if (value != null)
                {
                    var paramName = "@" + column;
                    updates.Add($"{column} = {paramName}");
                    parameters.Add((paramName, value));
                }
            }

            AddUpdate("Title", dto.Title);
            AddUpdate("Description", dto.Description);
            AddUpdate("AssignedEmployeeId", dto.AssignedEmployeeId);
            AddUpdate("PriorityId", dto.PriorityId);
            AddUpdate("StateId", dto.StateId);
            AddUpdate("CityId", dto.CityId);
            AddUpdate("AreaId", dto.AreaId);
            AddUpdate("PincodeId", dto.PincodeId);
            AddUpdate("StatusId", dto.StatusId);
            AddUpdate("ClassificationId", dto.ClassificationId);
            AddUpdate("CategoryId", dto.CategoryId);
            AddUpdate("DepartmentId", dto.DepartmentId);
            AddUpdate("DueDate", dto.DueDate);

            if (updates.Count == 0) return BadRequest("No updatable fields provided.");

            var sql = $"UPDATE Tasks SET {string.Join(", ", updates)} WHERE Id = @id";

            var conn = _db.Database.GetDbConnection();
            try
            {
                if (conn.State != System.Data.ConnectionState.Open)
                    await conn.OpenAsync();

                using var cmd = conn.CreateCommand();
                cmd.CommandText = sql;

                var idParam = cmd.CreateParameter();
                idParam.ParameterName = "@id";
                idParam.Value = id;
                cmd.Parameters.Add(idParam);

                foreach (var (name, value) in parameters)
                {
                    var p = cmd.CreateParameter();
                    p.ParameterName = name;
                    p.Value = value ?? System.DBNull.Value;
                    cmd.Parameters.Add(p);
                }

                var affected = await cmd.ExecuteNonQueryAsync();
                if (affected == 0) return NotFound();

                return NoContent();
            }
            catch (System.Exception ex)
            {
                return Problem(ex.Message);
            }
            finally
            {
                if (conn.State == System.Data.ConnectionState.Open)
                    await conn.CloseAsync();
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTask(int id)
        {
            var conn = _db.Database.GetDbConnection();
            try
            {
                if (conn.State != System.Data.ConnectionState.Open)
                    await conn.OpenAsync();

                using var cmd = conn.CreateCommand();
                cmd.CommandText = "DELETE FROM Tasks WHERE Id = @id";
                var p = cmd.CreateParameter();
                p.ParameterName = "@id";
                p.Value = id;
                cmd.Parameters.Add(p);

                var affected = await cmd.ExecuteNonQueryAsync();
                if (affected == 0) return NotFound();

                return NoContent();
            }
            catch (System.Exception ex)
            {
                return Problem(ex.Message);
            }
            finally
            {
                if (conn.State == System.Data.ConnectionState.Open)
                    await conn.CloseAsync();
            }
        }
    }
}