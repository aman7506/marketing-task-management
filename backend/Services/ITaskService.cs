using MarketingTaskAPI.Models;

namespace MarketingTaskAPI.Services
{
    public interface ITaskService
    {
        Task<IEnumerable<TaskDto>> GetAllTasksAsync();
        Task<IEnumerable<TaskDto>> GetTasksByEmployeeAsync(int employeeId);
        Task<TaskDto?> GetTaskByIdAsync(int taskId);
        Task<TaskDto> CreateTaskAsync(CreateTaskRequest request, int assignedByUserId);
        Task<TaskDto?> UpdateTaskStatusAsync(int taskId, UpdateTaskStatusRequest request, int changedByUserId);
        Task<TaskDto?> UpdateTaskAsync(int taskId, UpdateTaskRequest request, int updatedByUserId);
        Task<bool> DeleteTaskAsync(int taskId);
        
        // Task rescheduling
        Task<TaskDto?> RescheduleTaskAsync(int taskId, int rescheduledByUserId, TaskRescheduleRequest request);
        Task<IEnumerable<TaskRescheduleDto>> GetTaskRescheduleHistoryAsync(int taskId);
        
        // Task statistics
        Task<Dictionary<string, int>> GetTaskStatisticsAsync();
        Task<Dictionary<string, int>> GetEmployeeTaskStatisticsAsync(int employeeId);
        
        // Reporting methods using stored procedures
        Task<IEnumerable<HighPriorityTaskDto>> GetHighPriorityTasksAsync();
        Task<IEnumerable<TaskDto>> GetTasksByDepartmentAsync(string department);
        Task<IEnumerable<TaskStatusHistoryDto>> GetTaskStatusHistoryByEmployeeAsync(string employeeName);
    }
} 