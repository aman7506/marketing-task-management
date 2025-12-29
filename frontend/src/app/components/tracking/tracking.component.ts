import { Component, OnDestroy, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import * as L from 'leaflet';
import { Subject, takeUntil } from 'rxjs';
import { Employee, EmployeeService } from '../../services/employee.service';
import { TrackingService } from '../../services/tracking.service';
import { LocationLog } from '../../models/location-log.model';

interface DemoRoute {
  start: [number, number];
  end: [number, number];
  waypoints: number;
  intervalSeconds: number;
  label: string;
}

// Fix for Leaflet default icon not showing - Use CDN URLs
const iconDefault = L.icon({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41],
  shadowAnchor: [13, 41]
});

// Set as default for all markers
L.Marker.prototype.options.icon = iconDefault;

@Component({
  selector: 'app-tracking',
  templateUrl: './tracking.component.html',
  styleUrls: ['./tracking.component.css']
})
export class TrackingComponent implements OnInit, OnDestroy {
  employees: Employee[] = [];
  selectedEmployeeId: number | null = null;
  latestLocation: LocationLog | null = null;
  statusMessage = 'Select an employee to start live tracking.';
  isConnecting = false;
  isSimulating = false;
  simulationForm: FormGroup;

  private map?: L.Map;
  private marker?: L.Marker;
  private pathLine?: L.Polyline;
  private pathPoints: L.LatLng[] = [];
  private readonly destroy$ = new Subject<void>();
  private readonly indiaBounds = L.latLngBounds([6.0, 68.0], [37.0, 97.0]);
  private readonly defaultRouteId = 1;
  private readonly demoRoutes: Record<number, DemoRoute> = {
    1: {
      start: [28.6139, 77.2090],
      end: [28.667756, 77.116316],
      waypoints: 80,
      intervalSeconds: 1,
      label: 'Connaught Place → Sri Balaji Action Medical Institute'
    },
    14: {
      start: [28.6412, 77.2195],
      end: [28.667756, 77.116316],
      waypoints: 70,
      intervalSeconds: 1,
      label: 'Test Route to Sri Balaji Action Medical Institute (Paschim Vihar)'
    }
  };

  constructor(
    private readonly employeeService: EmployeeService,
    private readonly trackingService: TrackingService,
    private readonly fb: FormBuilder
  ) {
    this.simulationForm = this.fb.group({
      startLatitude: [28.6139, [Validators.required, Validators.min(-90), Validators.max(90)]],
      startLongitude: [77.2090, [Validators.required, Validators.min(-180), Validators.max(180)]],
      endLatitude: [28.4595, [Validators.required, Validators.min(-90), Validators.max(90)]],
      endLongitude: [77.0266, [Validators.required, Validators.min(-180), Validators.max(180)]],
      waypoints: [60, [Validators.required, Validators.min(50), Validators.max(500)]],
      intervalSeconds: [1, [Validators.required, Validators.min(1), Validators.max(2)]]
    });

    this.applyDemoRouteForEmployee(this.defaultRouteId, false);
  }

  ngOnInit(): void {
    this.loadEmployees();
    this.initMap();
    this.applyDemoRouteForEmployee(this.defaultRouteId);
    this.trackingService.locationUpdates$
      .pipe(takeUntil(this.destroy$))
      .subscribe(update => this.handleLocationUpdate(update));
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
    this.trackingService.disconnect();
    if (this.map) {
      this.map.remove();
    }
  }

  onEmployeeChange(event: Event): void {
    const value = Number((event.target as HTMLSelectElement).value);
    this.selectedEmployeeId = Number.isNaN(value) ? null : value;
    this.applyDemoRouteForEmployee(this.selectedEmployeeId);
    if (this.selectedEmployeeId) {
      this.startTracking(this.selectedEmployeeId);
    } else {
      this.statusMessage = 'Select a valid employee to begin tracking.';
    }
  }

  startSimulation(): void {
    if (!this.selectedEmployeeId) {
      this.statusMessage = 'Select an employee before simulating a trip.';
      return;
    }

    if (this.simulationForm.invalid) {
      this.simulationForm.markAllAsTouched();
      return;
    }

    this.isSimulating = true;
    const payload = {
      employeeId: this.selectedEmployeeId,
      ...this.simulationForm.value
    };

    this.trackingService.simulateTrip(payload).subscribe({
      next: () => {
        this.statusMessage = 'Simulation initiated. Watch the map for live updates.';
        this.isSimulating = false;
      },
      error: (error) => {
        console.error('Simulation error', error);
        this.statusMessage = 'Unable to start simulation. Please verify backend connectivity.';
        this.isSimulating = false;
      }
    });
  }

  private loadEmployees(): void {
    this.employeeService.getEmployees().subscribe({
      next: (employees) => {
        this.employees = employees;
        if (employees.length && !this.selectedEmployeeId) {
          this.selectedEmployeeId = employees[0].employeeId;
          this.startTracking(this.selectedEmployeeId);
        }
      },
      error: (error) => {
        console.error('Unable to load employees', error);
        this.statusMessage = 'Unable to load employees. Please ensure backend is reachable.';
      }
    });
  }

  private startTracking(employeeId: number): void {
    this.isConnecting = true;
    this.statusMessage = 'Connecting to live tracking service...';
    this.trackingService.connect(employeeId)
      .then(() => {
        this.isConnecting = false;
        this.statusMessage = 'Live tracking active.';
      })
      .catch(error => {
        console.error('Tracking connection error', error);
        this.isConnecting = false;
        this.statusMessage = 'Unable to connect to tracking hub. Please retry.';
      });

    this.trackingService.getLatestLocation(employeeId).subscribe({
      next: (location) => {
        if (location) {
          this.handleLocationUpdate(location);
        } else {
          this.handleMissingHistory(employeeId);
        }
      },
      error: (error) => {
        if (error.status === 404) {
          this.handleMissingHistory(employeeId);
        } else {
          console.error('Unable to load latest location', error);
          this.statusMessage = 'Unable to load the latest location. Please try again.';
        }
      }
    });
  }

  private initMap(): void {
    if (this.map) {
      return;
    }

    this.map = L.map('trackingMap', {
      zoomControl: true,
      maxBounds: this.indiaBounds,
      maxBoundsViscosity: 1.0
    }).setView([28.6139, 77.2090], 6);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap contributors',
      minZoom: 4,
      maxZoom: 18
    }).addTo(this.map);

    // Ensure map is fully loaded before rendering markers
    this.map.whenReady(() => {
      // If we have a latest location, render it
      if (this.latestLocation) {
        const latLng = L.latLng(this.latestLocation.latitude, this.latestLocation.longitude);
        this.renderMarkerAt(latLng, false);
      }
    });
  }

  private handleLocationUpdate(update: LocationLog): void {
    this.latestLocation = update;
    const latLng = L.latLng(update.latitude, update.longitude);

    if (!this.indiaBounds.contains(latLng)) {
      this.statusMessage = 'Received coordinates outside India bounds.';
      return;
    }

    this.renderMarkerAt(latLng, true);
    this.statusMessage = `Live location for employee ${update.employeeId}: ${latLng.lat.toFixed(4)}, ${latLng.lng.toFixed(4)}`;
  }

  private handleMissingHistory(employeeId: number): void {
    this.latestLocation = null;
    this.statusMessage = 'No location history yet. Use "Simulate Trip" to generate a sample route.';
    this.applyDemoRouteForEmployee(employeeId);
  }

  private applyDemoRouteForEmployee(employeeId: number | null, preview: boolean = true): void {
    const route = (employeeId && this.demoRoutes[employeeId]) || this.demoRoutes[this.defaultRouteId];
    if (!route) {
      return;
    }

    this.simulationForm.patchValue(
      {
        startLatitude: route.start[0],
        startLongitude: route.start[1],
        endLatitude: route.end[0],
        endLongitude: route.end[1],
        waypoints: route.waypoints,
        intervalSeconds: route.intervalSeconds
      },
      { emitEvent: false }
    );

    if (preview) {
      this.previewStaticPosition(route);
    }
  }

  private previewStaticPosition(route: DemoRoute): void {
    const target = L.latLng(route.end[0], route.end[1]);
    
    // Ensure map is initialized
    if (!this.map) {
      this.initMap();
    }
    
    // Wait for map to be ready, then render marker
    if (this.map) {
      this.map.whenReady(() => {
        // Use setTimeout to ensure map tiles are loaded
        setTimeout(() => {
          this.renderMarkerAt(target, false);
        }, 100);
      });
    }
    
    this.statusMessage = `Previewing ${route.label}. Click "Simulate Trip" to animate the route.`;
  }

  private renderMarkerAt(position: L.LatLng, appendToPath: boolean = true): void {
    if (!this.map) {
      this.initMap();
    }

    // Ensure map is initialized before proceeding
    if (!this.map) {
      console.error('Map not initialized');
      return;
    }

    // Create or update marker with proper Leaflet icon
    if (!this.marker) {
      this.marker = L.marker(position, {
        icon: iconDefault,
        zIndexOffset: 1000, // Ensure marker is above other layers
        riseOnHover: true
      }).addTo(this.map);
      
      // Add popup with employee info
      const employeeName = this.employees.find(e => e.employeeId === this.selectedEmployeeId)?.name || 'Employee';
      this.marker.bindPopup(`<strong>${employeeName}</strong><br>Lat: ${position.lat.toFixed(6)}<br>Lng: ${position.lng.toFixed(6)}`).openPopup();
    } else {
      // Update existing marker position
      this.marker.setLatLng(position);
      // Update popup content
      const employeeName = this.employees.find(e => e.employeeId === this.selectedEmployeeId)?.name || 'Employee';
      this.marker.setPopupContent(`<strong>${employeeName}</strong><br>Lat: ${position.lat.toFixed(6)}<br>Lng: ${position.lng.toFixed(6)}`);
    }

    // Ensure marker is visible
    if (this.marker && !this.map.hasLayer(this.marker)) {
      this.marker.addTo(this.map);
    }

    // Handle path line
    if (!this.pathLine) {
      this.pathLine = L.polyline([position], {
        color: '#06b6d4',
        weight: 4,
        opacity: 0.8
      }).addTo(this.map);
      this.pathPoints = [position];
    } else if (appendToPath) {
      this.pathPoints.push(position);
      if (this.pathPoints.length > 200) {
        this.pathPoints.shift();
      }
      this.pathLine.setLatLngs(this.pathPoints);
    } else {
      this.pathPoints = [position];
      this.pathLine.setLatLngs(this.pathPoints);
    }

    // Pan map to marker with animation
    this.map.flyTo(position, 14, { 
      duration: 1,
      animate: true
    });
  }
}

