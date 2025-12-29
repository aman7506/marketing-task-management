using MarketingTaskAPI.Models;

namespace MarketingTaskAPI.Services
{
    public interface ILocationService
    {
        // Legacy location methods
        Task<IEnumerable<LocationDto>> GetAllLocationsAsync();
        Task<IEnumerable<LocationDto>> GetLocationsByStateAsync(string state);
        Task<LocationDto?> GetLocationByIdAsync(int locationId);
        Task<LocationDto> CreateLocationAsync(CreateLocationRequest request);
        Task<LocationDto> UpdateLocationAsync(int locationId, CreateLocationRequest request);
        Task<bool> DeleteLocationAsync(int locationId);
        
        // Hierarchical location methods
        Task<IEnumerable<StateDto>> GetAllStatesAsync();
        Task<IEnumerable<AreaDto>> GetAreasByStateAsync(int stateId);
        Task<IEnumerable<PincodeDto>> GetPincodesByAreaAsync(int areaId);
        Task<IEnumerable<HierarchicalLocationDto>> GetHierarchicalLocationsAsync();
        Task<IEnumerable<HierarchicalLocationDto>> GetLocationsByFiltersAsync(int? stateId = null, int? areaId = null, int? pincodeId = null);
        
        // Search functionality
        Task<IEnumerable<StateDto>> SearchStatesAsync(string searchTerm);
        Task<IEnumerable<AreaDto>> SearchAreasAsync(string searchTerm, int? stateId = null);
        Task<IEnumerable<PincodeDto>> SearchPincodesAsync(string searchTerm, int? areaId = null);
        
        // Multiple selection and Delhi specific methods
        Task<IEnumerable<AreaDto>> GetMultipleAreasAsync(int[] areaIds);
        Task<IEnumerable<AreaDto>> GetDelhiAreasAsync();
        Task<StateDto?> GetDelhiStateAsync();
    }
} 