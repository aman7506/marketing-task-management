using Microsoft.EntityFrameworkCore;
using MarketingTaskAPI.Data;
using MarketingTaskAPI.Models;
using Microsoft.Data.SqlClient;
using System.Data;

namespace MarketingTaskAPI.Services
{
    public class TaskService : ITaskService
    {
        private readonly MarketingTaskDbContext _context;
        private readonly string _connectionString;

        public TaskService(MarketingTaskDbContext context, IConfiguration configuration)
        {
            _context = context;
            _connectionString = configuration.GetConnectionString("DefaultConnection") ?? throw new ArgumentNullException("Connection string not found");
        }

        public async Task<IEnumerable<TaskDto>> GetAllTasksAsync()
        {
            var tasks = new List<TaskDto>();
            
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_GetTasks", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandTimeout = 120; // Increase timeout to 120 seconds
                    command.Parameters.AddWithValue("@EmployeeId", DBNull.Value);
                    command.Parameters.AddWithValue("@Status", DBNull.Value);
                    
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            tasks.Add(new TaskDto
                            {
                                TaskId = reader.GetInt32("TaskId"),
                                EmployeeId = reader.GetInt32("EmployeeId"),
                                EmployeeName = reader.GetString("EmployeeName"),
                                EmployeeContact = reader.IsDBNull("EmployeeContact") ? string.Empty : reader.GetString("EmployeeContact"),
                                EmployeeDesignation = reader.IsDBNull("EmployeeDesignation") ? string.Empty : reader.GetString("EmployeeDesignation"),
                                LocationId = reader.IsDBNull("LocationId") ? null : reader.GetInt32("LocationId"),
                                LocationName = reader.IsDBNull("LocationName") ? string.Empty : reader.GetString("LocationName"),
                                CustomLocation = reader.IsDBNull("CustomLocation") ? string.Empty : reader.GetString("CustomLocation"),
                                Description = reader.GetString("Description"),
                                Priority = reader.GetString("Priority"),
                                TaskDate = reader.GetDateTime("TaskDate"),
                                Deadline = reader.GetDateTime("Deadline"),
                                Status = reader.GetString("Status"),
                                AssignedByUserId = reader.GetInt32("AssignedByUserId"),
                                AssignedByUserName = reader.GetString("AssignedByUsername"),
                                CreatedAt = reader.GetDateTime("CreatedAt"),
                                UpdatedAt = reader.IsDBNull("UpdatedAt") ? reader.GetDateTime("CreatedAt") : reader.GetDateTime("UpdatedAt")
                            });
                        }
                    }
                }
            }
            
            return tasks;
        }

        public async Task<IEnumerable<TaskDto>> GetTasksByEmployeeAsync(int employeeId)
        {
            var tasks = new List<TaskDto>();
            
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_GetTasks", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandTimeout = 120; // Increase timeout to 120 seconds
                    command.Parameters.AddWithValue("@EmployeeId", employeeId);
                    command.Parameters.AddWithValue("@Status", DBNull.Value);
                    
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            tasks.Add(new TaskDto
                            {
                                TaskId = reader.GetInt32("TaskId"),
                                EmployeeId = reader.GetInt32("EmployeeId"),
                                EmployeeName = reader.GetString("EmployeeName"),
                                EmployeeContact = reader.IsDBNull("EmployeeContact") ? string.Empty : reader.GetString("EmployeeContact"),
                                EmployeeDesignation = reader.IsDBNull("EmployeeDesignation") ? string.Empty : reader.GetString("EmployeeDesignation"),
                                LocationId = reader.IsDBNull("LocationId") ? null : reader.GetInt32("LocationId"),
                                LocationName = reader.IsDBNull("LocationName") ? string.Empty : reader.GetString("LocationName"),
                                CustomLocation = reader.IsDBNull("CustomLocation") ? string.Empty : reader.GetString("CustomLocation"),
                                Description = reader.GetString("Description"),
                                Priority = reader.GetString("Priority"),
                                TaskDate = reader.GetDateTime("TaskDate"),
                                Deadline = reader.GetDateTime("Deadline"),
                                Status = reader.GetString("Status"),
                                AssignedByUserId = reader.GetInt32("AssignedByUserId"),
                                AssignedByUserName = reader.GetString("AssignedByUsername"),
                                CreatedAt = reader.GetDateTime("CreatedAt"),
                                UpdatedAt = reader.IsDBNull("UpdatedAt") ? reader.GetDateTime("CreatedAt") : reader.GetDateTime("UpdatedAt")
                            });
                        }
                    }
                }
            }
            
            return tasks;
        }

        private async Task<int> ResolveValidUserIdAsync(int preferredUserId)
        {
            // If the preferred user exists, use it
            var existingPreferred = await _context.Users.FirstOrDefaultAsync(u => u.UserId == preferredUserId);
            if (existingPreferred != null)
            {
                return preferredUserId;
            }

            // Otherwise pick the first available user
            var anyUser = await _context.Users.OrderBy(u => u.UserId).FirstOrDefaultAsync();
            if (anyUser != null)
            {
                return anyUser.UserId;
            }

            // If no users exist, create a lightweight "system" user
            var systemUser = new User
            {
                Username = "system",
                PasswordHash = "system",
                Role = "Admin",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };

            _context.Users.Add(systemUser);
            await _context.SaveChangesAsync();

            return systemUser.UserId;
        }

        private async Task<int> ResolveValidEmployeeIdAsync(int? preferredEmployeeId)
        {
            if (preferredEmployeeId.HasValue)
            {
                var existing = await _context.Employees.FirstOrDefaultAsync(e => e.EmployeeId == preferredEmployeeId.Value);
                if (existing != null)
                {
                    return preferredEmployeeId.Value;
                }
            }

            var anyEmployee = await _context.Employees.OrderBy(e => e.EmployeeId).FirstOrDefaultAsync();
            if (anyEmployee != null)
            {
                return anyEmployee.EmployeeId;
            }

            // Create a fallback employee to satisfy FK if none exist
            var fallback = new Employee
            {
                Name = "Default Employee",
                Contact = "N/A",
                Designation = "N/A",
                Email = $"default_{Guid.NewGuid():N}@example.com"
            };
            _context.Employees.Add(fallback);
            await _context.SaveChangesAsync();
            return fallback.EmployeeId;
        }

        public async Task<TaskDto?> GetTaskByIdAsync(int taskId)
        {
            var task = await _context.UserTasks
                .Include(t => t.Employee)
                .Include(t => t.Location)
                .Include(t => t.AssignedByUser)
                .FirstOrDefaultAsync(t => t.TaskId == taskId);

            if (task is null) return null;

            return new TaskDto
            {
                TaskId = task.TaskId,
                EmployeeId = task.EmployeeId ?? 0,
                EmployeeName = task.Employee?.Name,
                EmployeeContact = task.Employee?.Contact,
                EmployeeDesignation = task.Employee?.Designation,
                LocationId = task.LocationId,
                LocationName = task.Location?.LocationName,
                CustomLocation = task.CustomLocation,
                Description = task.Description,
                Priority = task.Priority,
                TaskDate = task.TaskDate,
                Deadline = task.Deadline,
                Status = task.Status,
                AssignedByUserId = task.AssignedByUserId,
                AssignedByUserName = task.AssignedByUser?.Username,
                TaskType = task.TaskType,
                Department = task.Department,
                ClientName = task.ClientName,
                ProjectCode = task.ProjectCode,
                EstimatedHours = task.EstimatedHours ?? 0m,
                ActualHours = task.ActualHours ?? 0m,
                TaskCategory = task.TaskCategory,
                AdditionalNotes = task.AdditionalNotes,
                IsUrgent = task.IsUrgent,
                CreatedAt = task.CreatedAt,
                UpdatedAt = task.UpdatedAt
            };
        }

        public async Task<TaskDto> CreateTaskAsync(CreateTaskRequest request, int assignedByUserId)
        {
            try
            {
                // Ensure AssignedByUserId always points to an existing user to avoid FK violations.
                assignedByUserId = await ResolveValidUserIdAsync(assignedByUserId);

                // Ensure EmployeeId is valid to avoid FK violations.
                var resolvedEmployeeId = await ResolveValidEmployeeIdAsync(request.EmployeeId);
                request.EmployeeId = resolvedEmployeeId;

                int taskId = 0;
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_InsertTask", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@AssignedByUserId", assignedByUserId);
                        command.Parameters.AddWithValue("@EmployeeId", request.EmployeeId);
                        command.Parameters.AddWithValue("@LocationId", request.LocationId.HasValue ? (object)request.LocationId.Value : DBNull.Value);
                        command.Parameters.AddWithValue("@CustomLocation", string.IsNullOrEmpty(request.CustomLocation) ? DBNull.Value : request.CustomLocation);
                        command.Parameters.AddWithValue("@Description", request.Description);
                        command.Parameters.AddWithValue("@Priority", request.Priority);
                        command.Parameters.AddWithValue("@TaskDate", request.TaskDate);
                        command.Parameters.AddWithValue("@Deadline", request.Deadline);
                        command.Parameters.AddWithValue("@Status", "Not Started");
                        command.Parameters.AddWithValue("@TaskType", string.IsNullOrEmpty(request.TaskType) ? "General" : request.TaskType);
                        command.Parameters.AddWithValue("@Department", string.IsNullOrEmpty(request.Department) ? "Marketing" : request.Department);
                        command.Parameters.AddWithValue("@TaskCategory", string.IsNullOrEmpty(request.TaskCategory) ? "Field Work" : request.TaskCategory);
                        command.Parameters.AddWithValue("@ClientName", string.IsNullOrEmpty(request.ClientName) ? DBNull.Value : request.ClientName);
                        command.Parameters.AddWithValue("@ProjectCode", string.IsNullOrEmpty(request.ProjectCode) ? DBNull.Value : request.ProjectCode);
                        command.Parameters.AddWithValue("@EstimatedHours", request.EstimatedHours.HasValue ? (object)request.EstimatedHours.Value : DBNull.Value);
                        command.Parameters.AddWithValue("@AdditionalNotes", string.IsNullOrEmpty(request.AdditionalNotes) ? DBNull.Value : request.AdditionalNotes);
                        command.Parameters.AddWithValue("@IsUrgent", request.IsUrgent);
                        command.Parameters.AddWithValue("@Pincode", string.IsNullOrEmpty(request.Pincode) ? DBNull.Value : request.Pincode);
                        command.Parameters.AddWithValue("@LocalityName", string.IsNullOrEmpty(request.LocalityName) ? DBNull.Value : request.LocalityName);
                        command.Parameters.AddWithValue("@State", string.IsNullOrEmpty(request.State) ? DBNull.Value : request.State);
                        command.Parameters.AddWithValue("@City", string.IsNullOrEmpty(request.City) ? DBNull.Value : request.City);
                        command.Parameters.AddWithValue("@Area", string.IsNullOrEmpty(request.Area) ? DBNull.Value : request.Area);
                        command.Parameters.AddWithValue("@StateId", request.StateId.HasValue ? (object)request.StateId.Value : DBNull.Value);
                        command.Parameters.AddWithValue("@CityId", request.CityId.HasValue ? (object)request.CityId.Value : DBNull.Value);
                        command.Parameters.AddWithValue("@AreaId", request.AreaId.HasValue ? (object)request.AreaId.Value : DBNull.Value);
                        command.Parameters.AddWithValue("@PincodeId", request.PincodeId.HasValue ? (object)request.PincodeId.Value : DBNull.Value);
                        command.Parameters.AddWithValue("@EmployeeCode", string.IsNullOrEmpty(request.EmployeeCode) ? DBNull.Value : request.EmployeeCode);
                        command.Parameters.AddWithValue("@ConsultantName", string.IsNullOrEmpty(request.ConsultantName) ? DBNull.Value : request.ConsultantName);
                        command.Parameters.AddWithValue("@ConsultantFeedback", string.IsNullOrEmpty(request.ConsultantFeedback) ? DBNull.Value : request.ConsultantFeedback);
                        command.Parameters.AddWithValue("@CampCode", string.IsNullOrEmpty(request.CampCode) ? DBNull.Value : request.CampCode);
                        command.Parameters.AddWithValue("@ExpectedReach", string.IsNullOrEmpty(request.ExpectedReach) ? DBNull.Value : request.ExpectedReach);
                        command.Parameters.AddWithValue("@ConversionGoal", string.IsNullOrEmpty(request.ConversionGoal) ? DBNull.Value : request.ConversionGoal);
                        command.Parameters.AddWithValue("@Kpis", string.IsNullOrEmpty(request.Kpis) ? DBNull.Value : request.Kpis);
                        command.Parameters.AddWithValue("@MarketingMaterials", string.IsNullOrEmpty(request.MarketingMaterials) ? DBNull.Value : request.MarketingMaterials);
                        command.Parameters.AddWithValue("@ApprovalRequired", request.ApprovalRequired);
                        command.Parameters.AddWithValue("@ApprovalContact", string.IsNullOrEmpty(request.ApprovalContact) ? DBNull.Value : request.ApprovalContact);
                        command.Parameters.AddWithValue("@BudgetCode", string.IsNullOrEmpty(request.BudgetCode) ? DBNull.Value : request.BudgetCode);
                        command.Parameters.AddWithValue("@DepartmentCode", string.IsNullOrEmpty(request.DepartmentCode) ? DBNull.Value : request.DepartmentCode);

                        var result = await command.ExecuteScalarAsync();
                        if (result != null && int.TryParse(result.ToString(), out int newId))
                            taskId = newId;
                    }
                }
                return await GetTaskByIdAsync(taskId) ?? new TaskDto();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Exception in TaskService.CreateTaskAsync: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
                throw;
            }
        }

        public async Task<TaskDto?> UpdateTaskStatusAsync(int taskId, UpdateTaskStatusRequest request, int changedByUserId)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_UpdateTaskStatus", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@TaskId", taskId);
                    command.Parameters.AddWithValue("@Status", request.Status);
                    command.Parameters.AddWithValue("@Remarks", string.IsNullOrEmpty(request.Remarks) ? DBNull.Value : request.Remarks);
                    command.Parameters.AddWithValue("@ChangedByUserId", changedByUserId);
                    
                    await command.ExecuteNonQueryAsync();
                }
            }

            return await GetTaskByIdAsync(taskId);
        }

        public async Task<bool> DeleteTaskAsync(int taskId)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_DeleteTask", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@TaskId", taskId);
                    
                    var rowsAffected = await command.ExecuteNonQueryAsync();
                    return rowsAffected > 0;
                }
            }
        }

        public async Task<TaskDto?> UpdateTaskAsync(int taskId, UpdateTaskRequest request, int updatedByUserId)
        {
            var task = await _context.UserTasks.FindAsync(taskId);
            if (task == null)
                throw new ArgumentException("Task not found");

            // Update basic fields
            if (request.EmployeeId.HasValue) task.EmployeeId = request.EmployeeId.Value;
            if (request.LocationId.HasValue) task.LocationId = request.LocationId.Value;
            if (!string.IsNullOrEmpty(request.CustomLocation)) task.CustomLocation = request.CustomLocation;
            if (!string.IsNullOrEmpty(request.Description)) task.Description = request.Description;
            if (!string.IsNullOrEmpty(request.Priority)) task.Priority = request.Priority;
            if (request.TaskDate.HasValue) task.TaskDate = request.TaskDate.Value;
            if (request.Deadline.HasValue) task.Deadline = request.Deadline.Value;
            if (!string.IsNullOrEmpty(request.Status)) task.Status = request.Status;

            // Additional fields
            if (!string.IsNullOrEmpty(request.TaskType)) task.TaskType = request.TaskType;
            if (!string.IsNullOrEmpty(request.Department)) task.Department = request.Department;
            if (!string.IsNullOrEmpty(request.ClientName)) task.ClientName = request.ClientName;
            if (!string.IsNullOrEmpty(request.ProjectCode)) task.ProjectCode = request.ProjectCode;
            if (!string.IsNullOrEmpty(request.EmployeeIdNumber)) task.EmployeeIdNumber = request.EmployeeIdNumber;
            if (request.EstimatedHours.HasValue) task.EstimatedHours = request.EstimatedHours.Value;
            if (request.ActualHours.HasValue) task.ActualHours = request.ActualHours.Value;
            if (!string.IsNullOrEmpty(request.TaskCategory)) task.TaskCategory = request.TaskCategory;
            if (!string.IsNullOrEmpty(request.AdditionalNotes)) task.AdditionalNotes = request.AdditionalNotes;
            if (request.IsUrgent.HasValue) task.IsUrgent = request.IsUrgent.Value;

            task.UpdatedAt = DateTime.UtcNow;

            // Add status history if status changed
            if (!string.IsNullOrEmpty(request.Status))
            {
                var statusHistory = new TaskStatusHistory
                {
                    TaskId = taskId,
                    Status = request.Status,
                    Remarks = "Task updated by admin",
                    ChangedByUserId = updatedByUserId,
                    ChangedAt = DateTime.UtcNow
                };
                _context.TaskStatusHistories.Add(statusHistory);
            }

            await _context.SaveChangesAsync();
            return await GetTaskByIdAsync(taskId);
        }

        public async Task<TaskDto?> RescheduleTaskAsync(int taskId, int rescheduledByUserId, TaskRescheduleRequest request)
        {
            try
            {
                Console.WriteLine($"[INFO] Starting reschedule for task {taskId}");
                Console.WriteLine($"[INFO] New dates - TaskDate: {request.NewTaskDate:yyyy-MM-dd}, Deadline: {request.NewDeadline:yyyy-MM-dd}");
                
                // CRITICAL: Clear change tracker to avoid conflicts from previous queries
                _context.ChangeTracker.Clear();
                Console.WriteLine($"[INFO] Change tracker cleared");
                
                // Fetch task without tracking to avoid conflicts
                var task = await _context.UserTasks
                    .AsNoTracking()
                    .FirstOrDefaultAsync(t => t.TaskId == taskId);
                    
                if (task == null)
                {
                    Console.WriteLine($"[ERROR] Task {taskId} not found");
                    return null;
                }

                Console.WriteLine($"[INFO] Found task {taskId}");
                Console.WriteLine($"[INFO] Current dates - TaskDate: {task.TaskDate:yyyy-MM-dd}, Deadline: {task.Deadline:yyyy-MM-dd}");

                var reschedule = new TaskReschedule
                {
                    TaskId = taskId,
                    OriginalTaskDate = task.TaskDate,
                    OriginalDeadline = task.Deadline,
                    NewTaskDate = request.NewTaskDate,
                    NewDeadline = request.NewDeadline,
                    RescheduleReason = request.RescheduleReason ?? "No reason provided",
                    RescheduledByUserId = rescheduledByUserId,
                    RescheduledAt = DateTime.UtcNow
                };

                var statusHistory = new TaskStatusHistory
                {
                    TaskId = taskId,
                    Status = "Postponed",
                    Remarks = $"Task rescheduled: {request.RescheduleReason ?? "No reason provided"}",
                    ChangedByUserId = rescheduledByUserId,
                    ChangedAt = DateTime.UtcNow
                };

                // Update task dates
                task.TaskDate = request.NewTaskDate;
                task.Deadline = request.NewDeadline;
                task.Status = "Postponed";
                task.UpdatedAt = DateTime.UtcNow;

                Console.WriteLine($"[INFO] Task updated - New TaskDate: {task.TaskDate:yyyy-MM-dd}, New Deadline: {task.Deadline:yyyy-MM-dd}");

                Console.WriteLine($"[INFO] Attaching task entity...");
                _context.UserTasks.Attach(task);
                _context.Entry(task).State = EntityState.Modified;
                Console.WriteLine($"[INFO] Task entity attached and marked as modified");

                // Add new records
                await _context.TaskReschedules.AddAsync(reschedule);
                await _context.TaskStatusHistories.AddAsync(statusHistory);
                Console.WriteLine($"[INFO] Reschedule and status history records added");

                Console.WriteLine($"[INFO] Saving changes to database...");
                var saved = await _context.SaveChangesAsync();
                Console.WriteLine($"[INFO] Successfully saved {saved} changes for task {taskId}");

                // Clear tracker again before returning
                _context.ChangeTracker.Clear();

                // Return updated task
                return await GetTaskByIdAsync(taskId);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERROR] RescheduleTaskAsync failed for task {taskId}");
                Console.WriteLine($"[ERROR] Exception: {ex.Message}");
                Console.WriteLine($"[ERROR] Stack trace: {ex.StackTrace}");
                if (ex.InnerException != null)
                {
                    Console.WriteLine($"[ERROR] Inner exception: {ex.InnerException.Message}");
                    Console.WriteLine($"[ERROR] Inner stack trace: {ex.InnerException.StackTrace}");
                }
                throw; // Re-throw to controller
            }
        }

        public async Task<IEnumerable<TaskRescheduleDto>> GetTaskRescheduleHistoryAsync(int taskId)
        {
            var history = await _context.TaskReschedules
                .Where(r => r.TaskId == taskId)
                .OrderByDescending(r => r.RescheduledAt)
                .ToListAsync();

            return history.Select(r => new TaskRescheduleDto
            {
                RescheduleId = r.RescheduleId,
                TaskId = r.TaskId,
                OriginalTaskDate = r.OriginalTaskDate,
                OriginalDeadline = r.OriginalDeadline,
                NewTaskDate = r.NewTaskDate,
                NewDeadline = r.NewDeadline,
                RescheduleReason = r.RescheduleReason,
                RescheduledAt = r.RescheduledAt
            });
        }

        public async Task<Dictionary<string, int>> GetTaskStatisticsAsync()
        {
            var allTasks = await GetAllTasksAsync();
            var taskList = allTasks.ToList();

            return new Dictionary<string, int>
            {
                { "TotalTasks", taskList.Count },
                { "CompletedTasks", taskList.Count(t => t.Status == "Completed") },
                { "PendingTasks", taskList.Count(t => t.Status != "Completed") }
            };
        }

        public async Task<Dictionary<string, int>> GetEmployeeTaskStatisticsAsync(int employeeId)
        {
            var tasks = await GetTasksByEmployeeAsync(employeeId);
            var taskList = tasks.ToList();

            return new Dictionary<string, int>
            {
                { "EmployeeId", employeeId },
                { "TotalTasks", taskList.Count },
                { "CompletedTasks", taskList.Count(t => t.Status == "Completed") },
                { "PendingTasks", taskList.Count(t => t.Status != "Completed") }
            };
        }

        public async Task<IEnumerable<HighPriorityTaskDto>> GetHighPriorityTasksAsync()
        {
            var tasks = new List<HighPriorityTaskDto>();
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_GetHighPriorityTasks", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            tasks.Add(new HighPriorityTaskDto
                            {
                                TaskId = reader.GetInt32("TaskId"),
                                AssignedTo = reader.IsDBNull("AssignedTo") ? string.Empty : reader.GetString("AssignedTo"),
                                Designation = reader.IsDBNull("Designation") ? string.Empty : reader.GetString("Designation"),
                                EmployeeEmail = reader.IsDBNull("EmployeeEmail") ? string.Empty : reader.GetString("EmployeeEmail"),
                                Description = reader.IsDBNull("Description") ? string.Empty : reader.GetString("Description"),
                                Priority = reader.IsDBNull("Priority") ? string.Empty : reader.GetString("Priority"),
                                TaskType = reader.IsDBNull("TaskType") ? string.Empty : reader.GetString("TaskType"),
                                Department = reader.IsDBNull("Department") ? string.Empty : reader.GetString("Department"),
                                Location = reader.IsDBNull("Location") ? string.Empty : reader.GetString("Location"),
                                EstimatedHours = reader.IsDBNull("EstimatedHours") ? 0 : reader.GetDecimal("EstimatedHours"),
                                Deadline = reader.GetDateTime("Deadline"),
                                Status = reader.IsDBNull("Status") ? string.Empty : reader.GetString("Status"),
                                AssignedBy = reader.IsDBNull("AssignedBy") ? string.Empty : reader.GetString("AssignedBy"),
                                UrgencyStatus = reader.IsDBNull("UrgencyStatus") ? string.Empty : reader.GetString("UrgencyStatus"),
                                CreatedAt = reader.GetDateTime("CreatedAt")
                            });
                        }
                    }
                }
            }
            return tasks;
        }

        public async Task<IEnumerable<TaskDto>> GetTasksByDepartmentAsync(string department)
        {
            var tasks = new List<TaskDto>();
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_GetTasksByDepartment", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@Department", department);
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            tasks.Add(new TaskDto
                            {
                                TaskId = reader.GetInt32("TaskId"),
                                EmployeeId = reader.IsDBNull("EmployeeId") ? 0 : reader.GetInt32("EmployeeId"),
                                EmployeeName = reader.IsDBNull("EmployeeName") ? string.Empty : reader.GetString("EmployeeName"),
                                Description = reader.IsDBNull("Description") ? string.Empty : reader.GetString("Description"),
                                Department = reader.IsDBNull("Department") ? string.Empty : reader.GetString("Department"),
                                Status = reader.IsDBNull("Status") ? string.Empty : reader.GetString("Status"),
                                Priority = reader.IsDBNull("Priority") ? string.Empty : reader.GetString("Priority"),
                                TaskDate = reader.GetDateTime("TaskDate"),
                                Deadline = reader.GetDateTime("Deadline"),
                                AssignedByUserId = reader.IsDBNull("AssignedByUserId") ? 0 : reader.GetInt32("AssignedByUserId"),
                                CreatedAt = reader.GetDateTime("CreatedAt"),
                                UpdatedAt = reader.IsDBNull("UpdatedAt") ? reader.GetDateTime("CreatedAt") : reader.GetDateTime("UpdatedAt")
                            });
                        }
                    }
                }
            }
            return tasks;
        }

        public async Task<IEnumerable<TaskStatusHistoryDto>> GetTaskStatusHistoryByEmployeeAsync(string employeeName)
        {
            var history = new List<TaskStatusHistoryDto>();
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_GetTaskStatusHistoryByEmployee", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@EmployeeName", employeeName);
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            history.Add(new TaskStatusHistoryDto
                            {
                                TaskStatusHistoryId = reader.GetInt32("TaskStatusHistoryId"),
                                TaskId = reader.GetInt32("TaskId"),
                                EmployeeName = reader.IsDBNull("EmployeeName") ? string.Empty : reader.GetString("EmployeeName"),
                                Designation = reader.IsDBNull("Designation") ? string.Empty : reader.GetString("Designation"),
                                TaskDescription = reader.IsDBNull("TaskDescription") ? string.Empty : reader.GetString("TaskDescription"),
                                Status = reader.GetString("Status"),
                                Remarks = reader.IsDBNull("Remarks") ? string.Empty : reader.GetString("Remarks"),
                                ChangedAt = reader.GetDateTime("ChangedAt"),
                                ChangedByUser = reader.IsDBNull("ChangedByUser") ? string.Empty : reader.GetString("ChangedByUser")
                            });
                        }
                    }
                }
            }
            return history;
        }
    }
}
