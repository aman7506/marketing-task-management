import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, of, throwError, BehaviorSubject } from 'rxjs';
import { map, catchError, tap } from 'rxjs/operators';
import { environment } from '../../environments/environment';

export interface PincodeLocality {
  pincode: string;
  locality_name: string;
  pincodeId: number;
  areaId: number;
  areaName: string;
  cityId: number;
  cityName: string;
  stateId: number;
  stateName: string;
}

export interface PincodeDropdowns {
  pincodes: string[];
  localities: string[];
}

@Injectable({
  providedIn: 'root'
})
export class PincodeService {
  private apiUrl = environment.apiUrl;
  private localitiesCache = new Map<string, string[]>();

  constructor(private http: HttpClient) {}

  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('token');
    return new HttpHeaders({
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    });
  }

  getPincodeLocalities(): Observable<PincodeLocality[]> {
    return this.http.get<PincodeLocality[]>(`${this.apiUrl}/pincodes/with-localities`, { 
      headers: this.getHeaders() 
    }).pipe(
      catchError((err) => {
        console.error('Error in getPincodeLocalities:', err);
        return throwError(() => err);
      })
    );
  }

  getPincodeDropdowns(): Observable<PincodeDropdowns> {
    return this.http.get<PincodeDropdowns>(`${this.apiUrl}/pincodes/dropdowns`, { 
      headers: this.getHeaders() 
    }).pipe(
      catchError((err) => {
        console.error('Error in getPincodeDropdowns:', err);
        return throwError(() => err);
      })
    );
  }

  getLocalitiesByPincode(pincode: string): Observable<string[]> {
    return this.getPincodeLocalities().pipe(
      map(localities => 
        localities
          .filter(item => item.pincode === pincode)
          .map(item => item.locality_name)
          .filter((name, index, self) => self.indexOf(name) === index) // Remove duplicates
      )
    );
  }

  validatePincodeLocality(pincode: string, localityName: string): Observable<boolean> {
    return this.http.get<{valid: boolean}>(`${this.apiUrl}/pincodes/validate`, {
      headers: this.getHeaders(),
      params: { pincode, localityName }
    }).pipe(
      map(response => response.valid),
      catchError((err) => {
        console.error('Error in validatePincodeLocality:', err);
        return of(false);
      })
    );
  }

  // New methods for distinct pincodes and localities
  getPincodes(): Observable<{pincode: string}[]> {
    return this.http.get<{pincode: string}[]>(`${this.apiUrl}/pincodes/distinct`, { 
      headers: this.getHeaders() 
    }).pipe(
      catchError((err) => {
        console.error('Error in getPincodes:', err);
        return throwError(() => err);
      })
    );
  }

  getLocalities(pincode: string): Observable<string[]> {
    if (this.localitiesCache.has(pincode)) {
      return of(this.localitiesCache.get(pincode)!);
    }
    return this.http.get<string[]>(`${this.apiUrl}/pincodes/${pincode}/localities`, { 
      headers: this.getHeaders() 
    }).pipe(
      tap(localities => this.localitiesCache.set(pincode, localities)),
      catchError((err) => {
        console.error('Error in getLocalities:', err);
        return throwError(() => err);
      })
    );
  }
}