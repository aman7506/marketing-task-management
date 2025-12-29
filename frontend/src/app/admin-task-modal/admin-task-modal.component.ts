import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-admin-task-modal',
  templateUrl: './admin-task-modal.component.html',
  styleUrls: ['./admin-task-modal.component.css']
})
export class AdminTaskModalComponent implements OnInit {
  form: FormGroup;
  locations: any[] = [];
  states: any[] = [];
  areas: any[] = [];
  pincodes: any[] = [];
  employees: any[] = [];
  taskTypes: any[] = [];

  // derived lists
  cities: any[] = [];
  filteredAreas: any[] = [];
  filteredPincodes: any[] = [];

  priorities = ['Low', 'Medium', 'High'];
  statuses = ['Not Started', 'In Progress', 'Completed', 'Postponed', 'Partial Close'];
  categories = ['Field Work', 'Office Work', 'Client Work', 'Administrative'];
  departments = ['Marketing', 'Operations', 'Sales', 'Research', 'Administration'];
  apiUrl = environment.apiUrl;

  constructor(private fb: FormBuilder, private http: HttpClient) {
    this.form = this.fb.group({
      title: ['', Validators.required],
      stateId: [null, Validators.required],
      city: [null],
      areaId: [null],
      pincodeId: [null],
      locationId: [null],
      employeeId: [null, Validators.required],
      taskTypeId: [null],
      priority: ['Medium', Validators.required],
      status: ['Not Started', Validators.required],
      category: ['Field Work'],
      department: [null],
      description: ['']
    });
  }

  ngOnInit(): void {
    this.loadDropdowns();

    // react to state change
    this.form.get('stateId')?.valueChanges.subscribe((stateId: any) => {
      this.onStateChange(stateId);
    });

    // react to city change
    this.form.get('city')?.valueChanges.subscribe((city: any) => {
      this.onCityChange(city);
    });

    // react to area change
    this.form.get('areaId')?.valueChanges.subscribe((areaId: any) => {
      this.onAreaChange(areaId);
    });
  }

  loadDropdowns(): void {
    this.loadLocations();
    this.loadStates();
    this.loadAreas();
    this.loadPincodes();
    this.loadEmployees();
    this.loadTaskTypes();
  }

  loadLocations(): void {
    const url = `${this.apiUrl}/locations`;
    this.http.get<any[]>(url).subscribe(
      data => {
        this.locations = data || [];
      },
      err => console.error('Error loading locations: ', err)
    );
  }

  loadStates(): void {
    const url = `${this.apiUrl}/locations/states`;
    this.http.get<any[]>(url).subscribe(
      data => this.states = data || [],
      err => console.error('Error loading states: ', err)
    );
  }

  loadAreas(): void {
    const url = `${this.apiUrl}/areas`;
    this.http.get<any[]>(url).subscribe(
      data => this.areas = data || [],
      err => console.error('Error loading areas: ', err)
    );
  }

  loadPincodes(): void {
    const url = `${this.apiUrl}/pincodes`;
    this.http.get<any[]>(url).subscribe(
      data => this.pincodes = data || [],
      err => console.error('Error loading pincodes: ', err)
    );
  }

  loadEmployees(): void {
    const url = `${this.apiUrl}/employees`;
    this.http.get<any[]>(url).subscribe(
      data => this.employees = data || [],
      err => console.error('Error loading employees: ', err)
    );
  }

  loadTaskTypes(): void {
    const url = `${this.apiUrl}/tasktypes`;
    this.http.get<any[]>(url).subscribe(
      data => this.taskTypes = data || [],
      err => console.error('Error loading task types: ', err)
    );
  }

  onStateChange(stateId: number | null) {
    if (!stateId) {
      this.cities = [];
      this.filteredAreas = [];
      this.filteredPincodes = [];
      return;
    }

    // derive cities from locations matching stateId
    const citiesSet = new Set<string>();
    this.locations.forEach(loc => {
      if (loc.stateId === stateId || loc.stateId === Number(stateId)) {
        if (loc.locationName) citiesSet.add(loc.locationName);
      }
    });
    this.cities = Array.from(citiesSet).map(c => ({ name: c }));

    // filter areas for state
    this.filteredAreas = this.areas.filter(a => a.stateId === stateId || a.stateId === Number(stateId));

    // clear dependent fields
    this.form.patchValue({ city: null, areaId: null, pincodeId: null, locationId: null });
  }

  onCityChange(cityName: string | null) {
    if (!cityName) {
      this.filteredPincodes = [];
      return;
    }

    // find locations matching selected city name
    const matchingLocations = this.locations.filter(l => l.locationName === cityName);
    // areas from matching locations
    const areaIds = new Set<number>();
    matchingLocations.forEach(l => { if (l.areaId) areaIds.add(l.areaId); });

    this.filteredAreas = this.areas.filter(a => areaIds.has(a.areaId));

    // pincodes from matching locations
    const pincodeIds = new Set<number>();
    matchingLocations.forEach(l => { if (l.pincodeId) pincodeIds.add(l.pincodeId); });
    this.filteredPincodes = this.pincodes.filter(p => pincodeIds.has(p.pincodeId));

    // clear dependent selections
    this.form.patchValue({ areaId: null, pincodeId: null, locationId: null });
  }

  onAreaChange(areaId: number | null) {
    if (!areaId) {
      this.filteredPincodes = [];
      return;
    }

    const pIds = new Set<number>();
    this.locations.forEach(l => { if (l.areaId === areaId || l.areaId === Number(areaId)) { if (l.pincodeId) pIds.add(l.pincodeId); } });
    this.filteredPincodes = this.pincodes.filter(p => pIds.has(p.pincodeId));

    // clear pincode selection
    this.form.patchValue({ pincodeId: null, locationId: null });
  }

  submit(): void {
    if (this.form.invalid) return;
    const url = `${this.apiUrl}/tasks`;
    const payload = this.form.getRawValue();
    this.http.post(url, payload).subscribe(
      res => console.log('Task saved', res),
      err => console.error('Error saving task', err)
    );
  }
}
