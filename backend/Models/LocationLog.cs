using System.ComponentModel.DataAnnotations;

namespace MarketingTaskAPI.Models
{
    public class LocationLog
    {
        public long LogId { get; set; }

        [Required]
        public int EmployeeId { get; set; }

        [Range(-90, 90)]
        public double Latitude { get; set; }

        [Range(-180, 180)]
        public double Longitude { get; set; }

        public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    }

    public class LocationLogDto
    {
        public long LogId { get; set; }
        public int EmployeeId { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public DateTime Timestamp { get; set; }
    }

    public class LocationUpdateRequest
    {
        [Required]
        public int EmployeeId { get; set; }

        [Required]
        [Range(-90, 90)]
        public double Latitude { get; set; }

        [Required]
        [Range(-180, 180)]
        public double Longitude { get; set; }

        public DateTime? Timestamp { get; set; }
    }

    public class SimulateTripRequest
    {
        public int EmployeeId { get; set; }

        [Range(-90, 90)]
        public double StartLatitude { get; set; } = 28.6139; // Default: New Delhi

        [Range(-180, 180)]
        public double StartLongitude { get; set; } = 77.2090;

        [Range(-90, 90)]
        public double EndLatitude { get; set; } = 28.4595; // Default: Gurgaon

        [Range(-180, 180)]
        public double EndLongitude { get; set; } = 77.0266;

        [Range(50, 500)]
        public int Waypoints { get; set; } = 60;

        [Range(1, 2)]
        public int IntervalSeconds { get; set; } = 1;
    }
}

