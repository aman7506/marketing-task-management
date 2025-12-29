using MarketingTaskAPI.Models;

namespace MarketingTaskAPI.Services
{
    public interface IEmployeeService
    {
        Task<IEnumerable<EmployeeDto>> GetAllEmployeesAsync();
        Task<EmployeeDto?> GetEmployeeByIdAsync(int employeeId);
        Task<EmployeeDto> CreateEmployeeAsync(EmployeeDto employee);
        Task<EmployeeDto> UpdateEmployeeAsync(int employeeId, EmployeeDto employee);
        Task<bool> DeleteEmployeeAsync(int employeeId);
        Task<IEnumerable<EmployeeSummaryDto>> GetEmployeeSummaryAsync();
    }
} 