using MarketingTaskAPI.Models;
using MarketingTaskAPI.Services;
using Microsoft.AspNetCore.SignalR;

namespace MarketingTaskAPI.Hubs
{
    public class TrackingHub : Hub
    {
        private readonly ILocationLogService _locationLogService;
        private readonly ILogger<TrackingHub> _logger;

        public TrackingHub(ILocationLogService locationLogService, ILogger<TrackingHub> logger)
        {
            _locationLogService = locationLogService;
            _logger = logger;
        }

        public async Task SendLocationUpdate(LocationUpdateRequest request)
        {
            if (request == null)
            {
                _logger.LogWarning("Received null location update");
                return;
            }

            if (request.EmployeeId <= 0)
            {
                _logger.LogWarning("Rejected location update with invalid employee id");
                return;
            }

            var persisted = await _locationLogService.SaveLocationAsync(request);
            await Clients.All.SendAsync("ReceiveLocationUpdate", persisted);
        }
    }
}

