using Microsoft.EntityFrameworkCore;
using MarketingTaskAPI.Data;
using MarketingTaskAPI.Models;

namespace MarketingTaskAPI.Services
{
    public class TaskTypeService : ITaskTypeService
    {
        private readonly MarketingTaskDbContext _context;

        public TaskTypeService(MarketingTaskDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<TaskTypeDto>> GetAllTaskTypesAsync()
        {
            return await _context.TaskTypes
                .Where(tt => tt.IsActive)
                .Select(tt => new TaskTypeDto
                {
                    TaskTypeId = tt.TaskTypeId,
                    TypeName = tt.TypeName,
                    Description = tt.Description,
                    IsActive = tt.IsActive
                })
                .OrderBy(tt => tt.TypeName)
                .ToListAsync();
        }

        public async Task<TaskTypeDto?> GetTaskTypeByIdAsync(int taskTypeId)
        {
            return await _context.TaskTypes
                .Where(tt => tt.TaskTypeId == taskTypeId)
                .Select(tt => new TaskTypeDto
                {
                    TaskTypeId = tt.TaskTypeId,
                    TypeName = tt.TypeName,
                    Description = tt.Description,
                    IsActive = tt.IsActive
                })
                .OrderBy(tt => tt.TaskTypeId)
                .FirstOrDefaultAsync();
        }

        public async Task<TaskTypeDto> CreateTaskTypeAsync(string typeName, string? description = null)
        {
            // Check if task type already exists
            var existingTaskType = await _context.TaskTypes
                .FirstOrDefaultAsync(tt => tt.TypeName.ToLower() == typeName.ToLower());

            if (existingTaskType != null)
            {
                throw new ArgumentException("Task type with this name already exists.");
            }

            var taskType = new TaskType
            {
                TypeName = typeName,
                Description = description,
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };

            _context.TaskTypes.Add(taskType);
            await _context.SaveChangesAsync();

            return new TaskTypeDto
            {
                TaskTypeId = taskType.TaskTypeId,
                TypeName = taskType.TypeName,
                Description = taskType.Description,
                IsActive = taskType.IsActive
            };
        }

        public async Task<TaskTypeDto?> UpdateTaskTypeAsync(int taskTypeId, string typeName, string? description = null)
        {
            var taskType = await _context.TaskTypes.FindAsync(taskTypeId);
            if (taskType == null)
            {
                return null;
            }

            // Check if another task type with the same name exists
            var existingTaskType = await _context.TaskTypes
                .FirstOrDefaultAsync(tt => tt.TypeName.ToLower() == typeName.ToLower() && tt.TaskTypeId != taskTypeId);

            if (existingTaskType != null)
            {
                throw new ArgumentException("Task type with this name already exists.");
            }

            taskType.TypeName = typeName;
            taskType.Description = description;

            await _context.SaveChangesAsync();

            return new TaskTypeDto
            {
                TaskTypeId = taskType.TaskTypeId,
                TypeName = taskType.TypeName,
                Description = taskType.Description,
                IsActive = taskType.IsActive
            };
        }

        public async Task<bool> DeleteTaskTypeAsync(int taskTypeId)
        {
            var taskType = await _context.TaskTypes.FindAsync(taskTypeId);
            if (taskType == null)
            {
                return false;
            }

            // Check if task type is being used
            var isInUse = await _context.TaskTaskTypes.AnyAsync(ttt => ttt.TaskTypeId == taskTypeId);
            if (isInUse)
            {
                // Soft delete - just deactivate
                taskType.IsActive = false;
                await _context.SaveChangesAsync();
                return true;
            }

            // Hard delete if not in use
            _context.TaskTypes.Remove(taskType);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> ToggleTaskTypeStatusAsync(int taskTypeId)
        {
            var taskType = await _context.TaskTypes.FindAsync(taskTypeId);
            if (taskType == null)
            {
                return false;
            }

            taskType.IsActive = !taskType.IsActive;
            await _context.SaveChangesAsync();
            return true;
        }
    }
}