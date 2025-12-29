import { Component, Input, OnInit, Output, EventEmitter } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { EmployeeService } from '../../services/employee.service';
import { LocationService } from '../../services/location.service';
import { TaskService } from '../../services/task.service';
import { NotificationService } from '../../services/notification.service';
import { HierarchicalLocationSelection } from '../hierarchical-location-selector/hierarchical-location-selector.component';
import { HierarchicalLocationSelectorComponent } from '../hierarchical-location-selector/hierarchical-location-selector.component';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule } from '@angular/forms';
import { SearchableDropdownComponent } from '../searchable-dropdown/searchable-dropdown.component';
import { Task } from '../../models/task.model';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-task-assignment',
  templateUrl: './task-assignment.component.html',
  styleUrls: ['./task-assignment.component.css'],
})
export class TaskAssignmentComponent implements OnInit {
  @Input() mode: 'create' | 'edit' | 'view' = 'create';
  @Input() task?: Task;
  @Output() taskUpdated = new EventEmitter<Task>();

  taskForm: FormGroup;

  currentUserRole: string = '';
  canEdit: boolean = true;

  employees: any[] = [];
  employeeOptions: { value: string; label: string }[] = []; // for searchable dropdown
  isDropdownDisabled = false;

  locations: any[] = [];
  taskStatuses: any[] = [];

  showCustomLocation = false;
  isLoading = false;
  showSuccess = false;
  selectedLocationIds: number[] = [];
  selectedTaskTypes: string[] = [];
  hierarchicalLocationSelection: HierarchicalLocationSelection = {};

  availableTaskTypes: { value: string; label: string }[] = [];

  constructor(
    private fb: FormBuilder,
    private router: Router,
    private employeeService: EmployeeService,
    private locationService: LocationService,
    private taskService: TaskService,
    private notificationService: NotificationService,
    private http: HttpClient
  ) {
    this.taskForm = this.fb.group({
      employeeId: ['', Validators.required],
      taskDate: ['', Validators.required],
      locationId: ['', Validators.required],
      customLocation: [''],
      customLocationState: ['Delhi'],
      priority: ['', Validators.required],
      deadline: ['', Validators.required],
      description: ['', [Validators.required, Validators.minLength(10)]],
      status: ['Not Started', Validators.required],

      // Additional fields
      taskType: ['General'],
      department: ['Marketing'],
      clientName: [''],
      projectCode: [''],
      employeeIdNumber: [''],
      estimatedHours: [''],
      taskCategory: ['Field Work'],
      additionalNotes: [''],
      isUrgent: [false]
    });
  }

  ngOnInit() {
    this.loadCurrentUserRole();
    this.checkEditPermission();

    if (this.mode === 'edit' && this.task) {
      this.populateForm();
    }

    this.loadEmployees();
    this.loadLocations();
    this.loadTaskTypes();
    this.loadTaskStatuses();
  }

  loadEmployees() {
    this.employeeService.getEmployees().subscribe({
      next: (data) => {
        this.employees = data;
        // Map employees to dropdown format
        this.employeeOptions = data.map((emp: any) => ({
          value: emp.id.toString(),
          label: emp.name
        }));
        console.log('Employees loaded:', this.employeeOptions);
      },
      error: (error) => {
        console.error('Error loading employees:', error);
      }
    });
  }

  loadLocations() {
    this.locationService.getAllLocations().subscribe({
      next: (data: any) => {
        this.locations = data;
        console.log('Locations loaded:', data);
      },
      error: (error: any) => {
        console.error('Error loading locations:', error);
      }
    });
  }

  loadTaskTypes() {
    this.taskService.getTaskTypes().subscribe({
      next: (data) => {
        // If data is empty, use default task types
        if (data && data.length > 0) {
          this.availableTaskTypes = data.map((type: any) => ({
            value: type.name,
            label: type.name
          }));
        } else {
          this.availableTaskTypes = [
            { value: 'General', label: 'General' },
            { value: 'Marketing Campaign', label: 'Marketing Campaign' },
            { value: 'Client Meeting', label: 'Client Meeting' },
            { value: 'Field Survey', label: 'Field Survey' },
            { value: 'Data Collection', label: 'Data Collection' },
            { value: 'Report Generation', label: 'Report Generation' },
            { value: 'Training', label: 'Training' },
            { value: 'Event Management', label: 'Event Management' }
          ];
        }
        console.log('Task types loaded:', this.availableTaskTypes);
      },
      error: (error) => {
        console.error('Error loading task types:', error);
        // Fallback to default task types
        this.availableTaskTypes = [
          { value: 'General', label: 'General' },
          { value: 'Marketing Campaign', label: 'Marketing Campaign' },
          { value: 'Client Meeting', label: 'Client Meeting' },
          { value: 'Field Survey', label: 'Field Survey' },
          { value: 'Data Collection', label: 'Data Collection' },
          { value: 'Report Generation', label: 'Report Generation' },
          { value: 'Training', label: 'Training' },
          { value: 'Event Management', label: 'Event Management' }
        ];
      }
    });
  }

  loadTaskStatuses() {
    const token = localStorage.getItem('token');
    const headers = {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    };

    this.http.get<any>(`${environment.apiUrl}/dropdowns/statuses`, { headers }).subscribe({
      next: (data) => {
        this.taskStatuses = data;
        console.log('Task statuses loaded:', data);
      },
      error: (error) => {
        console.error('Error loading task statuses:', error);
        // Fallback to default statuses
        this.taskStatuses = [
          { id: 1, name: 'Not Started' },
          { id: 2, name: 'In Progress' },
          { id: 3, name: 'Completed' },
          { id: 4, name: 'Postponed' },
          { id: 5, name: 'Partial Close' }
        ];
      }
    });
  }

  onEmployeeSelect(selectedEmployeeId: string) {
    console.log('Employee selected:', selectedEmployeeId);
    this.taskForm.patchValue({ employeeId: selectedEmployeeId });
  }

  onLocationChange(event: any) {
    const selectedValue = event.target.value;
    if (selectedValue === 'custom') {
      this.showCustomLocation = true;
      this.taskForm.patchValue({
        locationId: '',
        customLocation: '',
        customLocationState: 'Delhi'
      });
      this.taskForm.get('customLocation')?.setValidators([Validators.required]);
      this.taskForm.get('locationId')?.clearValidators();
    } else {
      this.showCustomLocation = false;
      this.taskForm.get('customLocation')?.clearValidators();
      this.taskForm.get('locationId')?.setValidators([Validators.required]);
    }
    this.taskForm.get('customLocation')?.updateValueAndValidity();
    this.taskForm.get('locationId')?.updateValueAndValidity();
  }

  onLocationSelectionChange(event: any, locationId: number) {
    if (event.target.checked) {
      if (!this.selectedLocationIds.includes(locationId)) {
        this.selectedLocationIds.push(locationId);
      }
    } else {
      this.selectedLocationIds = this.selectedLocationIds.filter(id => id !== locationId);
    }
  }

  onCustomLocationToggle(event: any) {
    this.showCustomLocation = event.target.checked;
    if (this.showCustomLocation) {
      this.taskForm.get('customLocation')?.setValidators([Validators.required]);
    } else {
      this.taskForm.get('customLocation')?.clearValidators();
      this.taskForm.patchValue({ customLocation: '', customLocationState: 'Delhi' });
    }
    this.taskForm.get('customLocation')?.updateValueAndValidity();
  }

  onTaskTypeSelectionChange(event: any, taskType: string) {
    if (event.target.checked) {
      if (!this.selectedTaskTypes.includes(taskType)) {
        this.selectedTaskTypes.push(taskType);
      }
    } else {
      this.selectedTaskTypes = this.selectedTaskTypes.filter(type => type !== taskType);
    }
  }

  onSubmit() {
    if (this.mode === 'view' || !this.canEdit) {
      return;
    }

    if (this.taskForm.valid) {
      this.isLoading = true;
      this.showSuccess = false;

      const formData = this.taskForm.value;
      const taskData: any = {
        employeeId: parseInt(formData.employeeId),
        taskDate: formData.taskDate,
        priority: formData.priority,
        deadline: formData.deadline,
        description: formData.description,
        stateName: this.hierarchicalLocationSelection.stateName || '',
        cityName: this.hierarchicalLocationSelection.cityName || '',
        // Remove area field and replace with pincode and localityName
        pincode: this.hierarchicalLocationSelection.pincodeValue || '',
        localityName: this.hierarchicalLocationSelection.localityName || '',
        locationId: this.showCustomLocation ? null : (this.selectedLocationIds.length > 0 ? this.selectedLocationIds[0] : null),
        customLocation: this.showCustomLocation ? formData.customLocation : null,

        // Multiple selections support - use correct field names for backend
        LocationIds: this.selectedLocationIds.length > 0 ? this.selectedLocationIds : [],
        TaskTypeIds: [], // Will be populated based on task types

        // Extra fields
        taskType: this.selectedTaskTypes.length > 0 ? this.selectedTaskTypes[0] : 'General',
        department: formData.department || 'Marketing',
        clientName: formData.clientName || null,
        projectCode: formData.projectCode || null,
        estimatedHours: formData.estimatedHours ? parseFloat(formData.estimatedHours) : null,
        taskCategory: formData.taskCategory || 'Field Work',
        additionalNotes: formData.additionalNotes || null,
        isUrgent: formData.isUrgent || false
      };

      // Hierarchical data
      if (this.hierarchicalLocationSelection.stateId) {
        taskData.stateId = this.hierarchicalLocationSelection.stateId;
        taskData.stateName = this.hierarchicalLocationSelection.stateName;
      }
      if (this.hierarchicalLocationSelection.cityId) {
        taskData.cityId = this.hierarchicalLocationSelection.cityId;
        taskData.cityName = this.hierarchicalLocationSelection.cityName;
      }
      if (this.hierarchicalLocationSelection.areaIds?.length) {
        taskData.areaId = this.hierarchicalLocationSelection.areaIds[0]; // Use first area ID
        taskData.areaName = this.hierarchicalLocationSelection.areaNames?.[0] || '';
      }
      if (this.hierarchicalLocationSelection.pincodeId) {
        taskData.pincodeId = this.hierarchicalLocationSelection.pincodeId;
        taskData.pincodeValue = this.hierarchicalLocationSelection.pincodeValue;
        taskData.localityName = this.hierarchicalLocationSelection.localityName;
      }

      console.log('Populating form with task data:', taskData);

      if (this.mode === 'create') {
        this.taskService.createTask(taskData).subscribe({
          next: (response) => {
            this.isLoading = false;
            this.showSuccess = true;
            this.resetForm();

            console.log('Task created successfully:', response);
            this.notificationService.showNotification('Task assigned successfully!');

            setTimeout(() => {
              this.showSuccess = false;
              this.router.navigate(['/admin/dashboard']);
            }, 2000);
          },
          error: (error) => {
            console.error('Error creating task:', error);
            this.isLoading = false;
            this.notificationService.showNotification('Error creating task. Please try again.', 'error');
          }
        });
      } else if (this.mode === 'edit' && this.task) {
        this.taskService.updateTask(this.task.taskId, taskData).subscribe({
          next: (response) => {
            this.isLoading = false;
            this.showSuccess = true;
            this.taskUpdated.emit(response);

            console.log('Task updated successfully:', response);
            this.notificationService.showNotification('Task updated successfully!');

            setTimeout(() => {
              this.showSuccess = false;
              this.router.navigate(['/admin/dashboard']);
            }, 2000);
          },
          error: (error) => {
            console.error('Error updating task:', error);
            this.isLoading = false;
            this.notificationService.showNotification('Error updating task. Please try again.', 'error');
          }
        });
      }
    } else {
      this.markFormGroupTouched();
    }
  }

  resetForm() {
    this.taskForm.reset({
      customLocationState: 'Delhi',
      taskType: 'General',
      department: 'Marketing',
      taskCategory: 'Field Work',
      status: 'Not Started',
      isUrgent: false
    });
    this.showCustomLocation = false;
    this.selectedLocationIds = [];
    this.selectedTaskTypes = [];
    this.hierarchicalLocationSelection = {};
    this.taskForm.get('customLocation')?.clearValidators();
    this.taskForm.get('locationId')?.setValidators([Validators.required]);
    this.taskForm.get('customLocation')?.updateValueAndValidity();
    this.taskForm.get('locationId')?.updateValueAndValidity();
  }

  private markFormGroupTouched() {
    Object.keys(this.taskForm.controls).forEach(key => {
      const control = this.taskForm.get(key);
      control?.markAsTouched();
    });
  }

  onHierarchicalLocationChange(selection: HierarchicalLocationSelection) {
    this.hierarchicalLocationSelection = selection;
    console.log('Hierarchical location selection changed:', selection);
  }

  // --- Template Getters ---
  get employeeId() { return this.taskForm.get('employeeId'); }
  get taskDate() { return this.taskForm.get('taskDate'); }
  get locationId() { return this.taskForm.get('locationId'); }
  get customLocation() { return this.taskForm.get('customLocation'); }
  get priority() { return this.taskForm.get('priority'); }
  get deadline() { return this.taskForm.get('deadline'); }
  get description() { return this.taskForm.get('description'); }
  get taskType() { return this.taskForm.get('taskType'); }
  get department() { return this.taskForm.get('department'); }
  get clientName() { return this.taskForm.get('clientName'); }
  get projectCode() { return this.taskForm.get('projectCode'); }
  get estimatedHours() { return this.taskForm.get('estimatedHours'); }
  get taskCategory() { return this.taskForm.get('taskCategory'); }
  get additionalNotes() { return this.taskForm.get('additionalNotes'); }
  get isUrgent() { return this.taskForm.get('isUrgent'); }
  get status() { return this.taskForm.get('status'); }

  loadCurrentUserRole() {
    this.taskService.getCurrentUserRole().subscribe({
      next: (role: string) => {
        this.currentUserRole = role;
        this.checkEditPermission();
      },
      error: (error: any) => {
        console.error('Error loading user role:', error);
        this.currentUserRole = 'user'; // default
        this.checkEditPermission();
      }
    });
  }

  checkEditPermission() {
    if (this.mode === 'view') {
      this.canEdit = false;
      return;
    }

    if (!this.task) {
      this.canEdit = true; // For create mode
      return;
    }

    // Admin can edit everything
    if (this.currentUserRole === 'admin') {
      this.canEdit = true;
      return;
    }

    // Non-admin can edit if assigned and not completed
    const isAssigned = this.task.employeeId === this.getCurrentUserEmployeeId();
    const isNotCompleted = this.task.status !== 'Completed';
    this.canEdit = isAssigned && isNotCompleted;
  }

  private getCurrentUserEmployeeId(): number {
    // Assume stored in localStorage or service
    const user = JSON.parse(localStorage.getItem('user') || '{}');
    return user.employeeId || 0;
  }

  private populateForm() {
    if (this.task) {
      this.taskForm.patchValue({
        employeeId: this.task.employeeId.toString(),
        taskDate: this.task.taskDate,
        deadline: this.task.deadline,
        description: this.task.description,
        priority: this.task.priority,
        status: this.task.status,
        taskType: this.task.taskType,
        department: this.task.department,
        clientName: this.task.clientName,
        projectCode: this.task.projectCode,
        estimatedHours: this.task.estimatedHours,
        taskCategory: this.task.taskCategory,
        additionalNotes: this.task.additionalNotes,
        isUrgent: this.task.isUrgent
      });

      // Handle location
      this.showCustomLocation = !!this.task.customLocation;
      if (this.task.customLocation) {
        this.taskForm.patchValue({ customLocation: this.task.customLocation });
      }

      // Set hierarchical location if available
      if (this.task.stateId) {
        this.hierarchicalLocationSelection.stateId = this.task.stateId;
        this.hierarchicalLocationSelection.stateName = this.task.stateName || undefined;
      }

      if (this.task.cityId) {
        this.hierarchicalLocationSelection.cityId = this.task.cityId;
        this.hierarchicalLocationSelection.cityName = this.task.cityName || undefined;
      }

      if (this.task.areaId) {
        this.hierarchicalLocationSelection.areaIds = [this.task.areaId];
        this.hierarchicalLocationSelection.areaNames = [this.task.areaName || ''];
      }

      if (this.task.pincodeId) {
        this.hierarchicalLocationSelection.pincodeId = this.task.pincodeId;
        this.hierarchicalLocationSelection.pincodeValue = this.task.pincodeValue || undefined;
      }

      // Set selectedTaskTypes if multiple
      if (this.task.taskType) {
        this.selectedTaskTypes = [this.task.taskType];
      }

      // Set locationId if available
      if (this.task.locationId) {
        this.selectedLocationIds = [this.task.locationId];
      }
    }
  }
}
