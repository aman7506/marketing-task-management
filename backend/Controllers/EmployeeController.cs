using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using MarketingTaskAPI.Services;
using MarketingTaskAPI.Models;

namespace MarketingTaskAPI.Controllers
{
    [ApiController]
    [Route("api/employee")]
    [Authorize]
    public class EmployeeController : ControllerBase
    {
        private readonly IEmployeeService _employeeService;

        public EmployeeController(IEmployeeService employeeService)
        {
            _employeeService = employeeService;
        }

        [HttpGet("all")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<IEnumerable<EmployeeDto>>> GetAllEmployees()
        {
            var employees = await _employeeService.GetAllEmployeesAsync();
            return Ok(employees);
        }

        [HttpGet("{employeeId}")]
        public async Task<ActionResult<EmployeeDto>> GetEmployeeById(int employeeId)
        {
            var employee = await _employeeService.GetEmployeeByIdAsync(employeeId);
            
            if (employee == null)
            {
                return NotFound();
            }

            return Ok(employee);
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<EmployeeDto>> CreateEmployee([FromBody] EmployeeDto employee)
        {
            try
            {
                var createdEmployee = await _employeeService.CreateEmployeeAsync(employee);
                return CreatedAtAction(nameof(GetEmployeeById), new { employeeId = createdEmployee.EmployeeId }, createdEmployee);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("{employeeId}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<EmployeeDto>> UpdateEmployee(int employeeId, [FromBody] EmployeeDto employee)
        {
            try
            {
                var updatedEmployee = await _employeeService.UpdateEmployeeAsync(employeeId, employee);
                return Ok(updatedEmployee);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpDelete("{employeeId}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> DeleteEmployee(int employeeId)
        {
            var result = await _employeeService.DeleteEmployeeAsync(employeeId);
            
            if (!result)
            {
                return NotFound();
            }

            return NoContent();
        }
    }
}