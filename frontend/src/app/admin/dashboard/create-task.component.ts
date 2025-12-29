import { Component, OnInit, Input } from '@angular/core';
import { FormGroup, FormBuilder, Validators } from '@angular/forms';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { LocationService } from '../../services/location.service';
import { TaskService, TaskCreateDto } from '../../services/task.service';
import { TaskType, CreateTaskRequest } from '../../models/task.model';
import { State, City, Area } from '../../models/location.models';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule } from '@angular/forms';

@Component({
  selector: 'app-create-task',
  templateUrl: './create-task.component.html',
  styleUrls: ['./create-task.component.css'],
})
export class CreateTaskComponent implements OnInit {
  @Input() employeeData: any[] = [];
  @Input() taskTypes: TaskType[] = [];
  @Input() departments: any[] = [];
  
  taskForm!: FormGroup;
  states: State[] = [];
  cities: City[] = [];
  areas: Area[] = [];

  constructor(
    public activeModal: NgbActiveModal,
    private fb: FormBuilder,
    private locationService: LocationService,
    private taskService: TaskService
  ) {
    this.createForm();
  }

  ngOnInit() {
    this.loadStates();
  }

  private createForm() {
    this.taskForm = this.fb.group({
      employeeId: ['', Validators.required],
      taskDate: ['', Validators.required],
      state: ['', Validators.required],
      city: [''],
      area: ['', Validators.required],
      pincode: [''],
      priority: ['', Validators.required],
      deadline: ['', Validators.required],
      taskType: [''],
      department: ['']
    });
  }

  async loadStates() {
    const states = await this.locationService.getAllStates().toPromise();
    if (states) {
      this.states = states;
    }
  }

  async onStateChange() {
    const stateControl = this.taskForm.get('state');
    if (stateControl && stateControl.value) {
      const cities = await this.locationService.getCitiesByState(stateControl.value).toPromise();
      if (cities) {
        this.cities = cities;
        this.taskForm.patchValue({ city: '', area: '', pincode: '' });
      }
    }
  }

  async onCityChange() {
    const cityControl = this.taskForm.get('city');
    if (cityControl && cityControl.value) {
      const areas = await this.locationService.getAreasByCity(cityControl.value).toPromise();
      if (areas) {
        this.areas = areas;
        this.taskForm.patchValue({ area: '', pincode: '' });
      }
    }
  }

  async onAreaChange() {
    const areaControl = this.taskForm.get('area');
    if (areaControl && areaControl.value) {
      const pincodes = await this.locationService.getPincodesByArea(areaControl.value).toPromise();
      if (pincodes && pincodes.length > 0) {
        this.taskForm.patchValue({ pincode: pincodes[0] });
      }
    }
  }

  async onSubmit() {
    if (this.taskForm.valid) {
      try {
        const formData = this.taskForm.value;
        // Convert dates to ISO strings
        if (formData.taskDate) {
          formData.taskDate = new Date(formData.taskDate).toISOString();
        }
        if (formData.deadline) {
          formData.deadline = new Date(formData.deadline).toISOString();
        }
        
        // Convert IDs to strings where needed and add required fields for TaskCreateDto
        const taskRequest: TaskCreateDto = {
          ...formData,
          stateId: Number(formData.state),
          cityId: Number(formData.city),
          areaId: Number(formData.area),
          taskType: formData.taskType ? String(formData.taskType) : undefined,
          // Add required fields from TaskCreateDto that are missing in CreateTaskRequest
          taskTypeIds: formData.taskType ? [Number(formData.taskType)] : [],
          locationIds: [],
          description: "Task description", // Add a default description
          isUrgent: false // Default value
        };
        
        await this.taskService.createTask(taskRequest).toPromise();
        this.activeModal.close(true);
      } catch (error) {
        console.error('Error creating task:', error);
      }
    }
  }
}