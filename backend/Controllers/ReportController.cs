using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using MarketingTaskAPI.Services;
using MarketingTaskAPI.Models;

namespace MarketingTaskAPI.Controllers
{
    [ApiController]
    [Route("api/reports")]
    [Authorize]
    public class ReportController : ControllerBase
    {
        private readonly IEmployeeService _employeeService;
        private readonly ITaskService _taskService;

        public ReportController(IEmployeeService employeeService, ITaskService taskService)
        {
            _employeeService = employeeService;
            _taskService = taskService;
        }

        [HttpGet("employee-summary")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<IEnumerable<EmployeeSummaryDto>>> GetEmployeeSummary()
        {
            var summary = await _employeeService.GetEmployeeSummaryAsync();
            return Ok(summary);
        }

        [HttpGet("high-priority-tasks")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<IEnumerable<HighPriorityTaskDto>>> GetHighPriorityTasks()
        {
            var tasks = await _taskService.GetHighPriorityTasksAsync();
            return Ok(tasks);
        }

        [HttpGet("tasks-by-department/{department}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<IEnumerable<TaskDto>>> GetTasksByDepartment(string department)
        {
            var tasks = await _taskService.GetTasksByDepartmentAsync(department);
            return Ok(tasks);
        }

        [HttpGet("task-status-history/{employeeName}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<IEnumerable<TaskStatusHistoryDto>>> GetTaskStatusHistoryByEmployee(string employeeName)
        {
            var history = await _taskService.GetTaskStatusHistoryByEmployeeAsync(employeeName);
            return Ok(history);
        }
    }
}
