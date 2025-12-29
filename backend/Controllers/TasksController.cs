using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MarketingTaskAPI.Data;
using MarketingTaskAPI.Models;
using MarketingTaskAPI.Services;
using System.Security.Claims;
using System.Text.Json;

namespace MarketingTaskAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TasksController : ControllerBase
    {
        private readonly ITaskService _taskService;

        public TasksController(ITaskService taskService)
        {
            _taskService = taskService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] string? status = null, [FromQuery] int? employeeId = null)
        {
            try
            {
                IEnumerable<TaskDto> tasks;
                
                if (employeeId.HasValue)
                {
                    tasks = await _taskService.GetTasksByEmployeeAsync(employeeId.Value);
                }
                else
                {
                    tasks = await _taskService.GetAllTasksAsync();
                }

                // Filter by status if provided
                if (!string.IsNullOrWhiteSpace(status))
                {
                    tasks = tasks.Where(t => t.Status?.Equals(status, StringComparison.OrdinalIgnoreCase) == true);
                }

                var result = tasks.Select(t => new {
                    t.TaskId,
                    t.Description,
                    t.Status,
                    t.Priority,
                    t.EmployeeId,
                    t.EmployeeName,
                    t.EmployeeContact,
                    t.EmployeeDesignation,
                    Employee = new { 
                        EmployeeId = t.EmployeeId, 
                        Name = t.EmployeeName, 
                        Designation = t.EmployeeDesignation, 
                        Contact = t.EmployeeContact,
                        EmployeeCode = string.Empty // Will be populated from additional data if needed
                    },
                    t.LocationId,
                    t.LocationName,
                    Location = t.LocationId.HasValue ? new { 
                        LocationId = t.LocationId.Value, 
                        LocationName = t.LocationName
                    } : null,
                    t.CustomLocation,
                    t.TaskDate,
                    t.Deadline,
                    TaskType = string.Empty, // Will be populated from additional data if needed
                    Department = string.Empty, // Will be populated from additional data if needed
                    ClientName = string.Empty, // Will be populated from additional data if needed
                    ProjectCode = string.Empty, // Will be populated from additional data if needed
                    EstimatedHours = (decimal?)null, // Will be populated from additional data if needed
                    ActualHours = (decimal?)null, // Will be populated from additional data if needed
                    TaskCategory = string.Empty, // Will be populated from additional data if needed
                    t.AdditionalNotes,
                    IsUrgent = false, // Will be populated from additional data if needed
                    t.CreatedAt,
                    t.UpdatedAt,
                    t.AssignedByUserId,
                    t.AssignedByUserName,
                    EmployeeCode = string.Empty, // Will be populated from additional data if needed
                    StateId = (int?)null, // Will be populated from additional data if needed
                    StateName = string.Empty, // Will be populated from additional data if needed
                    CityId = (int?)null, // Will be populated from additional data if needed
                    CityName = string.Empty, // Will be populated from additional data if needed
                    AreaId = (int?)null, // Will be populated from additional data if needed
                    AreaName = string.Empty, // Will be populated from additional data if needed
                    PincodeId = (int?)null, // Will be populated from additional data if needed
                    PincodeValue = string.Empty, // Will be populated from additional data if needed
                    LocalityName = string.Empty, // Will be populated from additional data if needed
                    ConsultantFeedback = t.AdditionalNotes ?? string.Empty,
                    TaskTypes = new List<object>(), // Will be populated from additional data if needed
                    Locations = new List<object>() // Will be populated from additional data if needed
                }).ToList();

                return Ok(result);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERROR] /api/tasks: {ex.Message}\n{ex.StackTrace}");
                return Ok(new List<object>());
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            try
            {
                var task = await _taskService.GetTaskByIdAsync(id);

                if (task == null)
                {
                    return NotFound();
                }

                var result = new {
                    task.TaskId,
                    task.Description,
                    task.Status,
                    task.Priority,
                    task.EmployeeId,
                    task.EmployeeName,
                    task.EmployeeContact,
                    task.EmployeeDesignation,
                    Employee = new { 
                        EmployeeId = task.EmployeeId, 
                        Name = task.EmployeeName, 
                        Designation = task.EmployeeDesignation, 
                        Contact = task.EmployeeContact,
                        EmployeeCode = string.Empty
                    },
                    task.LocationId,
                    task.LocationName,
                    Location = task.LocationId.HasValue ? new { 
                        LocationId = task.LocationId.Value, 
                        LocationName = task.LocationName
                    } : null,
                    task.CustomLocation,
                    task.TaskDate,
                    task.Deadline,
                    TaskType = string.Empty,
                    Department = string.Empty,
                    ClientName = string.Empty,
                    ProjectCode = string.Empty,
                    EstimatedHours = (decimal?)null,
                    ActualHours = (decimal?)null,
                    TaskCategory = string.Empty,
                    task.AdditionalNotes,
                    IsUrgent = false,
                    task.CreatedAt,
                    task.UpdatedAt,
                    task.AssignedByUserId,
                    task.AssignedByUserName,
                    EmployeeCode = string.Empty,
                    StateId = (int?)null,
                    StateName = string.Empty,
                    CityId = (int?)null,
                    CityName = string.Empty,
                    AreaId = (int?)null,
                    AreaName = string.Empty,
                    PincodeId = (int?)null,
                    PincodeValue = string.Empty,
                    LocalityName = string.Empty,
                    ConsultantFeedback = task.AdditionalNotes ?? string.Empty,
                    TaskTypes = new List<object>(),
                    Locations = new List<object>(),
                    StatusHistory = new List<object>()
                };

                return Ok(result);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERROR] /api/tasks/{id}: {ex.Message}\n{ex.StackTrace}");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] TaskCreateDto taskDto)
        {
            try
            {
                Console.WriteLine($"[INFO] Received task creation request: EmployeeId={taskDto.EmployeeId}, Description={taskDto.Description}, Priority={taskDto.Priority}");
                
                // Validate required fields
                if (string.IsNullOrWhiteSpace(taskDto.Description))
                {
                    Console.WriteLine("[ERROR] Description is required but was empty");
                    return BadRequest(new { error = "Description is required" });
                }

                if (string.IsNullOrWhiteSpace(taskDto.Priority))
                {
                    Console.WriteLine("[ERROR] Priority is required but was empty");
                    return BadRequest(new { error = "Priority is required" });
                }

                // Handle date conversion
                DateTime taskDate;
                DateTime deadline;
                
                if (taskDto.TaskDate is string taskDateStr)
                {
                    if (DateTime.TryParse(taskDateStr, out DateTime parsedTaskDate))
                    {
                        taskDate = parsedTaskDate;
                    }
                    else
                    {
                        taskDate = DateTime.UtcNow;
                    }
                }
                else if (taskDto.TaskDate is JsonElement jsonElement)
                {
                    if (jsonElement.TryGetDateTime(out DateTime parsedDate))
                    {
                        taskDate = parsedDate;
                    }
                    else if (DateTime.TryParse(jsonElement.GetString(), out DateTime stringDate))
                    {
                        taskDate = stringDate;
                    }
                    else
                    {
                        taskDate = DateTime.UtcNow;
                    }
                }
                else
                {
                    taskDate = (DateTime)taskDto.TaskDate;
                }
                
                if (taskDto.Deadline is string deadlineStr)
                {
                    if (DateTime.TryParse(deadlineStr, out DateTime parsedDeadline))
                    {
                        deadline = parsedDeadline;
                    }
                    else
                    {
                        deadline = DateTime.UtcNow.AddDays(7);
                    }
                }
                else if (taskDto.Deadline is JsonElement deadlineJsonElement)
                {
                    if (deadlineJsonElement.TryGetDateTime(out DateTime parsedDeadline))
                    {
                        deadline = parsedDeadline;
                    }
                    else if (DateTime.TryParse(deadlineJsonElement.GetString(), out DateTime stringDeadline))
                    {
                        deadline = stringDeadline;
                    }
                    else
                    {
                        deadline = DateTime.UtcNow.AddDays(7);
                    }
                }
                else
                {
                    deadline = (DateTime)taskDto.Deadline;
                }

                // Create CreateTaskRequest for the service
                // Centralized logging for all fields
                Console.WriteLine($"CREATE TASK DTO: " + JsonSerializer.Serialize(taskDto));
                
                // Validate at least some location data is provided
                if (taskDto.StateId == null && taskDto.CityId == null && string.IsNullOrWhiteSpace(taskDto.CustomLocation))
                {
                    Console.WriteLine("[WARNING] No location specified, using default");
                }


                var createRequest = new CreateTaskRequest
                {
                    EmployeeId = taskDto.EmployeeId,
                    LocationId = taskDto.LocationId,
                    CustomLocation = taskDto.CustomLocation,
                    Description = taskDto.Description.Trim(),
                    Priority = taskDto.Priority.Trim(),
                    TaskDate = taskDate,
                    Deadline = deadline,
                    TaskType = taskDto.TaskType ?? "General",
                    Department = taskDto.Department ?? "Marketing",
                    TaskCategory = taskDto.TaskCategory ?? "Field Work",
                    AdditionalNotes = taskDto.AdditionalNotes,
                    IsUrgent = taskDto.IsUrgent ?? false,
                    EstimatedHours = taskDto.EstimatedHours,

                    // Location hierarchy
                    StateId = taskDto.StateId,
                    CityId = taskDto.CityId,
                    AreaId = taskDto.AreaId,
                    PincodeId = taskDto.PincodeId,
                    PincodeValue = taskDto.PincodeValue ?? taskDto.Pincode,
                    // Ensure non-null strings for stored procedure
                    Pincode = string.IsNullOrWhiteSpace(taskDto.PincodeValue) ? (taskDto.Pincode ?? "000000") : taskDto.PincodeValue,
                    LocalityName = string.IsNullOrWhiteSpace(taskDto.LocalityName) ? (taskDto.AreaName ?? "UnknownArea") : taskDto.LocalityName
                };


                var createdTask = await _taskService.CreateTaskAsync(createRequest, 1);
                
                if (createdTask == null || createdTask.TaskId == 0)
                {
                    Console.WriteLine("[ERROR] Task creation returned null or invalid TaskId");
                    return StatusCode(500, new { error = "Task creation failed", success = false });
                }

                Console.WriteLine($"[INFO] Task created successfully with ID: {createdTask.TaskId}");

                // Return simple success response to avoid serialization issues
                return Ok(new { 
                    taskId = createdTask.TaskId,
                    success = true,
                    message = "Task created successfully"
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERROR] POST /api/tasks: {ex.Message}\n{ex.StackTrace}");
                if (ex.InnerException != null)
                {
                    Console.WriteLine($"[ERROR] Inner exception: {ex.InnerException.Message}");
                }
                return StatusCode(500, new { error = "Internal server error", details = ex.Message, innerException = ex.InnerException?.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] TaskUpdateDto taskDto)
        {
            try
            {
                Console.WriteLine($"[INFO] Updating task {id}");

                // Validate required fields
                if (string.IsNullOrWhiteSpace(taskDto.Description))
                {
                    return BadRequest(new { error = "Description is required" });
                }

                if (string.IsNullOrWhiteSpace(taskDto.Priority))
                {
                    return BadRequest(new { error = "Priority is required" });
                }

                // Handle date conversion
                DateTime taskDate;
                DateTime deadline;
                
                if (taskDto.TaskDate is string taskDateStr)
                {
                    if (DateTime.TryParse(taskDateStr, out DateTime parsedTaskDate))
                    {
                        taskDate = parsedTaskDate;
                    }
                    else
                    {
                        taskDate = DateTime.UtcNow;
                    }
                }
                else
                {
                    taskDate = (DateTime)taskDto.TaskDate;
                }
                
                if (taskDto.Deadline is string deadlineStr)
                {
                    if (DateTime.TryParse(deadlineStr, out DateTime parsedDeadline))
                    {
                        deadline = parsedDeadline;
                    }
                    else
                    {
                        deadline = DateTime.UtcNow.AddDays(7);
                    }
                }
                else
                {
                    deadline = (DateTime)taskDto.Deadline;
                }

                // Create UpdateTaskRequest for the service
                var updateRequest = new UpdateTaskRequest
                {
                    EmployeeId = taskDto.EmployeeId ?? 1,
                    LocationId = taskDto.LocationId,
                    CustomLocation = taskDto.CustomLocation,
                    Description = taskDto.Description.Trim(),
                    Priority = taskDto.Priority.Trim(),
                    TaskDate = taskDate,
                    Deadline = deadline,
                    Status = taskDto.Status
                };

                var updatedTask = await _taskService.UpdateTaskAsync(id, updateRequest, 1);
                if (updatedTask == null)
                {
                    Console.WriteLine($"[ERROR] Task {id} not found");
                    return NotFound(new { error = "Task not found" });
                }

                Console.WriteLine($"[INFO] Task {id} updated successfully");
                return Ok(new { TaskId = id, Success = true });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERROR] PUT /api/tasks/{id}: {ex.Message}\n{ex.StackTrace}");
                return StatusCode(500, new { error = "Internal server error", details = ex.Message });
            }
        }

        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateStatus(int id, [FromBody] TaskStatusUpdateDto statusUpdate)
        {
            try
            {
                Console.WriteLine($"[INFO] Updating status for task {id} to {statusUpdate.Status}");

                var task = await _taskService.GetTaskByIdAsync(id);
                if (task == null)
                {
                    Console.WriteLine($"[ERROR] Task {id} not found");
                    return NotFound(new { error = "Task not found" });
                }

                var statusUpdateRequest = new UpdateTaskStatusRequest
                {
                    Status = statusUpdate.Status,
                    Remarks = statusUpdate.Remarks ?? $"Status updated to {statusUpdate.Status}"
                };

                var updatedTask = await _taskService.UpdateTaskStatusAsync(id, statusUpdateRequest, 1);
                if (updatedTask == null)
                {
                    Console.WriteLine($"[ERROR] Failed to update task {id}");
                    return NotFound(new { error = "Task not found" });
                }

                Console.WriteLine($"[INFO] Task {id} status updated successfully to {statusUpdate.Status}");

                // Return the updated task in the same format as the frontend expects
                var result = new {
                    updatedTask.TaskId,
                    updatedTask.Description,
                    updatedTask.Status,
                    updatedTask.Priority,
                    updatedTask.EmployeeId,
                    updatedTask.EmployeeName,
                    updatedTask.EmployeeContact,
                    updatedTask.EmployeeDesignation,
                    updatedTask.LocationId,
                    updatedTask.LocationName,
                    updatedTask.CustomLocation,
                    updatedTask.TaskDate,
                    updatedTask.Deadline,
                    updatedTask.AdditionalNotes,
                    updatedTask.CreatedAt,
                    updatedTask.UpdatedAt,
                    updatedTask.AssignedByUserId,
                    updatedTask.AssignedByUserName
                };

                return Ok(result);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERROR] PUT /api/tasks/{id}/status: {ex.Message}\n{ex.StackTrace}");
                if (ex.InnerException != null)
                {
                    Console.WriteLine($"[ERROR] Inner exception: {ex.InnerException.Message}\n{ex.InnerException.StackTrace}");
                }
                return StatusCode(500, new { error = "Internal server error", details = ex.Message, innerException = ex.InnerException?.Message });
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                var success = await _taskService.DeleteTaskAsync(id);
                if (!success)
                {
                    return NotFound();
                }

                return Ok();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERROR] DELETE /api/tasks/{id}: {ex.Message}\n{ex.StackTrace}");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPut("{id}/reschedule")]
        public async Task<IActionResult> RescheduleTask(int id, [FromBody] TaskRescheduleRequest rescheduleRequest)
        {
            try
            {
                Console.WriteLine($"[INFO] Rescheduling task {id}");
                Console.WriteLine($"[INFO] New Task Date: {rescheduleRequest.NewTaskDate}, New Deadline: {rescheduleRequest.NewDeadline}");
                Console.WriteLine($"[INFO] Reason: {rescheduleRequest.RescheduleReason}");

                // Validate request
                if (rescheduleRequest.NewDeadline <= rescheduleRequest.NewTaskDate)
                {
                    return BadRequest(new { error = "Deadline must be after task date" });
                }

                var task = await _taskService.GetTaskByIdAsync(id);
                if (task == null)
                {
                    Console.WriteLine($"[ERROR] Task {id} not found");
                    return NotFound(new { error = "Task not found" });
                }

                // Call the reschedule service method
                var updatedTask = await _taskService.RescheduleTaskAsync(id, 1, rescheduleRequest);
                if (updatedTask == null)
                {
                    Console.WriteLine($"[ERROR] Failed to reschedule task {id}");
                    return NotFound(new { error = "Task not found" });
                }

                Console.WriteLine($"[INFO] Task {id} rescheduled successfully");

                // Return the updated task
                var result = new {
                    updatedTask.TaskId,
                    updatedTask.Description,
                    updatedTask.Status,
                    updatedTask.Priority,
                    updatedTask.EmployeeId,
                    updatedTask.EmployeeName,
                    updatedTask.EmployeeContact,
                    updatedTask.EmployeeDesignation,
                    updatedTask.LocationId,
                    updatedTask.LocationName,
                    updatedTask.CustomLocation,
                    updatedTask.TaskDate,
                    updatedTask.Deadline,
                    updatedTask.AdditionalNotes,
                    updatedTask.CreatedAt,
                    updatedTask.UpdatedAt,
                    updatedTask.AssignedByUserId,
                    updatedTask.AssignedByUserName
                };

                return Ok(result);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERROR] PUT /api/tasks/{id}/reschedule: {ex.Message}\n{ex.StackTrace}");
                if (ex.InnerException != null)
                {
                    Console.WriteLine($"[ERROR] Inner exception: {ex.InnerException.Message}\n{ex.InnerException.StackTrace}");
                }
                return StatusCode(500, new { error = "Internal server error", details = ex.Message, innerException = ex.InnerException?.Message });
            }
        }
    }

    // DTOs for task creation and update
    public class TaskCreateDto
    {
        public int EmployeeId { get; set; }
        public int? LocationId { get; set; }
        public string? CustomLocation { get; set; }
        public string Description { get; set; } = string.Empty;
        public string Priority { get; set; } = string.Empty;
        public object TaskDate { get; set; } = DateTime.UtcNow; // Allow both DateTime and string
        public object Deadline { get; set; } = DateTime.UtcNow.AddDays(7); // Allow both DateTime and string
        public string? TaskType { get; set; }
        public string? Department { get; set; }
        public string? ClientName { get; set; }
        public string? ProjectCode { get; set; }
        public decimal? EstimatedHours { get; set; }
        public decimal? ActualHours { get; set; }
        public string? TaskCategory { get; set; }
        public string? ConsultantFeedback { get; set; }
        public bool? IsUrgent { get; set; }
        public string? EmployeeCode { get; set; }
        public int? StateId { get; set; }
        public int? CityId { get; set; }
        public int? AreaId { get; set; }
        public int? PincodeId { get; set; }
        public string? PincodeValue { get; set; }
        public string? Pincode { get; set; } // Support both field names
        public string? LocalityName { get; set; }
        public string? StateName { get; set; }
        public string? CityName { get; set; }
        public string? AreaName { get; set; }
        public string? AdditionalNotes { get; set; }
        public List<int> TaskTypeIds { get; set; } = new List<int>();
        public List<int> LocationIds { get; set; } = new List<int>();
    }

    public class TaskUpdateDto
    {
        public int? EmployeeId { get; set; }
        public int? LocationId { get; set; }
        public string? CustomLocation { get; set; }
        public string Description { get; set; } = string.Empty;
        public string Priority { get; set; } = string.Empty;
        public object TaskDate { get; set; } = DateTime.UtcNow; // Allow both DateTime and string
        public object Deadline { get; set; } = DateTime.UtcNow.AddDays(7); // Allow both DateTime and string
        public string Status { get; set; } = string.Empty;
        public string? TaskType { get; set; }
        public string? Department { get; set; }
        public string? ClientName { get; set; }
        public string? ProjectCode { get; set; }
        public decimal? EstimatedHours { get; set; }
        public decimal? ActualHours { get; set; }
        public string? TaskCategory { get; set; }
        public string? ConsultantFeedback { get; set; }
        public bool? IsUrgent { get; set; }
        public string? EmployeeCode { get; set; }
        public int? StateId { get; set; }
        public int? CityId { get; set; }
        public int? AreaId { get; set; }
        public int? PincodeId { get; set; }
        public string? PincodeValue { get; set; }
        public string? Pincode { get; set; } // Support both field names
        public string? LocalityName { get; set; }
        public string? StateName { get; set; }
        public string? CityName { get; set; }
        public string? AreaName { get; set; }
        public string? AdditionalNotes { get; set; }
        public List<int> TaskTypeIds { get; set; } = new List<int>();
        public List<int> LocationIds { get; set; } = new List<int>();
    }

    public class TaskStatusUpdateDto
    {
        public string Status { get; set; } = string.Empty;
        public string? Remarks { get; set; }
    }
}
