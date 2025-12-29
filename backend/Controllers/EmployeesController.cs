using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MarketingTaskAPI.Data;
using MarketingTaskAPI.Models;

namespace MarketingTaskAPI.Controllers
{
    [ApiController]
    [Route("api/employees")]
    public class EmployeesController : ControllerBase
    {
        private readonly MarketingTaskDbContext _context;

        public EmployeesController(MarketingTaskDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetEmployees()
        {
            try
            {
                var employees = await _context.Employees
                    .AsNoTracking()
                    .Where(e => e.IsActive == true)
                    .OrderBy(e => e.Name)
                    .Select(e => new {
                        employeeId = e.EmployeeId,
                        name = e.Name,
                        contact = e.Contact,
                        designation = e.Designation,
                        email = e.Email
                    })
                    .ToListAsync();

                return Ok(employees);
            }
            catch (Exception ex)
            {
                // Log error here if logger available
                return StatusCode(500, new { success = false, error = ex.Message });
            }
        }
    }
}
