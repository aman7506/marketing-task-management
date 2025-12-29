using MarketingTaskAPI.Models;

namespace MarketingTaskAPI.Services
{
    public interface ITaskTypeService
    {
        Task<IEnumerable<TaskTypeDto>> GetAllTaskTypesAsync();
        Task<TaskTypeDto?> GetTaskTypeByIdAsync(int taskTypeId);
        Task<TaskTypeDto> CreateTaskTypeAsync(string typeName, string? description = null);
        Task<TaskTypeDto?> UpdateTaskTypeAsync(int taskTypeId, string typeName, string? description = null);
        Task<bool> DeleteTaskTypeAsync(int taskTypeId);
        Task<bool> ToggleTaskTypeStatusAsync(int taskTypeId);
    }
}