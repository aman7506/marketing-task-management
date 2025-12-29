using MarketingTaskAPI.Models;

namespace MarketingTaskAPI.Services
{
    public interface ILocationLogService
    {
        Task<LocationLogDto> SaveLocationAsync(LocationUpdateRequest request, CancellationToken cancellationToken = default);
        Task<LocationLogDto?> GetLatestLocationAsync(int employeeId, CancellationToken cancellationToken = default);
        Task<IReadOnlyList<LocationLogDto>> GetRecentLocationsAsync(int employeeId, DateTime? sinceUtc = null, int maxRows = 100, CancellationToken cancellationToken = default);
    }
}

