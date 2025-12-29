import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { environment } from '../../environments/environment';
import { State, City, Area, Pincode } from '../models/location.models';

export interface Location {
  locationId: number;
  locationName: string;
  address?: string;
  stateId?: number;
  stateName?: string;
  cityId?: number;
  cityName?: string;
  areaId?: number;
  areaName?: string;
  pincodeId?: number;
  pincodeValue?: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data: T;
  error?: string;
}

@Injectable({
  providedIn: 'root'
})
export class LocationService {
  private apiUrl = `${environment.apiUrl}`;

  constructor(private http: HttpClient) { }

  getAllLocations(): Observable<Location[]> {
    return this.http.get<Location[]>(`${this.apiUrl}/locations`);
  }

  getLocationById(id: number): Observable<Location> {
    return this.http.get<Location>(`${this.apiUrl}/locations/${id}`);
  }

  createLocation(location: Partial<Location>): Observable<Location> {
    return this.http.post<Location>(`${this.apiUrl}/locations`, location);
  }

  updateLocation(id: number, location: Partial<Location>): Observable<any> {
    return this.http.put<any>(`${this.apiUrl}/locations/${id}`, location);
  }

  deleteLocation(id: number): Observable<any> {
    return this.http.delete<any>(`${this.apiUrl}/locations/${id}`);
  }

  // States API
  getAllStates(): Observable<State[]> {
    return this.http.get<ApiResponse<State[]>>(`${this.apiUrl}/states`).pipe(
      map(response => {
        if (response && response.success) {
          return response.data;
        } else if (Array.isArray(response)) {
          // Handle direct array response
          return response;
        } else {
          return [];
        }
      })
    );
  }

  // Cities API
  getCitiesByState(stateId: number): Observable<City[]> {
    return this.http.get<ApiResponse<City[]>>(`${this.apiUrl}/cities?stateId=${stateId}`).pipe(
      map(response => {
        if (response && response.success) {
          return response.data;
        } else if (Array.isArray(response)) {
          return response;
        } else {
          return [];
        }
      })
    );
  }

  getAllCities(): Observable<City[]> {
    return this.http.get<ApiResponse<City[]>>(`${this.apiUrl}/cities`).pipe(
      map(response => {
        if (response && response.success) {
          return response.data;
        } else if (Array.isArray(response)) {
          return response;
        } else {
          return [];
        }
      })
    );
  }

  // Areas API
  getAreasByCity(cityId: number): Observable<Area[]> {
    return this.http.get<ApiResponse<Area[]>>(`${this.apiUrl}/areas?cityId=${cityId}`).pipe(
      map(response => {
        if (response && response.success) {
          return response.data;
        } else if (Array.isArray(response)) {
          return response;
        } else {
          return [];
        }
      })
    );
  }

  getAreasByState(stateId: number): Observable<Area[]> {
    return this.http.get<ApiResponse<Area[]>>(`${this.apiUrl}/areas?stateId=${stateId}`).pipe(
      map(response => response.success ? response.data : [])
    );
  }

  getAllAreas(): Observable<Area[]> {
    return this.http.get<ApiResponse<Area[]>>(`${this.apiUrl}/areas`).pipe(
      map(response => response.success ? response.data : [])
    );
  }

  // Pincodes API
  getPincodesByArea(areaId: number): Observable<Pincode[]> {
    return this.http.get<ApiResponse<Pincode[]>>(`${this.apiUrl}/pincodes?areaId=${areaId}`).pipe(
      map(response => response.success ? response.data : [])
    );
  }

  getAllPincodes(): Observable<Pincode[]> {
    return this.http.get<ApiResponse<Pincode[]>>(`${this.apiUrl}/pincodes`).pipe(
      map(response => response.success ? response.data : [])
    );
  }

  getPincodesWithLocalities(): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/pincodes/with-localities`);
  }

  getPincodeLocalityDropdowns(): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/pincodes/dropdowns`);
  }

  validatePincodeLocality(pincode: string, localityName: string): Observable<{ valid: boolean }> {
    return this.http.get<{ valid: boolean }>(`${this.apiUrl}/pincodes/validate?pincode=${encodeURIComponent(pincode)}&localityName=${encodeURIComponent(localityName)}`);
  }

  getLocalitiesByPincode(pincode: string): Observable<string[]> {
    return this.http.get<string[]>(`${this.apiUrl}/pincodes/${encodeURIComponent(pincode)}/localities`);
  }

  searchStates(term: string): Observable<State[]> {
    return this.http.get<ApiResponse<State[]>>(`${this.apiUrl}/states/search?term=${encodeURIComponent(term)}`).pipe(
      map(response => response.success ? response.data : [])
    );
  }

  searchCities(term: string, stateId?: number): Observable<City[]> {
    let url = `${this.apiUrl}/cities/search?term=${encodeURIComponent(term)}`;
    if (stateId) url += `&stateId=${stateId}`;
    return this.http.get<ApiResponse<City[]>>(url).pipe(
      map(response => response.success ? response.data : [])
    );
  }

  searchAreas(term: string, stateId?: number, cityId?: number): Observable<Area[]> {
    let url = `${this.apiUrl}/areas/search?term=${encodeURIComponent(term)}`;
    if (stateId) url += `&stateId=${stateId}`;
    if (cityId) url += `&cityId=${cityId}`;
    return this.http.get<ApiResponse<Area[]>>(url).pipe(
      map(response => response.success ? response.data : [])
    );
  }


  // New methods for locality-based pincode fetching
  getLocalitiesByArea(areaId: number): Observable<any[]> {
    return this.http.get<ApiResponse<any[]>>(`${this.apiUrl}/pincodes/localities?areaId=${areaId}`).pipe(
      map(response => {
        if (response && response.success) {
          return response.data;
        } else if (Array.isArray(response)) {
          return response;
        } else {
          return [];
        }
      })
    );
  }

  getLocalitiesByCity(cityId: number): Observable<{ id: number, name: string }[]> {
    return this.http.get<{ id: number, name: string }[]>(`${this.apiUrl}/locations/localities?cityId=${cityId}`);
  }

  getPincodesByLocality(localityName: string, areaId?: number): Observable<string[]> {
    // Get the area/locality ID by name first
    if (!areaId && localityName) {
      // Need to find the AreaId from locality name - for now return empty
      // This should be handled by passing the areaId from component
      return new Observable(observer => {
        observer.next([]);
        observer.complete();
      });
    }

    if (areaId) {
      return this.http.get<{ id: number, value: string, localityName: string }[]>(
        `${this.apiUrl}/locations/pincodes?localityId=${areaId}`
      ).pipe(
        map(pincodes => pincodes.map(p => p.value)) // Extract just the pincode value
      );
    }

    return new Observable(observer => {
      observer.next([]);
      observer.complete();
    });
  }

  // Get all localities for an area
  getLocalitiesForArea(areaId: number): Observable<any[]> {
    return this.http.get<ApiResponse<any[]>>(`${this.apiUrl}/pincodes/area-localities?areaId=${areaId}`).pipe(
      map(response => {
        if (response && response.success) {
          return response.data;
        } else if (Array.isArray(response)) {
          return response;
        } else {
          return [];
        }
      })
    );
  }

  // Get all pincodes for an area
  getPincodesForArea(areaId: number): Observable<any[]> {
    return this.http.get<ApiResponse<any[]>>(`${this.apiUrl}/pincodes/area-pincodes?areaId=${areaId}`).pipe(
      map(response => {
        if (response && response.success) {
          return response.data;
        } else if (Array.isArray(response)) {
          return response;
        } else {
          return [];
        }
      })
    );
  }

  // Get all pincode data from database
  getAllPincodeData(): Observable<any[]> {
    return this.http.get<ApiResponse<any[]>>(`${this.apiUrl}/pincodes/all-data`).pipe(
      map(response => {
        if (response && response.success) {
          return response.data;
        } else if (Array.isArray(response)) {
          return response;
        } else {
          return [];
        }
      })
    );
  }

  // Search pincodes with optional filters
  searchLocalities(searchTerm?: string, areaId?: number): Observable<any[]> {
    let url = `${this.apiUrl}/pincodes/search-localities`;
    const params = new URLSearchParams();

    if (searchTerm) {
      params.append('searchTerm', searchTerm);
    }
    if (areaId) {
      params.append('areaId', areaId.toString());
    }

    if (params.toString()) {
      url += `?${params.toString()}`;
    }

    return this.http.get<ApiResponse<any[]>>(url).pipe(
      map(response => {
        if (response && response.success) {
          return response.data;
        } else if (Array.isArray(response)) {
          return response;
        } else {
          return [];
        }
      })
    );
  }

  searchPincodes(searchTerm?: string, areaId?: number): Observable<any[]> {
    let url = `${this.apiUrl}/pincodes/search`;
    const params = new URLSearchParams();

    if (searchTerm) params.append('searchTerm', searchTerm);
    if (areaId) params.append('areaId', areaId.toString());

    if (params.toString()) {
      url += `?${params.toString()}`;
    }

    return this.http.get<ApiResponse<any[]>>(url).pipe(
      map(response => {
        if (response && response.success) {
          return response.data;
        } else if (Array.isArray(response)) {
          return response;
        } else {
          return [];
        }
      })
    );
  }

  getPincodeLocalityData(): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/pincode-locality-data`);
  }
}
