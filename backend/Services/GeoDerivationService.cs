using MarketingTaskAPI.Models;
using System.Text.Json;

namespace MarketingTaskAPI.Services
{
    public class GeoLocation
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public int StateId { get; set; }
        public string PincodeValue { get; set; } = string.Empty;
    }

    public class State
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
    }

    public class GeoDerivationService
    {
        private static readonly List<State> States = new()
        {
            new State { Id = 1, Name = "Delhi" },
            new State { Id = 2, Name = "Haryana" },
            new State { Id = 3, Name = "Uttar Pradesh" }
        };

        private static readonly List<GeoLocation> Cities = new()
        {
            new GeoLocation { Id = 101, Name = "New Delhi", StateId = 1, PincodeValue = "110001" },
            new GeoLocation { Id = 102, Name = "Noida", StateId = 3, PincodeValue = "201301" },
            new GeoLocation { Id = 103, Name = "Gurgaon", StateId = 2, PincodeValue = "122001" },
            new GeoLocation { Id = 104, Name = "Faridabad", StateId = 2, PincodeValue = "121001" },
            new GeoLocation { Id = 105, Name = "Dwarka (Delhi)", StateId = 1, PincodeValue = "110075" },
            new GeoLocation { Id = 106, Name = "Janakpuri (Delhi)", StateId = 1, PincodeValue = "110058" },
            new GeoLocation { Id = 107, Name = "Khan Market (Delhi)", StateId = 1, PincodeValue = "110003" },
            new GeoLocation { Id = 108, Name = "Connaught Place (Delhi)", StateId = 1, PincodeValue = "110001" },
            new GeoLocation { Id = 109, Name = "Sector 29 (Gurgaon)", StateId = 2, PincodeValue = "122001" }
        };

        public void ApplyDefaults(UserTask task)
        {
            // Apply string defaults
            task.Description = string.IsNullOrWhiteSpace(task.Description) ? "No description provided." : task.Description;
            task.ClientName = string.IsNullOrWhiteSpace(task.ClientName) ? "N/A" : task.ClientName;
            task.ProjectCode = string.IsNullOrWhiteSpace(task.ProjectCode) ? $"GEN-{task.TaskId}" : task.ProjectCode;
            task.CustomLocation = string.IsNullOrWhiteSpace(task.CustomLocation) ? 
                (!string.IsNullOrWhiteSpace(task.CityName) ? task.CityName : "Head Office") : task.CustomLocation;
            task.TaskCategory = string.IsNullOrWhiteSpace(task.TaskCategory) ? 
                (!string.IsNullOrWhiteSpace(task.TaskType) ? task.TaskType : "General") : task.TaskCategory;
            task.AdditionalNotes = string.IsNullOrWhiteSpace(task.AdditionalNotes) ? "No additional notes." : task.AdditionalNotes;
            task.Department = string.IsNullOrWhiteSpace(task.Department) ? 
                (!string.IsNullOrWhiteSpace(task.TaskType) && task.TaskType.Contains("Marketing", StringComparison.OrdinalIgnoreCase) ? 
                    "Marketing" : "Operations") : task.Department;
            task.EmployeeIdNumber = string.IsNullOrWhiteSpace(task.EmployeeIdNumber) ? $"EMP-{task.EmployeeId}" : task.EmployeeIdNumber;

            // Apply numeric defaults
            task.EstimatedHours = task.EstimatedHours ?? 8.00m;
            
            if (task.Status == "Completed")
                task.ActualHours = task.EstimatedHours;
            else if (task.Status == "In Progress")
                task.ActualHours = Math.Round((task.EstimatedHours ?? 0) * 0.5m, 2);
            else
                task.ActualHours = 0.00m;
                
            task.IsUrgent = string.IsNullOrWhiteSpace(task.Priority) ? false : task.Priority == "High";

            // Apply date defaults
            if (task.TaskDate == DateTime.MinValue)
                task.TaskDate = task.CreatedAt != DateTime.MinValue ? task.CreatedAt : DateTime.UtcNow;
                
            if (task.Deadline == DateTime.MinValue)
                task.Deadline = task.TaskDate.AddDays(1);
                
            if (task.CreatedAt == DateTime.MinValue)
                task.CreatedAt = task.TaskDate != DateTime.MinValue ? task.TaskDate : DateTime.UtcNow;
                
            if (task.UpdatedAt == DateTime.MinValue)
                task.UpdatedAt = task.CreatedAt;

            // Apply other defaults
            task.Status = string.IsNullOrWhiteSpace(task.Status) ? "Not Started" : task.Status;
            task.Priority = string.IsNullOrWhiteSpace(task.Priority) ? "Medium" : task.Priority;
            task.TaskType = string.IsNullOrWhiteSpace(task.TaskType) ? "General" : task.TaskType;

            // Apply geo derivation
            DeriveGeoLocation(task);
        }

        public void DeriveGeoLocation(UserTask task)
        {
            // If we already have location data, don't override it
            if (task.StateId.HasValue && task.CityId.HasValue && 
                !string.IsNullOrWhiteSpace(task.StateName) && 
                !string.IsNullOrWhiteSpace(task.CityName) &&
                !string.IsNullOrWhiteSpace(task.PincodeValue))
            {
                return;
            }

            var locationText = !string.IsNullOrWhiteSpace(task.CustomLocation) ? task.CustomLocation :
                              !string.IsNullOrWhiteSpace(task.CityName) ? task.CityName : "New Delhi";

            var matchedCity = Cities.FirstOrDefault(c => 
                locationText.Contains(c.Name, StringComparison.OrdinalIgnoreCase) ||
                c.Name.Contains(locationText, StringComparison.OrdinalIgnoreCase));

            if (matchedCity != null)
            {
                task.CityId = matchedCity.Id;
                task.CityName = matchedCity.Name;
                task.StateId = matchedCity.StateId;
                task.StateName = States.FirstOrDefault(s => s.Id == matchedCity.StateId)?.Name ?? "Unknown";
                task.PincodeValue = matchedCity.PincodeValue;
                task.PincodeId = 0; // Default ID for pincode
                task.AreaId = 0; // Default ID for area
                return;
            }

            // Default to New Delhi if no match
            task.CityId = 101;
            task.CityName = "New Delhi";
            task.StateId = 1;
            task.StateName = "Delhi";
            task.PincodeValue = "110001";
            task.PincodeId = 0;
            task.AreaId = 0;
        }
    }
}