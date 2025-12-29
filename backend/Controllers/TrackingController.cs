using MarketingTaskAPI.Hubs;
using MarketingTaskAPI.Models;
using MarketingTaskAPI.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.DependencyInjection;
using System.Threading;

namespace MarketingTaskAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin")]
    public class TrackingController : ControllerBase
    {
        private readonly IHubContext<TrackingHub> _hubContext;
        private readonly ILocationLogService _locationLogService;
        private readonly ILogger<TrackingController> _logger;
        private readonly IServiceScopeFactory _scopeFactory;

        public TrackingController(
            IHubContext<TrackingHub> hubContext,
            ILocationLogService locationLogService,
            ILogger<TrackingController> logger,
            IServiceScopeFactory scopeFactory)
        {
            _hubContext = hubContext;
            _locationLogService = locationLogService;
            _logger = logger;
            _scopeFactory = scopeFactory;
        }

        [HttpGet("{employeeId}/latest")]
        public async Task<ActionResult<LocationLogDto>> GetLatestLocation(int employeeId)
        {
            var latest = await _locationLogService.GetLatestLocationAsync(employeeId);
            if (latest == null) return NotFound();
            return Ok(latest);
        }

        [HttpGet("{employeeId}/history")]
        public async Task<ActionResult<IEnumerable<LocationLogDto>>> GetRecentLocations(
            int employeeId,
            [FromQuery] int hours = 4,
            [FromQuery] int max = 200)
        {
            hours = Math.Clamp(hours, 1, 24);
            max = Math.Clamp(max, 10, 1000);
            var since = DateTime.UtcNow.AddHours(-hours);
            var history = await _locationLogService.GetRecentLocationsAsync(employeeId, since, max);
            return Ok(history);
        }

        [HttpPost("simulate-trip")]
        public IActionResult SimulateTrip([FromBody] SimulateTripRequest request)
        {
            if (!ModelState.IsValid)
            {
                return ValidationProblem(ModelState);
            }

            if (request.EmployeeId <= 0)
            {
                return BadRequest("EmployeeId is required for simulation.");
            }

            var linkedCts = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted);
            _ = RunSimulationAsync(request, linkedCts.Token);

            return Accepted(new
            {
                message = "Simulation started",
                request.EmployeeId,
                request.Waypoints,
                request.IntervalSeconds
            });
        }

        private async Task RunSimulationAsync(SimulateTripRequest request, CancellationToken token)
        {
            try
            {
                var steps = Math.Max(request.Waypoints, 50);
                var intervalSeconds = Math.Clamp(request.IntervalSeconds, 1, 2);

                using var scope = _scopeFactory.CreateScope();
                var scopedLocationLogService = scope.ServiceProvider.GetRequiredService<ILocationLogService>();

                for (var i = 0; i <= steps && !token.IsCancellationRequested; i++)
                {
                    var progress = (double)i / steps;
                    var latitude = Interpolate(request.StartLatitude, request.EndLatitude, progress);
                    var longitude = Interpolate(request.StartLongitude, request.EndLongitude, progress);

                    var update = new LocationUpdateRequest
                    {
                        EmployeeId = request.EmployeeId,
                        Latitude = latitude,
                        Longitude = longitude,
                        Timestamp = DateTime.UtcNow
                    };

                    var persisted = await scopedLocationLogService.SaveLocationAsync(update, token);
                    await _hubContext.Clients.All.SendAsync("ReceiveLocationUpdate", persisted, CancellationToken.None);

                    await Task.Delay(TimeSpan.FromSeconds(intervalSeconds), token);
                }
            }
            catch (TaskCanceledException)
            {
                _logger.LogInformation("Simulation for employee {EmployeeId} cancelled", request.EmployeeId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Simulation failed for employee {EmployeeId}", request.EmployeeId);
            }
        }

        private static double Interpolate(double start, double end, double t) =>
            start + (end - start) * t;
    }
}

