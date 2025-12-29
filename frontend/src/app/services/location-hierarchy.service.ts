import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { map, catchError } from 'rxjs/operators';

// Simple interfaces for location data
export interface LocationOption {
    id: number;
    name: string;
}

export interface PincodeOption {
    id: number;
    value: string;
    localityName: string;
}

@Injectable({
    providedIn: 'root'
})
export class LocationHierarchyService {
    private readonly baseUrl = 'http://localhost:5005/api/locations';

    constructor(private http: HttpClient) { }

    /**
     * Get all states
     * Returns: [{ id: 1, name: "Delhi" }, { id: 2, name: "Haryana" }]
     */
    getStates(): Observable<LocationOption[]> {
        return this.http.get<LocationOption[]>(`${this.baseUrl}/states`).pipe(
            catchError(err => {
                console.error('Error fetching states:', err);
                return of([]);
            })
        );
    }

    /**
     * Get cities for a specific state
     * Returns: [{ id: 4, name: "Gurugram" }, { id: 5, name: "Gurgaon" }]
     */
    getCitiesByState(stateId: number): Observable<LocationOption[]> {
        if (!stateId) {
            return of([]);
        }

        return this.http.get<LocationOption[]>(`${this.baseUrl}/cities?stateId=${stateId}`).pipe(
            catchError(err => {
                console.error('Error fetching cities:', err);
                return of([]);
            })
        );
    }

    /**
     * Get localities for a specific city
     * Returns: [{ id: 20, name: "Gurugram Cyber City" }, ...]
     */
    getLocalitiesByCity(cityId: number): Observable<LocationOption[]> {
        if (!cityId) {
            return of([]);
        }

        return this.http.get<LocationOption[]>(`${this.baseUrl}/localities?cityId=${cityId}`).pipe(
            catchError(err => {
                console.error('Error fetching localities:', err);
                return of([]);
            })
        );
    }

    /**
     * Get pincodes for a specific locality
     * Returns: [{ id: 28, value: "122002", localityName: "Cyber City" }]
     */
    getPincodesByLocality(localityId: number): Observable<PincodeOption[]> {
        if (!localityId) {
            return of([]);
        }

        return this.http.get<PincodeOption[]>(`${this.baseUrl}/pincodes?localityId=${localityId}`).pipe(
            catchError(err => {
                console.error('Error fetching pincodes:', err);
                return of([]);
            })
        );
    }
}
