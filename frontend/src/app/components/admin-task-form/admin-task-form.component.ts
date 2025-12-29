import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { TaskService, TaskCreateDto } from '../../services/task.service';
import { EmployeeService, Employee } from '../../services/employee.service';
import { LocationService, Location } from '../../services/location.service';
import { TaskTypeService, TaskType } from '../../services/task-type.service';
import { TaskStatusService, TaskStatus } from '../../services/task-status.service';
import { NotificationService } from '../../services/notification.service';

@Component({
  selector: 'app-admin-task-form',
  templateUrl: './admin-task-form.component.html',
  styleUrls: ['./admin-task-form.component.css']
})
export class AdminTaskFormComponent implements OnInit {
  taskForm: FormGroup;
  employees: Employee[] = [];
  locations: Location[] = [];
  taskTypes: TaskType[] = [];
  taskStatuses: TaskStatus[] = [];
  selectedTaskTypes: number[] = [];
  selectedLocations: number[] = [];
  isSubmitting = false;

  constructor(
    private fb: FormBuilder,
    private taskService: TaskService,
    private employeeService: EmployeeService,
    private locationService: LocationService,
    private taskTypeService: TaskTypeService,
    private taskStatusService: TaskStatusService,
    private notificationService: NotificationService
  ) {
    this.taskForm = this.fb.group({
      employeeId: ['', Validators.required],
      description: ['', Validators.required],
      priority: ['Medium', Validators.required],
      taskDate: [new Date().toISOString().split('T')[0], Validators.required],
      deadline: ['', Validators.required],
      consultantName: ['', Validators.required],
      campCode: ['', Validators.required],
      employeeCode: ['', Validators.required],
      taskTypeIds: [[]],
      locationIds: [[]],
      customLocation: [''],
      department: ['Marketing'],
      estimatedHours: [0],
      actualHours: [0],
      taskCategory: ['Field Work'],
      additionalNotes: [''],
      isUrgent: [false],
      consultantFeedback: [''],
      stateId: [''],
      cityId: [''],
      areaId: [''],
      pincodeId: [''],
      pincodeValue: ['']
    });
  }

  ngOnInit(): void {
    this.loadEmployees();
    this.loadLocations();
    this.loadTaskTypes();
    this.loadTaskStatuses();
  }

  loadEmployees(): void {
    this.employeeService.getEmployees().subscribe({
      next: (employees) => {
        this.employees = employees;
      },
      error: (error) => {
        console.error('Error loading employees:', error);
      }
    });
  }

  loadLocations(): void {
    this.locationService.getAllLocations().subscribe({
      next: (locations) => {
        this.locations = locations;
      },
      error: (error) => {
        console.error('Error loading locations:', error);
      }
    });
  }

  loadTaskTypes(): void {
    this.taskTypeService.getAllTaskTypes().subscribe({
      next: (taskTypes) => {
        this.taskTypes = taskTypes;
      },
      error: (error) => {
        console.error('Error loading task types:', error);
      }
    });
  }

  loadTaskStatuses(): void {
    this.taskStatusService.getAllTaskStatuses().subscribe({
      next: (taskStatuses) => {
        this.taskStatuses = taskStatuses;
      },
      error: (error) => {
        console.error('Error loading task statuses:', error);
      }
    });
  }

  toggleTaskType(taskTypeId: number): void {
    const index = this.selectedTaskTypes.indexOf(taskTypeId);
    if (index > -1) {
      this.selectedTaskTypes.splice(index, 1);
    } else {
      this.selectedTaskTypes.push(taskTypeId);
    }
    this.taskForm.patchValue({ taskTypeIds: this.selectedTaskTypes });
  }

  toggleLocation(locationId: number): void {
    const index = this.selectedLocations.indexOf(locationId);
    if (index > -1) {
      this.selectedLocations.splice(index, 1);
    } else {
      this.selectedLocations.push(locationId);
    }
    this.taskForm.patchValue({ locationIds: this.selectedLocations });
  }

  onSubmit(): void {
    if (this.taskForm.invalid || this.isSubmitting) {
      return;
    }

    this.isSubmitting = true;
    const formValue = this.taskForm.value;
    
    const taskData: TaskCreateDto = {
      employeeId: formValue.employeeId,
      description: formValue.description,
      priority: formValue.priority,
      taskDate: formValue.taskDate,
      deadline: formValue.deadline,
      consultantName: formValue.consultantName,
      campCode: formValue.campCode,
      employeeCode: formValue.employeeCode,
      taskTypeIds: this.selectedTaskTypes,
      locationIds: this.selectedLocations,
      customLocation: formValue.customLocation,
      department: formValue.department,
      estimatedHours: formValue.estimatedHours,
      actualHours: formValue.actualHours,
      taskCategory: formValue.taskCategory,
      additionalNotes: formValue.additionalNotes,
      isUrgent: formValue.isUrgent,
      consultantFeedback: formValue.consultantFeedback,
      stateId: formValue.stateId,
      cityId: formValue.cityId,
      areaId: formValue.areaId,
      pincodeId: formValue.pincodeId,
      pincodeValue: formValue.pincodeValue
    };

    this.taskService.createTask(taskData).subscribe({
      next: (response) => {
        this.isSubmitting = false;
        console.log('Task created successfully:', response);
        
        // Notify about task creation
        const employee = this.employees.find(e => e.employeeId === formValue.employeeId);
        if (employee) {
          this.notificationService.sendTaskNotification(
            'Task Assigned',
            response.taskId,
            `New task assigned to ${employee.name}`
          );
        }
        
        // Reset form
        this.taskForm.reset({
          priority: 'Medium',
          taskDate: new Date().toISOString().split('T')[0],
          department: 'Marketing',
          taskCategory: 'Field Work',
          estimatedHours: 0,
          actualHours: 0,
          isUrgent: false
        });
        this.selectedTaskTypes = [];
        this.selectedLocations = [];
      },
      error: (error) => {
        this.isSubmitting = false;
        console.error('Error creating task:', error);
        alert('Error creating task. Please try again.');
      }
    });
  }

  isTaskTypeSelected(taskTypeId: number): boolean {
    return this.selectedTaskTypes.includes(taskTypeId);
  }

  isLocationSelected(locationId: number): boolean {
    return this.selectedLocations.includes(locationId);
  }
}