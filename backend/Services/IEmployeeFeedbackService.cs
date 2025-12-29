using MarketingTaskAPI.Models;

namespace MarketingTaskAPI.Services
{
    public interface IEmployeeFeedbackService
    {
        Task<IEnumerable<EmployeeFeedbackDto>> GetFeedbackByEmployeeIdAsync(int employeeId);
        Task<IEnumerable<EmployeeFeedbackDto>> GetFeedbackByTaskIdAsync(int taskId);
        Task<EmployeeFeedbackDto?> GetFeedbackByIdAsync(int feedbackId);
        Task<EmployeeFeedbackDto> CreateFeedbackAsync(int employeeId, CreateEmployeeFeedbackRequest request);
        Task<EmployeeFeedbackDto?> UpdateFeedbackAsync(int feedbackId, int employeeId, UpdateEmployeeFeedbackRequest request);
        Task<bool> DeleteFeedbackAsync(int feedbackId, int employeeId);
    }
}