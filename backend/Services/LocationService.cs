using Microsoft.EntityFrameworkCore;
using MarketingTaskAPI.Data;
using MarketingTaskAPI.Models;
using Microsoft.Data.SqlClient;
using System.Data;

namespace MarketingTaskAPI.Services
{
    public class LocationService : ILocationService
    {
        private readonly MarketingTaskDbContext _context;
        private readonly string _connectionString;

        public LocationService(MarketingTaskDbContext context, IConfiguration configuration)
        {
            _context = context;
            _connectionString = configuration.GetConnectionString("DefaultConnection") ?? throw new ArgumentNullException("Connection string not found");
        }

        public async Task<IEnumerable<LocationDto>> GetAllLocationsAsync()
        {
            var locations = new List<LocationDto>();
            
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_GetLocations", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@IsActive", true);
                    
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            locations.Add(new LocationDto
                            {
                                LocationId = reader.GetInt32("LocationId"),
                                LocationName = reader.GetString("LocationName"),
                                State = reader.GetString("State"),
                                CreatedAt = reader.GetDateTime("CreatedAt")
                            });
                        }
                    }
                }
            }
            
            return locations;
        }

        public async Task<IEnumerable<LocationDto>> GetLocationsByStateAsync(string state)
        {
            return await _context.Locations
                .Where(l => l.State == state && l.IsActive)
                .Select(l => new LocationDto
                {
                    LocationId = l.LocationId,
                    LocationName = l.LocationName,
                    State = l.State,
                    CreatedAt = l.CreatedAt
                })
                .ToListAsync();
        }

        public async Task<LocationDto?> GetLocationByIdAsync(int locationId)
        {
            var location = await _context.Locations
                .FirstOrDefaultAsync(l => l.LocationId == locationId && l.IsActive);

            if (location == null) return null;

            return new LocationDto
            {
                LocationId = location.LocationId,
                LocationName = location.LocationName,
                State = location.State,
                CreatedAt = location.CreatedAt
            };
        }

        public async Task<LocationDto> CreateLocationAsync(CreateLocationRequest request)
        {
            var location = new Location
            {
                LocationName = request.LocationName,
                State = request.State, // Legacy field
                StateId = request.StateId,
                AreaId = request.AreaId,
                PincodeId = request.PincodeId,
                CreatedAt = DateTime.UtcNow,
                IsActive = true
            };

            _context.Locations.Add(location);
            await _context.SaveChangesAsync();

            // Load related data for response
            await _context.Entry(location)
                .Reference(l => l.StateNavigation)
                .LoadAsync();
            await _context.Entry(location)
                .Reference(l => l.AreaNavigation)
                .LoadAsync();
            await _context.Entry(location)
                .Reference(l => l.PincodeNavigation)
                .LoadAsync();

            return new LocationDto
            {
                LocationId = location.LocationId,
                LocationName = location.LocationName,
                State = location.State,
                StateId = location.StateId,
                StateName = location.StateNavigation?.StateName,
                AreaId = location.AreaId,
                AreaName = location.AreaNavigation?.AreaName,
                PincodeId = location.PincodeId,
                PincodeValue = location.PincodeNavigation?.PincodeValue,
                CreatedAt = location.CreatedAt
            };
        }

        public async Task<LocationDto> UpdateLocationAsync(int locationId, CreateLocationRequest request)
        {
            var location = await _context.Locations.FindAsync(locationId);
            if (location == null)
                throw new ArgumentException("Location not found");

            location.LocationName = request.LocationName;
            location.State = request.State;

            await _context.SaveChangesAsync();

            return new LocationDto
            {
                LocationId = location.LocationId,
                LocationName = location.LocationName,
                State = location.State,
                CreatedAt = location.CreatedAt
            };
        }

        public async Task<bool> DeleteLocationAsync(int locationId)
        {
            var location = await _context.Locations.FindAsync(locationId);
            if (location == null) return false;

            location.IsActive = false;
            await _context.SaveChangesAsync();
            return true;
        }

        // Hierarchical location methods
        public async Task<IEnumerable<StateDto>> GetAllStatesAsync()
        {
            var states = new List<StateDto>();
            
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_GetStates", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            states.Add(new StateDto
                            {
                                StateId = reader.GetInt32("StateId"),
                                StateName = reader.GetString("StateName"),
                                StateCode = reader.IsDBNull("StateCode") ? string.Empty : reader.GetString("StateCode"),
                                IsActive = true
                            });
                        }
                    }
                }
            }
            
            return states;
        }

        public async Task<IEnumerable<AreaDto>> GetAreasByStateAsync(int stateId)
        {
            var areas = new List<AreaDto>();
            
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_GetCitiesByState", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@StateId", stateId);
                    
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            areas.Add(new AreaDto
                            {
                                AreaId = reader.GetInt32("CityId"),
                                AreaName = reader.GetString("CityName"),
                                CityId = stateId,
                                CityName = string.Empty, // Will be populated separately if needed
                                IsActive = true
                            });
                        }
                    }
                }
            }
            
            return areas;
        }

        public async Task<IEnumerable<PincodeDto>> GetPincodesByAreaAsync(int areaId)
        {
            return await _context.Pincodes
                .Include(p => p.Area)
                .Where(p => p.AreaId == areaId && p.IsActive)
                .OrderBy(p => p.PincodeValue)
                .Select(p => new PincodeDto
                {
                    PincodeId = p.PincodeId,
                    PincodeValue = p.PincodeValue,
                    AreaId = p.AreaId,
                    AreaName = p.Area.AreaName,
                    LocalityName = p.LocalityName,
                    IsActive = p.IsActive
                })
                .ToListAsync();
        }

        public async Task<IEnumerable<HierarchicalLocationDto>> GetHierarchicalLocationsAsync()
        {
            return await _context.Locations
                .Include(l => l.StateNavigation)
                .Include(l => l.AreaNavigation)
                .Include(l => l.PincodeNavigation)
                .Where(l => l.IsActive)
                .OrderBy(l => l.LocationName)
                .Select(l => new HierarchicalLocationDto
                {
                    LocationId = l.LocationId,
                    LocationName = l.LocationName,
                    StateId = l.StateId,
                    StateName = l.StateNavigation != null ? l.StateNavigation.StateName : null,
                    StateCode = l.StateNavigation != null ? l.StateNavigation.StateCode : null,
                    AreaId = l.AreaId,
                    AreaName = l.AreaNavigation != null ? l.AreaNavigation.AreaName : null,
                    PincodeId = l.PincodeId,
                    PincodeValue = l.PincodeNavigation != null ? l.PincodeNavigation.PincodeValue : null,
                    LocalityName = l.PincodeNavigation != null ? l.PincodeNavigation.LocalityName : null,
                    IsActive = l.IsActive,
                    CreatedAt = l.CreatedAt
                })
                .ToListAsync();
        }

        public async Task<IEnumerable<HierarchicalLocationDto>> GetLocationsByFiltersAsync(int? stateId = null, int? areaId = null, int? pincodeId = null)
        {
            var query = _context.Locations
                .Include(l => l.StateNavigation)
                .Include(l => l.AreaNavigation)
                .Include(l => l.PincodeNavigation)
                .Where(l => l.IsActive);

            if (stateId.HasValue)
                query = query.Where(l => l.StateId == stateId.Value);

            if (areaId.HasValue)
                query = query.Where(l => l.AreaId == areaId.Value);

            if (pincodeId.HasValue)
                query = query.Where(l => l.PincodeId == pincodeId.Value);

            return await query
                .OrderBy(l => l.LocationName)
                .Select(l => new HierarchicalLocationDto
                {
                    LocationId = l.LocationId,
                    LocationName = l.LocationName,
                    StateId = l.StateId,
                    StateName = l.StateNavigation != null ? l.StateNavigation.StateName : null,
                    StateCode = l.StateNavigation != null ? l.StateNavigation.StateCode : null,
                    AreaId = l.AreaId,
                    AreaName = l.AreaNavigation != null ? l.AreaNavigation.AreaName : null,
                    PincodeId = l.PincodeId,
                    PincodeValue = l.PincodeNavigation != null ? l.PincodeNavigation.PincodeValue : null,
                    LocalityName = l.PincodeNavigation != null ? l.PincodeNavigation.LocalityName : null,
                    IsActive = l.IsActive,
                    CreatedAt = l.CreatedAt
                })
                .ToListAsync();
        }

        // Search functionality
        public async Task<IEnumerable<StateDto>> SearchStatesAsync(string searchTerm)
        {
            return await _context.States
                .Where(s => s.IsActive && 
                    (s.StateName.Contains(searchTerm) || s.StateCode.Contains(searchTerm)))
                .OrderBy(s => s.StateName)
                .Select(s => new StateDto
                {
                    StateId = s.StateId,
                    StateName = s.StateName,
                    StateCode = s.StateCode,
                    IsActive = s.IsActive
                })
                .ToListAsync();
        }

        public async Task<IEnumerable<AreaDto>> SearchAreasAsync(string searchTerm, int? stateId = null)
        {
            var query = _context.Areas
                .Include(a => a.City)
                .Where(a => a.IsActive && a.AreaName.Contains(searchTerm));

            if (stateId.HasValue)
                query = query.Where(a => a.City.StateId == stateId.Value);

            return await query
                .OrderBy(a => a.AreaName)
                .Select(a => new AreaDto
                {
                    AreaId = a.AreaId,
                    AreaName = a.AreaName,
                    CityId = a.CityId,
                    CityName = a.City.CityName,
                    IsActive = a.IsActive
                })
                .ToListAsync();
        }

        public async Task<IEnumerable<PincodeDto>> SearchPincodesAsync(string searchTerm, int? areaId = null)
        {
            var query = _context.Pincodes
                .Include(p => p.Area)
                .Where(p => p.IsActive && 
                    (p.PincodeValue.Contains(searchTerm) || 
                     (p.LocalityName != null && p.LocalityName.Contains(searchTerm))));

            if (areaId.HasValue)
                query = query.Where(p => p.AreaId == areaId.Value);

            return await query
                .OrderBy(p => p.PincodeValue)
                .Select(p => new PincodeDto
                {
                    PincodeId = p.PincodeId,
                    PincodeValue = p.PincodeValue,
                    AreaId = p.AreaId,
                    AreaName = p.Area.AreaName,
                    LocalityName = p.LocalityName,
                    IsActive = p.IsActive
                })
                .ToListAsync();
        }

        // Multiple selection and Delhi specific methods
        public async Task<IEnumerable<AreaDto>> GetMultipleAreasAsync(int[] areaIds)
        {
            return await _context.Areas
                .Include(a => a.City)
                .Where(a => a.IsActive && areaIds.Contains(a.AreaId))
                .OrderBy(a => a.AreaName)
                .Select(a => new AreaDto
                {
                    AreaId = a.AreaId,
                    AreaName = a.AreaName,
                    CityId = a.CityId,
                    CityName = a.City.CityName,
                    IsActive = a.IsActive
                })
                .ToListAsync();
        }

        public async Task<IEnumerable<AreaDto>> GetDelhiAreasAsync()
        {
            var delhiState = await _context.States
                .FirstOrDefaultAsync(s => s.StateName == "Delhi" && s.IsActive);

            if (delhiState == null)
                return new List<AreaDto>();

            return await _context.Areas
                .Include(a => a.City)
                .Where(a => a.IsActive && a.City.StateId == delhiState.StateId)
                .OrderBy(a => a.AreaName)
                .Select(a => new AreaDto
                {
                    AreaId = a.AreaId,
                    AreaName = a.AreaName,
                    CityId = a.CityId,
                    CityName = a.City.CityName,
                    IsActive = a.IsActive
                })
                .ToListAsync();
        }

        public async Task<StateDto?> GetDelhiStateAsync()
        {
            var delhiState = await _context.States
                .FirstOrDefaultAsync(s => s.StateName == "Delhi" && s.IsActive);

            if (delhiState == null)
                return null;

            return new StateDto
            {
                StateId = delhiState.StateId,
                StateName = delhiState.StateName,
                StateCode = delhiState.StateCode,
                IsActive = delhiState.IsActive
            };
        }
    }
} 