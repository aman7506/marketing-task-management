using Microsoft.EntityFrameworkCore;
using MarketingTaskAPI.Data;
using MarketingTaskAPI.Models;
using System.Data;
using Microsoft.Data.SqlClient;

namespace MarketingTaskAPI.Services
{
    public class TaskServiceFixed : ITaskService
    {
        private readonly MarketingTaskDbContext _context;
        private readonly string _connectionString;

        public TaskServiceFixed(MarketingTaskDbContext context, IConfiguration configuration)
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
                
                // Use direct SQL query instead of stored procedure
                var sql = @"
                    SELECT 
                        t.TaskId,
                        t.AssignedByUserId,
                        u.Username AS AssignedByUsername,
                        t.EmployeeId,
                        e.Name AS EmployeeName,
                        e.Contact AS EmployeeContact,
                        e.Designation AS EmployeeDesignation,
                        e.Email AS EmployeeEmail,
                        t.LocationId,
                        l.LocationName,
                        l.State,
                        t.CustomLocation,
                        t.Description,
                        t.Priority,
                        t.TaskDate,
                        t.Deadline,
                        t.Status,
                        t.CreatedAt,
                        t.UpdatedAt
                    FROM Tasks t
                    INNER JOIN Users u ON t.AssignedByUserId = u.UserId
                    INNER JOIN Employees e ON t.EmployeeId = e.EmployeeId
                    LEFT JOIN Locations l ON t.LocationId = l.LocationId
                    ORDER BY t.CreatedAt DESC";
                
                using (var command = new SqlCommand(sql, connection))
                {
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
                                LocationId = reader.IsDBNull("LocationId") ? (int?)null : reader.GetInt32("LocationId"),
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
                
                var sql = @"
                    SELECT 
                        t.TaskId,
                        t.AssignedByUserId,
                        u.Username AS AssignedByUsername,
                        t.EmployeeId,
                        e.Name AS EmployeeName,
                        e.Contact AS EmployeeContact,
                        e.Designation AS EmployeeDesignation,
                        e.Email AS EmployeeEmail,
                        t.LocationId,
                        l.LocationName,
                        l.State,
                        t.CustomLocation,
                        t.Description,
                        t.Priority,
                        t.TaskDate,
                        t.Deadline,
                        t.Status,
                        t.CreatedAt,
                        t.UpdatedAt
                    FROM Tasks t
                    INNER JOIN Users u ON t.AssignedByUserId = u.UserId
                    INNER JOIN Employees e ON t.EmployeeId = e.EmployeeId
                    LEFT JOIN Locations l ON t.LocationId = l.LocationId
                    WHERE t.EmployeeId = @EmployeeId
                    ORDER BY t.CreatedAt DESC";
                
                using (var command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@EmployeeId", employeeId);
                    
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
                                LocationId = reader.IsDBNull("LocationId") ? (int?)null : reader.GetInt32("LocationId"),
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

        // Implement other required methods from ITaskService interface
        public async Task<TaskDto?> GetTaskByIdAsync(int taskId)
        {
            return await _context.UserTasks
                .Include(t => t.Employee)
                .Include(t => t.Location)
                .Include(t => t.AssignedByUser)
                .Where(t => t.TaskId == taskId)
                .Select(t => new TaskDto
                {
                    TaskId = t.TaskId,
                    EmployeeId = t.EmployeeId ?? 0,
                    EmployeeName = t.Employee.Name,
                    EmployeeContact = t.Employee.Contact,
                    EmployeeDesignation = t.Employee.Designation,
                    LocationId = t.LocationId,
                    LocationName = t.Location != null ? t.Location.LocationName : string.Empty,
                    CustomLocation = t.CustomLocation,
                    Description = t.Description,
                    Priority = t.Priority,
                    TaskDate = t.TaskDate,
                    Deadline = t.Deadline,
                    Status = t.Status,
                    AssignedByUserId = t.AssignedByUserId,
                    AssignedByUserName = t.AssignedByUser.Username,
                    CreatedAt = t.CreatedAt,
                    UpdatedAt = t.UpdatedAt
                })
                .FirstOrDefaultAsync();
        }

        public async Task<TaskDto> CreateTaskAsync(CreateTaskRequest request, int assignedByUserId)
        {
            var task = new UserTask
            {
                AssignedByUserId = assignedByUserId,
                EmployeeId = request.EmployeeId,
                LocationId = request.LocationId,
                CustomLocation = request.CustomLocation,
                Description = request.Description,
                Priority = request.Priority,
                TaskDate = request.TaskDate,
                Deadline = request.Deadline,
                Status = "Not Started",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.UserTasks.Add(task);
            await _context.SaveChangesAsync();

            return new TaskDto
            {
                TaskId = task.TaskId,
                EmployeeId = task.EmployeeId ?? 0,
                Description = task.Description,
                Priority = task.Priority,
                TaskDate = task.TaskDate,
                Deadline = task.Deadline,
                Status = task.Status,
                AssignedByUserId = task.AssignedByUserId,
                CreatedAt = task.CreatedAt,
                UpdatedAt = task.UpdatedAt
            };
        }

        public async Task<TaskDto?> UpdateTaskAsync(int taskId, UpdateTaskRequest request, int updatedByUserId)
        {
            var task = await _context.UserTasks.FindAsync(taskId);
            if (task == null) return null;

            task.EmployeeId = request.EmployeeId;
            task.LocationId = request.LocationId;
            task.CustomLocation = request.CustomLocation ?? string.Empty;
            task.Description = request.Description ?? string.Empty;
            task.Priority = request.Priority ?? string.Empty;
            task.TaskDate = request.TaskDate ?? DateTime.UtcNow;
            task.Deadline = request.Deadline ?? DateTime.UtcNow.AddDays(7);
            task.Status = request.Status ?? string.Empty;
            task.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            
            return new TaskDto
            {
                TaskId = task.TaskId,
                EmployeeId = task.EmployeeId ?? 0,
                Description = task.Description,
                Priority = task.Priority,
                TaskDate = task.TaskDate,
                Deadline = task.Deadline,
                Status = task.Status,
                AssignedByUserId = task.AssignedByUserId,
                CreatedAt = task.CreatedAt,
                UpdatedAt = task.UpdatedAt
            };
        }

        public async Task<bool> DeleteTaskAsync(int taskId)
        {
            var task = await _context.UserTasks.FindAsync(taskId);
            if (task == null) return false;

            _context.UserTasks.Remove(task);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<IEnumerable<HighPriorityTaskDto>> GetHighPriorityTasksAsync()
        {
            var tasks = new List<HighPriorityTaskDto>();
            
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                
                var sql = @"
                    SELECT TOP 10
                        t.TaskId,
                        e.Name AS AssignedTo,
                        e.Designation,
                        e.Email AS EmployeeEmail,
                        t.Description,
                        t.Priority,
                        l.LocationName AS Location,
                        t.Deadline,
                        t.Status,
                        u.Username AS AssignedBy,
                        CASE WHEN t.Priority = 'High' THEN 'Urgent' ELSE 'Normal' END AS UrgencyStatus,
                        t.CreatedAt
                    FROM Tasks t
                    INNER JOIN Users u ON t.AssignedByUserId = u.UserId
                    INNER JOIN Employees e ON t.EmployeeId = e.EmployeeId
                    LEFT JOIN Locations l ON t.LocationId = l.LocationId
                    WHERE t.Priority = 'High' AND t.Status != 'Completed'
                    ORDER BY t.Deadline ASC, t.CreatedAt DESC";
                
                using (var command = new SqlCommand(sql, connection))
                {
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            tasks.Add(new HighPriorityTaskDto
                            {
                                TaskId = reader.GetInt32("TaskId"),
                                AssignedTo = reader.GetString("AssignedTo"),
                                Designation = reader.GetString("Designation"),
                                EmployeeEmail = reader.GetString("EmployeeEmail"),
                                Description = reader.GetString("Description"),
                                TaskType = reader.IsDBNull("TaskType") ? string.Empty : reader.GetString("TaskType"),
                                Department = reader.IsDBNull("Department") ? string.Empty : reader.GetString("Department"),
                                Location = reader.IsDBNull("Location") ? string.Empty : reader.GetString("Location"),
                                EstimatedHours = reader.IsDBNull("EstimatedHours") ? 0 : reader.GetInt32("EstimatedHours"),
                                Deadline = reader.GetDateTime("Deadline"),
                                Status = reader.GetString("Status"),
                                AssignedBy = reader.GetString("AssignedBy"),
                                UrgencyStatus = reader.GetString("UrgencyStatus"),
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
                
                var sql = @"
                    SELECT 
                        t.TaskId,
                        t.AssignedByUserId,
                        u.Username AS AssignedByUsername,
                        t.EmployeeId,
                        e.Name AS EmployeeName,
                        e.Contact AS EmployeeContact,
                        e.Designation AS EmployeeDesignation,
                        e.Email AS EmployeeEmail,
                        t.LocationId,
                        l.LocationName,
                        l.State,
                        t.CustomLocation,
                        t.Description,
                        t.Priority,
                        t.TaskDate,
                        t.Deadline,
                        t.Status,
                        t.CreatedAt,
                        t.UpdatedAt
                    FROM Tasks t
                    INNER JOIN Users u ON t.AssignedByUserId = u.UserId
                    INNER JOIN Employees e ON t.EmployeeId = e.EmployeeId
                    LEFT JOIN Locations l ON t.LocationId = l.LocationId
                    WHERE t.Department = @Department
                    ORDER BY t.CreatedAt DESC";
                
                using (var command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@Department", department);
                    
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
                                LocationId = reader.IsDBNull("LocationId") ? (int?)null : reader.GetInt32("LocationId"),
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

        public async Task<TaskDto?> UpdateTaskStatusAsync(int taskId, UpdateTaskStatusRequest request, int changedByUserId)
        {
            var task = await _context.UserTasks.FindAsync(taskId);
            if (task == null) return null;

            task.Status = request.Status;
            task.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            
            return new TaskDto
            {
                TaskId = task.TaskId,
                EmployeeId = task.EmployeeId ?? 0,
                Description = task.Description,
                Priority = task.Priority,
                TaskDate = task.TaskDate,
                Deadline = task.Deadline,
                Status = task.Status,
                AssignedByUserId = task.AssignedByUserId,
                CreatedAt = task.CreatedAt,
                UpdatedAt = task.UpdatedAt
            };
        }

        public async Task<TaskDto?> RescheduleTaskAsync(int taskId, int rescheduledByUserId, TaskRescheduleRequest request)
        {
            var task = await _context.UserTasks.FindAsync(taskId);
            if (task == null) return null;

            task.TaskDate = request.NewTaskDate;
            task.Deadline = request.NewDeadline;
            task.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            
            return new TaskDto
            {
                TaskId = task.TaskId,
                EmployeeId = task.EmployeeId ?? 0,
                Description = task.Description,
                Priority = task.Priority,
                TaskDate = task.TaskDate,
                Deadline = task.Deadline,
                Status = task.Status,
                AssignedByUserId = task.AssignedByUserId,
                CreatedAt = task.CreatedAt,
                UpdatedAt = task.UpdatedAt
            };
        }

        public Task<IEnumerable<TaskRescheduleDto>> GetTaskRescheduleHistoryAsync(int taskId)
        {
            // Return empty list for now - implement if needed
            return Task.FromResult<IEnumerable<TaskRescheduleDto>>(new List<TaskRescheduleDto>());
        }

        public async Task<Dictionary<string, int>> GetTaskStatisticsAsync()
        {
            var stats = new Dictionary<string, int>();
            
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                
                var sql = @"
                    SELECT 
                        Status,
                        COUNT(*) as Count
                    FROM Tasks 
                    GROUP BY Status";
                
                using (var command = new SqlCommand(sql, connection))
                {
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            stats[reader.GetString("Status")] = reader.GetInt32("Count");
                        }
                    }
                }
            }
            
            return stats;
        }

        public async Task<Dictionary<string, int>> GetEmployeeTaskStatisticsAsync(int employeeId)
        {
            var stats = new Dictionary<string, int>();
            
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                
                var sql = @"
                    SELECT 
                        Status,
                        COUNT(*) as Count
                    FROM Tasks 
                    WHERE EmployeeId = @EmployeeId
                    GROUP BY Status";
                
                using (var command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@EmployeeId", employeeId);
                    
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            stats[reader.GetString("Status")] = reader.GetInt32("Count");
                        }
                    }
                }
            }
            
            return stats;
        }

        public Task<IEnumerable<TaskStatusHistoryDto>> GetTaskStatusHistoryByEmployeeAsync(string employeeName)
        {
            // Return empty list for now - implement if needed
            return Task.FromResult<IEnumerable<TaskStatusHistoryDto>>(new List<TaskStatusHistoryDto>());
        }
    }
}
