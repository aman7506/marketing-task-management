using MarketingTaskAPI.Data;
using MarketingTaskAPI.Models;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace MarketingTaskAPI.Services
{
    public class LocationLogService : ILocationLogService
    {
        private readonly MarketingTaskDbContext _context;
        private readonly ILogger<LocationLogService> _logger;

        public LocationLogService(MarketingTaskDbContext context, ILogger<LocationLogService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<LocationLogDto> SaveLocationAsync(LocationUpdateRequest request, CancellationToken cancellationToken = default)
        {
            if (request == null) throw new ArgumentNullException(nameof(request));

            var log = new LocationLog
            {
                EmployeeId = request.EmployeeId,
                Latitude = request.Latitude,
                Longitude = request.Longitude,
                Timestamp = request.Timestamp?.ToUniversalTime() ?? DateTime.UtcNow
            };

            _context.LocationLogs.Add(log);
            await _context.SaveChangesAsync(cancellationToken);

            _logger.LogInformation("Location logged for employee {EmployeeId} at {Timestamp}", log.EmployeeId, log.Timestamp);

            return MapToDto(log);
        }

        public async Task<LocationLogDto?> GetLatestLocationAsync(int employeeId, CancellationToken cancellationToken = default)
        {
            var log = await _context.LocationLogs
                .Where(l => l.EmployeeId == employeeId)
                .OrderByDescending(l => l.Timestamp)
                .FirstOrDefaultAsync(cancellationToken);

            return log == null ? null : MapToDto(log);
        }

        public async Task<IReadOnlyList<LocationLogDto>> GetRecentLocationsAsync(int employeeId, DateTime? sinceUtc = null, int maxRows = 100, CancellationToken cancellationToken = default)
        {
            sinceUtc ??= DateTime.UtcNow.AddHours(-4);

            var logs = await _context.LocationLogs
                .Where(l => l.EmployeeId == employeeId && l.Timestamp >= sinceUtc)
                .OrderByDescending(l => l.Timestamp)
                .Take(Math.Clamp(maxRows, 1, 1000))
                .ToListAsync(cancellationToken);

            return logs.Select(MapToDto).ToList();
        }

        private static LocationLogDto MapToDto(LocationLog log) =>
            new()
            {
                LogId = log.LogId,
                EmployeeId = log.EmployeeId,
                Latitude = log.Latitude,
                Longitude = log.Longitude,
                Timestamp = log.Timestamp
            };
    }
}

