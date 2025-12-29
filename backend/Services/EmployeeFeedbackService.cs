using Microsoft.EntityFrameworkCore;
using MarketingTaskAPI.Data;
using MarketingTaskAPI.Models;

namespace MarketingTaskAPI.Services
{
    public class EmployeeFeedbackService : IEmployeeFeedbackService
    {
        private readonly MarketingTaskDbContext _context;

        public EmployeeFeedbackService(MarketingTaskDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<EmployeeFeedbackDto>> GetFeedbackByEmployeeIdAsync(int employeeId)
        {
            return await _context.EmployeeFeedback
                .Where(f => f.EmployeeId == employeeId)
                .Include(f => f.Task)
                .Include(f => f.Employee)
                .Select(f => new EmployeeFeedbackDto
                {
                    FeedbackId = f.FeedbackId,
                    TaskId = f.TaskId,
                    TaskDescription = f.Task.Description,
                    EmployeeId = f.EmployeeId,
                    EmployeeName = f.Employee.Name,
                    ConsultantName = f.ConsultantName,
                    FeedbackText = f.FeedbackText,
                    MeetingDate = f.MeetingDate,
                    CreatedAt = f.CreatedAt,
                    UpdatedAt = f.UpdatedAt
                })
                .OrderByDescending(f => f.CreatedAt)
                .ToListAsync();
        }

        public async Task<IEnumerable<EmployeeFeedbackDto>> GetFeedbackByTaskIdAsync(int taskId)
        {
            return await _context.EmployeeFeedback
                .Where(f => f.TaskId == taskId)
                .Include(f => f.Task)
                .Include(f => f.Employee)
                .Select(f => new EmployeeFeedbackDto
                {
                    FeedbackId = f.FeedbackId,
                    TaskId = f.TaskId,
                    TaskDescription = f.Task.Description,
                    EmployeeId = f.EmployeeId,
                    EmployeeName = f.Employee.Name,
                    ConsultantName = f.ConsultantName,
                    FeedbackText = f.FeedbackText,
                    MeetingDate = f.MeetingDate,
                    CreatedAt = f.CreatedAt,
                    UpdatedAt = f.UpdatedAt
                })
                .OrderByDescending(f => f.CreatedAt)
                .ToListAsync();
        }

        public async Task<EmployeeFeedbackDto?> GetFeedbackByIdAsync(int feedbackId)
        {
            return await _context.EmployeeFeedback
                .Where(f => f.FeedbackId == feedbackId)
                .Include(f => f.Task)
                .Include(f => f.Employee)
                .Select(f => new EmployeeFeedbackDto
                {
                    FeedbackId = f.FeedbackId,
                    TaskId = f.TaskId,
                    TaskDescription = f.Task.Description,
                    EmployeeId = f.EmployeeId,
                    EmployeeName = f.Employee.Name,
                    ConsultantName = f.ConsultantName,
                    FeedbackText = f.FeedbackText,
                    MeetingDate = f.MeetingDate,
                    CreatedAt = f.CreatedAt,
                    UpdatedAt = f.UpdatedAt
                })
                .OrderBy(f => f.FeedbackId)
                .FirstOrDefaultAsync();
        }

        public async Task<EmployeeFeedbackDto> CreateFeedbackAsync(int employeeId, CreateEmployeeFeedbackRequest request)
        {
            // Verify that the task exists and belongs to the employee
            var task = await _context.Tasks
                .Where(t => t.TaskId == request.TaskId && t.EmployeeId == employeeId)
                .FirstOrDefaultAsync();
            
            if (task == null)
            {
                throw new ArgumentException("Task not found or does not belong to the employee.");
            }

            var feedback = new EmployeeFeedback
            {
                TaskId = request.TaskId,
                EmployeeId = employeeId,
                ConsultantName = request.ConsultantName,
                FeedbackText = request.FeedbackText,
                MeetingDate = request.MeetingDate,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.EmployeeFeedback.Add(feedback);
            await _context.SaveChangesAsync();

            return await GetFeedbackByIdAsync(feedback.FeedbackId) ?? throw new InvalidOperationException("Failed to retrieve created feedback.");
        }

        public async Task<EmployeeFeedbackDto?> UpdateFeedbackAsync(int feedbackId, int employeeId, UpdateEmployeeFeedbackRequest request)
        {
            var feedback = await _context.EmployeeFeedback
                .FirstOrDefaultAsync(f => f.FeedbackId == feedbackId && f.EmployeeId == employeeId);

            if (feedback == null)
            {
                return null;
            }

            feedback.ConsultantName = request.ConsultantName;
            feedback.FeedbackText = request.FeedbackText;
            feedback.MeetingDate = request.MeetingDate;
            feedback.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return await GetFeedbackByIdAsync(feedbackId);
        }

        public async Task<bool> DeleteFeedbackAsync(int feedbackId, int employeeId)
        {
            var feedback = await _context.EmployeeFeedback
                .FirstOrDefaultAsync(f => f.FeedbackId == feedbackId && f.EmployeeId == employeeId);

            if (feedback == null)
            {
                return false;
            }

            _context.EmployeeFeedback.Remove(feedback);
            await _context.SaveChangesAsync();

            return true;
        }
    }
}