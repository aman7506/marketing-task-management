import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { HubConnection, HubConnectionBuilder, HubConnectionState, LogLevel } from '@microsoft/signalr';
import { BehaviorSubject, Observable, filter } from 'rxjs';
import { environment } from '../../environments/environment';
import { LocationLog, SimulateTripRequest } from '../models/location-log.model';

@Injectable({
  providedIn: 'root'
})
export class TrackingService {
  private hubConnection?: HubConnection;
  private readonly locationSubject = new BehaviorSubject<LocationLog | null>(null);
  private currentlyTrackedEmployeeId: number | null = null;
  private readonly baseUrl = `${environment.apiUrl}/tracking`;

  locationUpdates$: Observable<LocationLog> = this.locationSubject
    .asObservable()
    .pipe(filter((value): value is LocationLog => value !== null));

  constructor(private http: HttpClient) {}

  connect(employeeId: number): Promise<void> {
    this.currentlyTrackedEmployeeId = employeeId;

    if (this.hubConnection && this.hubConnection.state === HubConnectionState.Connected) {
      return Promise.resolve();
    }

    if (!this.hubConnection) {
      this.hubConnection = this.buildHubConnection(environment.trackingHubUrl ?? environment.signalRHubUrl);

      this.hubConnection.on('ReceiveLocationUpdate', (payload: LocationLog) => {
        if (!payload) {
          return;
        }

        if (this.currentlyTrackedEmployeeId && payload.employeeId !== this.currentlyTrackedEmployeeId) {
          return;
        }

        this.locationSubject.next(payload);
      });
    }

    return this.hubConnection
      .start()
      .catch(error => {
        console.error('Tracking hub connection failed, retrying with LAN URL...', error);
        if (environment.lanTrackingHubUrl) {
          this.hubConnection = this.buildHubConnection(environment.lanTrackingHubUrl);
          this.hubConnection.on('ReceiveLocationUpdate', (payload: LocationLog) => {
            if (!payload) {
              return;
            }
            if (this.currentlyTrackedEmployeeId && payload.employeeId !== this.currentlyTrackedEmployeeId) {
              return;
            }
            this.locationSubject.next(payload);
          });
          return this.hubConnection.start();
        }
        throw error;
      });
  }

  disconnect(): void {
    if (this.hubConnection && this.hubConnection.state !== HubConnectionState.Disconnected) {
      this.hubConnection.stop().catch(err => console.error('Error stopping tracking hub', err));
    }
  }

  getLatestLocation(employeeId: number): Observable<LocationLog> {
    return this.http.get<LocationLog>(`${this.baseUrl}/${employeeId}/latest`);
  }

  getRecentLocations(employeeId: number, hours = 4, max = 200): Observable<LocationLog[]> {
    return this.http.get<LocationLog[]>(`${this.baseUrl}/${employeeId}/history`, {
      params: {
        hours,
        max
      } as any
    });
  }

  simulateTrip(request: SimulateTripRequest): Observable<any> {
    return this.http.post(`${this.baseUrl}/simulate-trip`, request);
  }

  private buildHubConnection(url: string): HubConnection {
    const token = localStorage.getItem('token') ?? '';

    return new HubConnectionBuilder()
      .withUrl(url, {
        accessTokenFactory: () => token
      })
      .withAutomaticReconnect({
        nextRetryDelayInMilliseconds: retryContext => Math.min((retryContext.previousRetryCount + 1) * 2000, 10000)
      })
      .configureLogging(LogLevel.Information)
      .build();
  }
}

