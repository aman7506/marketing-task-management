import { Component, Input, Output, EventEmitter, OnInit, OnDestroy, ChangeDetectorRef, OnChanges, SimpleChanges } from '@angular/core';
import { FormBuilder, FormGroup, Validators, AbstractControl, ValidationErrors } from '@angular/forms';
import { TaskService, Task, TaskCreateDto, TaskUpdateDto } from '../../services/task.service';
import { EmployeeService, Employee } from '../../services/employee.service';
import { LocationService } from '../../services/location.service';
import { LocationHierarchyService, LocationOption, PincodeOption } from '../../services/location-hierarchy.service';
import { TaskStatus, TaskStatusService } from '../../services/task-status.service';
import { NotificationService } from '../../services/notification.service';
import { PincodeService, PincodeLocality } from '../../services/pincode.service';
import { TaskType } from '../../services/task-type.service';
import { State, City, Area } from '../../models/location.models';
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';

export function deadlineAfterTaskDateValidator(control: AbstractControl): ValidationErrors | null {
  const taskDate = control.get('taskDate')?.value;
  const deadline = control.get('deadline')?.value;
  if (!taskDate || !deadline) {
    return null;
  }
  const taskDateObj = new Date(taskDate);
  const deadlineObj = new Date(deadline);
  if (deadlineObj < taskDateObj) {
    return { deadlineNotAfterTaskDate: true };
  }
  return null;
}

@Component({
  selector: 'app-admin-task-modal',
  templateUrl: './admin-task-modal.component.html',
  styleUrls: ['./admin-task-modal.component.css'],
})
export class AdminTaskModalComponent implements OnInit, OnDestroy, OnChanges {
  @Input() task: Task | null = null;
  @Input()
  set show(value: boolean) {
    this._show = value;
    if (value) {
      this.dataLoaded = false;
      this.loadModalData();
    } else {
      this.resetModal();
    }
  }
  get show() { return this._show; }
  private _show = false;

  @Input() mode: 'create' | 'edit' | 'view' = 'view';
  @Output() close = new EventEmitter<void>();
  @Output() taskSaved = new EventEmitter<Task>();
  @Output() taskDeleted = new EventEmitter<number>();
  @Output() taskCreated = new EventEmitter<void>();

  taskForm: FormGroup;
  employees: Employee[] = [];
  states: any[] = [];
  cities: any[] = [];
  areas: Area[] = [];
  taskTypes: TaskType[] = [];
  isSubmitting = false;
  isDeleting = false;
  showDeleteConfirm = false;
  private dataLoaded = false;

  manualLocationEntry = false;
  locationForm!: FormGroup;
  pincodeOptions: string[] = [];
  localitySuggestions: string[] = [];
  private pincodeLocalityRecords: PincodeLocality[] = [];

  private destroy$ = new Subject<void>();

  priorityOptions = [
    { value: 'Low', label: 'Low' },
    { value: 'Medium', label: 'Medium' },
    { value: 'High', label: 'High' },
    { value: 'Urgent', label: 'Urgent' }
  ];

  statusOptions: { value: string; label: string }[] = [];
  taskTypeOptions: { value: string; label: string }[] = [];

  categoryOptions: { value: string; label: string }[] = [
    { value: 'Field Work', label: 'Field Work' },
    { value: 'Office Work', label: 'Office Work' },
    { value: 'Marketing', label: 'Marketing' },
    { value: 'Sales', label: 'Sales' },
    { value: 'Support', label: 'Support' }
  ];

  private readonly fallbackStatusOptions: { value: string; label: string }[] = [
    { value: 'Not Started', label: 'Not Started' },
    { value: 'In Progress', label: 'In Progress' },
    { value: 'Completed', label: 'Completed' },
    { value: 'On Hold', label: 'On Hold' },
    { value: 'Postponed', label: 'Postponed' }
  ];

  private readonly fallbackTaskTypeOptions: { value: string; label: string }[] = [
    { value: 'General', label: 'General' },
    { value: 'Marketing Campaign', label: 'Marketing Campaign' },
    { value: 'Client Meeting', label: 'Client Meeting' },
    { value: 'Field Survey', label: 'Field Survey' },
    { value: 'Data Collection', label: 'Data Collection' },
    { value: 'Report Generation', label: 'Report Generation' },
    { value: 'Training', label: 'Training' },
    { value: 'Event Management', label: 'Event Management' },
    { value: 'Meeting Consultant', label: 'Meeting Consultant' }
  ];

  private readonly taskTypeDictionary: Record<string, string> = {
    '1': 'General',
    '2': 'Marketing Campaign',
    '3': 'Client Meeting',
    '4': 'Field Survey',
    '5': 'Data Collection',
    '6': 'Report Generation',
    '7': 'Training',
    '8': 'Event Management',
    '9': 'Meeting Consultant'
  };

  private readonly fallbackPincodes: string[] = ['110001', '400001', '560001', '600001', '700001'];
  private readonly fallbackLocalities: string[] = [
    'Connaught Place',
    'Bandra West',
    'Indiranagar',
    'T Nagar',
    'Salt Lake'
  ];

  constructor(
    private fb: FormBuilder,
    private taskService: TaskService,
    private employeeService: EmployeeService,
    private locationService: LocationService,
    private locationHierarchyService: LocationHierarchyService,
    private taskStatusService: TaskStatusService,
    private notificationService: NotificationService,
    private pincodeService: PincodeService,
    private cdr: ChangeDetectorRef
  ) {
    this.taskForm = this.fb.group({
      description: ['', [Validators.required, Validators.minLength(5)]],
      employeeName: ['', Validators.required],
      priority: ['Medium', Validators.required],
      status: ['Not Started', Validators.required],
      taskDate: ['', Validators.required],
      deadline: ['', Validators.required],
      stateId: ['', Validators.required],
      cityId: ['', Validators.required],
      areaId: [''],
      pincode: ['', [Validators.required, Validators.pattern(/^\d{6}$/)]],
      localityName: [''],
      taskType: ['', Validators.required],
      isUrgent: [false],
      department: [''],
      taskCategory: [''],
      clientName: [''],
      projectCode: [''],
      estimatedHours: [0],
      actualHours: [0],
      additionalNotes: ['']
    }, { validators: deadlineAfterTaskDateValidator });

    this.statusOptions = [...this.fallbackStatusOptions];
    this.taskTypeOptions = [...this.fallbackTaskTypeOptions];
  }

  ngOnInit(): void {
    this.locationForm = this.fb.group({
      stateId: ['', Validators.required],
      cityId: ['', Validators.required],
      localityName: ['', Validators.required],
      pincode: ['', Validators.required],
      stateName: [''], // manual
      cityName: [''], // manual
      localityNameInput: [''], // manual
      pincodeManual: [''], // manual
    });
  }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['task'] && this.task) {
      this.populateForm();
    }
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  get description() { return this.taskForm.get('description'); }
  get employeeName() { return this.taskForm.get('employeeName'); }
  get priority() { return this.taskForm.get('priority'); }
  get status() { return this.taskForm.get('status'); }
  get taskDate() { return this.taskForm.get('taskDate'); }
  get deadline() { return this.taskForm.get('deadline'); }
  get stateId() { return this.taskForm.get('stateId'); }
  get cityId() { return this.taskForm.get('cityId'); }
  get areaId() { return this.taskForm.get('areaId'); }
  get pincode() { return this.taskForm.get('pincode'); }
  get localityName() { return this.taskForm.get('localityName'); }
  get taskType() { return this.taskForm.get('taskType'); }

  populateForm(): void {
    if (!this.task) return;
    this.taskForm.patchValue({
      description: this.task.description,
      employeeName: this.task.employeeName,
      priority: this.task.priority,
      status: this.task.status,
      taskDate: this.task.taskDate,
      deadline: this.task.deadline,
      stateId: this.task.stateId,
      cityId: this.task.cityId,
      areaId: this.task.areaId,
      pincode: this.task.pincodeId ? this.task.pincodeId.toString() : '',
      localityName: this.task.localityName,
      taskType: this.task.taskType || '',
      isUrgent: this.task.isUrgent
    });

    if (this.task.stateId) {
      this.onStateChange(this.task.stateId);
    }
    if (this.task.cityId) {
      this.onCityChange(this.task.cityId);
    }
    if (this.task.pincodeId) {
      this.onPincodeChange(this.task.pincodeId.toString());
    }
  }

  loadModalData(): void {
    if (this.dataLoaded) return;
    this.dataLoaded = true;

    this.employeeService.getEmployees().pipe(takeUntil(this.destroy$)).subscribe({
      next: employees => {
        this.employees = employees;
        this.cdr.detectChanges();
      },
      error: err => console.error('Error loading employees', err)
    });

    this.locationService.getAllStates().pipe(takeUntil(this.destroy$)).subscribe({
      next: states => {
        this.states = states;
        this.cdr.detectChanges();
      },
      error: err => console.error('Error loading states', err)
    });

    this.taskStatusService.getAllTaskStatuses().pipe(takeUntil(this.destroy$)).subscribe({
      next: statuses => {
        this.statusOptions = this.formatStatusOptions(statuses);
        this.cdr.detectChanges();
      },
      error: err => {
        console.error('Error loading task statuses', err);
        this.statusOptions = [...this.fallbackStatusOptions];
        this.cdr.detectChanges();
      }
    });

    this.taskService.getTaskTypes().pipe(takeUntil(this.destroy$)).subscribe({
      next: types => {
        this.taskTypeOptions = this.formatTaskTypeOptions(types);
        this.cdr.detectChanges();
      },
      error: err => {
        console.error('Error loading task types', err);
        this.taskTypeOptions = [...this.fallbackTaskTypeOptions];
        this.cdr.detectChanges();
      }
    });

    this.pincodeService.getPincodeLocalities().pipe(takeUntil(this.destroy$)).subscribe({
      next: records => {
        this.pincodeLocalityRecords = Array.isArray(records) ? records : [];
        this.setPincodeOptionsFromRecords(this.pincodeLocalityRecords);
      },
      error: err => {
        console.error('Error loading pincode localities', err);
        this.setPincodeOptions(this.fallbackPincodes);
      }
    });
  }

  onManualToggle(event?: any) {
    if (event && typeof event.target?.checked === 'boolean') {
      this.manualLocationEntry = event.target.checked;
    } else {
      this.manualLocationEntry = !this.manualLocationEntry;
    }
    if (this.manualLocationEntry) {
      this.locationForm.get('stateId')?.disable();
      this.locationForm.get('cityId')?.disable();
      this.locationForm.get('localityName')?.disable();
      this.locationForm.get('pincode')?.disable();
      this.locationForm.get('stateName')?.enable();
      this.locationForm.get('cityName')?.enable();
      this.locationForm.get('localityNameInput')?.enable();
      this.locationForm.get('pincodeManual')?.enable();
      // Remove required validators in manual
      this.locationForm.get('stateName')?.setValidators(null);
      this.locationForm.get('cityName')?.setValidators(null);
      this.locationForm.get('localityNameInput')?.setValidators(null);
      this.locationForm.get('pincodeManual')?.setValidators(null);
      this.locationForm.updateValueAndValidity();
    } else {
      this.locationForm.get('stateId')?.enable();
      this.locationForm.get('cityId')?.enable();
      this.locationForm.get('localityName')?.enable();
      this.locationForm.get('pincode')?.enable();
      this.locationForm.get('stateName')?.disable();
      this.locationForm.get('cityName')?.disable();
      this.locationForm.get('localityNameInput')?.disable();
      this.locationForm.get('pincodeManual')?.disable();
      // Restore required validators
      this.locationForm.get('stateId')?.setValidators(Validators.required);
      this.locationForm.get('cityId')?.setValidators(Validators.required);
      this.locationForm.get('localityName')?.setValidators(Validators.required);
      this.locationForm.get('pincode')?.setValidators(Validators.required);
      this.locationForm.updateValueAndValidity();
    }
  }

  onStateChange(stateId: number): void {
    console.log('🔍 STATE CHANGED TO:', stateId);

    if (!stateId) {
      this.cities = [];
      this.localitySuggestions = [];
      this.pincodeOptions = [];
      this.taskForm.patchValue({
        cityId: null,
        areaId: null,
        localityName: '',
        pincode: ''
      });
      console.log('⚠️ State cleared, cities reset');
      return;
    }

    // Reset dependent fields
    this.localitySuggestions = [];
    this.pincodeOptions = [];
    this.taskForm.patchValue({
      cityId: null,
      areaId: null,
      localityName: '',
      pincode: ''
    });

    console.log('📡 Fetching cities for stateId:', stateId);
    this.locationService.getCitiesByState(stateId).subscribe({
      next: cities => {
        console.log('🏙️ CITIES LOADED:', cities);
        this.cities = cities;
        this.taskForm.get('cityId')?.enable();
        this.cdr.detectChanges();
        console.log('✅ Cities dropdown should now show', this.cities.length, 'cities');
      },
      error: err => {
        console.error('❌ ERROR loading cities:', err);
        this.cities = [];
      }
    });
  }

  onCityChange(cityId: number): void {
    console.log('🏙️ CITY CHANGED TO:', cityId);

    if (!cityId) {
      this.localitySuggestions = [];
      this.taskForm.patchValue({
        areaId: null,
        localityName: ''
      });
      this.pincodeOptions = [];
      console.log('⚠️ City cleared, localities reset');
      return;
    }

    console.log('📡 Fetching localities for cityId:', cityId);
    this.locationHierarchyService.getLocalitiesByCity(cityId).subscribe({
      next: localities => {
        console.log('🏘️ LOCALITIES LOADED:', localities);
        // Store as objects for dropdown binding
        this.localitySuggestions = localities.map(l => l.name);

        // Also store the full locality objects for ID lookup
        (this as any).localityObjects = localities;

        this.taskForm.get('localityName')?.enable();
        this.cdr.detectChanges();
        console.log('✅ Localities dropdown should now show', this.localitySuggestions.length, 'localities');
      },
      error: err => {
        console.error('❌ ERROR loading localities:', err);
        this.localitySuggestions = [];
      }
    });
  }

  onLocalityChange(localityName: string): void {
    console.log('🏘️ LOCALITY CHANGED TO:', localityName);

    if (!localityName) {
      this.pincodeOptions = [];
      this.taskForm.patchValue({
        areaId: null,
        pincode: ''
      });
      console.log('⚠️ Locality cleared, pincodes reset');
      return;
    }

    // Find the locality object to get its ID
    const localityObjects = (this as any).localityObjects || [];
    const selectedLocality = localityObjects.find((l: any) => l.name === localityName);

    console.log('🔍 Looking for locality object:', localityName, 'in', localityObjects);
    console.log('✅ Found locality:', selectedLocality);

    if (selectedLocality) {
      const areaId = selectedLocality.id;

      // Store the AreaId for saving
      this.taskForm.patchValue({
        areaId: areaId
      });

      console.log('📡 Fetching pincodes for localityId/areaId:', areaId);
      // Fetch pincodes using the areaId
      this.locationHierarchyService.getPincodesByLocality(areaId).subscribe({
        next: pincodes => {
          console.log('📮 PINCODES LOADED:', pincodes);
          // Extract just the pincode values as strings
          this.pincodeOptions = pincodes.map(p => p.value);
          this.cdr.detectChanges();
          // If only one, auto-select
          if (this.pincodeOptions.length === 1) {
            this.taskForm.get('pincode')?.setValue(this.pincodeOptions[0]);
          }
          console.log('✅ Pincodes dropdown should now show', this.pincodeOptions.length, 'pincodes');
        },
        error: err => {
          console.error('❌ ERROR loading pincodes:', err);
          this.pincodeOptions = [];
        }
      });
    } else {
      console.warn('⚠️ Locality object not found for:', localityName);
    }
  }

  onPincodeChange(pincode: string): void {
    if (!pincode) {
      this.localitySuggestions = [];
      this.locationForm.get('localityName')?.disable();
      this.locationForm.get('pincode')?.disable();
      this.locationForm.get('pincodeManual')?.disable();
      this.locationForm.get('localityNameInput')?.disable();
      this.locationForm.get('localityNameInput')?.setValue('');
      this.locationForm.get('pincodeManual')?.setValue('');
      return;
    }
    const trimmed = (pincode || '').toString().trim();
    this.locationForm.get('localityNameInput')?.disable();
    this.locationForm.get('localityNameInput')?.setValue('');
    this.locationForm.get('pincodeManual')?.disable();
    this.locationForm.get('pincodeManual')?.setValue('');

    const cachedMatches = this.pincodeLocalityRecords.filter(record =>
      this.normalizePincode(record) === trimmed
    );
    const cachedNames = this.extractLocalityNames(cachedMatches);
    if (cachedNames.length) {
      this.setLocalitySuggestions(cachedNames);
      this.locationForm.get('localityName')?.enable();
      this.locationForm.get('pincode')?.enable();
      this.locationForm.get('pincodeManual')?.disable();
      this.locationForm.get('localityNameInput')?.disable();
      this.locationForm.get('localityNameInput')?.setValue('');
      this.locationForm.get('pincodeManual')?.setValue('');
      return;
    }

    this.pincodeService.getLocalities(trimmed).pipe(takeUntil(this.destroy$)).subscribe({
      next: localities => {
        const names = this.extractLocalityNames(localities);
        this.setLocalitySuggestions(names.length ? names : this.fallbackLocalities);
        this.locationForm.get('localityName')?.enable();
        this.locationForm.get('pincode')?.enable();
        this.locationForm.get('pincodeManual')?.disable();
        this.locationForm.get('localityNameInput')?.disable();
        this.locationForm.get('localityNameInput')?.setValue('');
        this.locationForm.get('pincodeManual')?.setValue('');
      },
      error: err => {
        console.error('Error loading localities', err);
        this.setLocalitySuggestions(this.fallbackLocalities);
        this.locationForm.get('localityName')?.enable();
        this.locationForm.get('pincode')?.enable();
        this.locationForm.get('pincodeManual')?.disable();
        this.locationForm.get('localityNameInput')?.disable();
        this.locationForm.get('localityNameInput')?.setValue('');
        this.locationForm.get('pincodeManual')?.setValue('');
      }
    });
  }

  onSubmit(): void {
    if (this.taskForm.invalid) {
      // Show which fields are invalid
      const invalidFields: string[] = [];
      Object.keys(this.taskForm.controls).forEach(key => {
        const control = this.taskForm.get(key);
        if (control && control.invalid) {
          invalidFields.push(key);
          control.markAsTouched();
        }
      });

      console.error('❌ Invalid fields:', invalidFields);
      console.log('📋 Current form values:', this.taskForm.value);
      console.log('📋 Form errors:', this.taskForm.errors);

      Object.keys(this.taskForm.controls).forEach(control => {
        this.taskForm.get(control)?.markAsTouched();
      });

      this.notificationService.showNotification(
        `Please fill all required fields correctly. Invalid: ${invalidFields.join(', ')}`,
        'error'
      );
      return;
    }
    this.isSubmitting = true;
    const formValue = this.taskForm.value;

    // Find employee ID from employee name
    const selectedEmployee = this.employees.find(emp => emp.name === formValue.employeeName);
    const employeeId = selectedEmployee ? selectedEmployee.employeeId : 1; // Default to 1 if not found

    console.log('📋 SUBMITTING TASK:', {
      employeeName: formValue.employeeName,
      employeeId,
      stateId: formValue.stateId,
      cityId: formValue.cityId,
      areaId: formValue.areaId,
      localityName: formValue.localityName,
      pincode: formValue.pincode
    });

    if (this.mode === 'create') {
      // Align request body with backend TaskCreateDto / sp_InsertTask expectations
      const createDto: TaskCreateDto = {
        description: formValue.description,
        employeeId: employeeId, // Convert employee name to ID
        priority: formValue.priority,
        taskDate: formValue.taskDate ? new Date(formValue.taskDate).toISOString() : new Date().toISOString(),
        deadline: formValue.deadline ? new Date(formValue.deadline).toISOString() : new Date().toISOString(),
        // Location hierarchy
        stateId: formValue.stateId ? Number(formValue.stateId) : undefined,
        cityId: formValue.cityId ? Number(formValue.cityId) : undefined,
        // map localityId -> areaId
        areaId: formValue.areaId ? Number(formValue.areaId) : (formValue.localityId ? Number(formValue.localityId) : undefined),
        localityName: formValue.localityName || formValue.localityNameInput || undefined,
        pincodeId: formValue.pincodeId ? Number(formValue.pincodeId) : undefined,
        pincodeValue: formValue.pincode || formValue.pincodeValue || undefined,
        // Optional fields
        customLocation: formValue.customLocation || undefined,
        taskType: formValue.taskType || 'General',
        department: formValue.department || 'Marketing',
        taskCategory: formValue.taskCategory || 'Field Work',
        additionalNotes: formValue.additionalNotes || undefined,
        isUrgent: formValue.isUrgent || false,
        estimatedHours: formValue.estimatedHours ? Number(formValue.estimatedHours) : undefined,
        actualHours: formValue.actualHours ? Number(formValue.actualHours) : undefined,
      };

      console.log('📤 SENDING CREATE DTO:', createDto);

      this.taskService.createTask(createDto).subscribe({
        next: (task) => {
          console.log('✅ TASK CREATED:', task);
          this.notificationService.showNotification('Task created successfully', 'success');
          this.taskCreated.emit();
          this.closeModal();
        },
        error: (err) => {
          console.error('❌ ERROR CREATING TASK:', err);
          this.notificationService.showNotification('Error creating task: ' + (err.error?.error || err.message), 'error');
          this.isSubmitting = false;
        }
      });
    } else if (this.mode === 'edit' && this.task) {
      const updateDto: any = {
        taskId: this.task.taskId,
        ...formValue,
        employeeId: employeeId,
        stateId: formValue.stateId || null,
        cityId: formValue.cityId || null,
        areaId: formValue.areaId || null,
        localityName: formValue.localityName || null,
        pincode: formValue.pincode || null,
        pincodeValue: formValue.pincode || null
      };

      console.log('📤 SENDING UPDATE DTO:', updateDto);

      this.taskService.updateTask(this.task.taskId, updateDto).subscribe({
        next: (task) => {
          console.log('✅ TASK UPDATED:', task);
          this.notificationService.showNotification('Task updated successfully', 'success');
          this.taskSaved.emit(task);
          this.closeModal();
        },
        error: (err) => {
          console.error('❌ ERROR UPDATING TASK:', err);
          this.notificationService.showNotification('Error updating task: ' + (err.error?.error || err.message), 'error');
          this.isSubmitting = false;
        }
      });
    }
  }

  closeModal(): void {
    this.resetModal();
    this.close.emit();
  }

  onClose(): void {
    this.closeModal();
  }

  confirmDelete(): void {
    this.showDeleteConfirm = true;
  }

  cancelDelete(): void {
    this.showDeleteConfirm = false;
  }

  deleteTask(): void {
    if (!this.task) return;
    this.isDeleting = true;
    this.taskService.deleteTask(this.task.taskId).subscribe({
      next: () => {
        this.notificationService.showNotification('Task deleted successfully', 'success');
        this.taskDeleted.emit(this.task!.taskId);
        this.closeModal();
      },
      error: () => {
        this.notificationService.showNotification('Error deleting task', 'error');
        this.isDeleting = false;
      }
    });
  }

  resetModal(): void {
    this.taskForm.reset();
    this.showDeleteConfirm = false;
    this.isSubmitting = false;
    this.isDeleting = false;
    // Remove disables to allow dropdowns to always be enabled except manual
    // Manual mode disables handled in onManualToggle
  }

  private formatStatusOptions(statuses: TaskStatus[] | null | undefined): { value: string; label: string }[] {
    if (!statuses || !statuses.length) {
      return [...this.fallbackStatusOptions];
    }
    return statuses.map(status => ({
      value: status.statusName,
      label: status.statusName
    }));
  }

  private formatTaskTypeOptions(types: TaskType[] | null | undefined): { value: string; label: string }[] {
    if (!types || !types.length) {
      return [...this.fallbackTaskTypeOptions];
    }

    const mapped = types.map(raw => {
      if (typeof raw === 'number' || typeof raw === 'string') {
        const key = String(raw);
        const labelFromDict = this.taskTypeDictionary[key] || key;
        return { value: labelFromDict, label: labelFromDict };
      }

      const taskTypeId =
        (raw as any).taskTypeId ??
        (raw as any).TaskTypeId ??
        (raw as any).task_type_id ??
        (raw as any).TaskTypeID ??
        (raw as any).taskTypeID ??
        null;

      const typeName =
        (raw as any).typeName ??
        (raw as any).TypeName ??
        (raw as any).taskTypeName ??
        (raw as any).TaskTypeName ??
        (raw as any).name ??
        (raw as any).Name ??
        (raw as any).description ??
        (raw as any).Description ??
        'General';

      let label = typeName;
      if ((!label || label.toLowerCase() === 'general') && taskTypeId !== null && taskTypeId !== undefined) {
        const lookupValue = this.taskTypeDictionary[String(taskTypeId)];
        if (lookupValue) {
          label = lookupValue;
        }
      }

      return {
        value: label,
        label
      };
    });

    const uniqueMap = new Map<string, { value: string; label: string }>();
    mapped.forEach(option => {
      if (!uniqueMap.has(option.value)) {
        uniqueMap.set(option.value, option);
      }
    });

    return Array.from(uniqueMap.values());
  }

  private setPincodeOptions(pincodes: string[]): void {
    const unique = Array.from(new Set(pincodes.filter(Boolean)));
    this.pincodeOptions = [...unique];
    if (!unique.length) {
      this.localityName?.disable();
    }
    this.cdr.detectChanges();
  }

  private setPincodeOptionsFromRecords(records: PincodeLocality[]): void {
    if (!records || !records.length) {
      this.setPincodeOptions(this.fallbackPincodes);
      return;
    }
    const unique = Array.from(
      new Set(
        records
          .map(record => this.normalizePincode(record))
          .filter((pin): pin is string => !!pin)
      )
    );
    this.setPincodeOptions(unique.length ? unique : this.fallbackPincodes);
  }

  private setLocalitySuggestions(localities: string[]): void {
    const cleaned = Array.from(new Set(localities.filter(Boolean)));
    this.localitySuggestions = [...cleaned];
    if (cleaned.length) {
      this.localityName?.enable();
    } else {
      this.localityName?.disable();
    }
    this.cdr.detectChanges();
  }

  private extractLocalityNames(localities: any): string[] {
    if (!localities) return [];
    if (Array.isArray(localities)) {
      return localities
        .map(loc => {
          if (typeof loc === 'string') {
            return loc;
          }
          if (loc && typeof loc === 'object') {
            return (
              loc.localityName ??
              loc.locality_name ??
              loc.name ??
              loc.Name ??
              loc.Locality ??
              loc.locality ??
              null
            );
          }
          return null;
        })
        .filter((loc): loc is string => !!loc);
    }
    if (typeof localities === 'object') {
      return Object.values(localities)
        .map(value => {
          if (typeof value === 'string') {
            return value;
          }
          if (value && typeof value === 'object') {
            return (
              (value as any).localityName ??
              (value as any).locality_name ??
              (value as any).name ??
              (value as any).Name ??
              null
            );
          }
          return null;
        })
        .filter((loc): loc is string => !!loc);
    }
    return [];
  }

  private normalizePincode(record: PincodeLocality | any): string {
    if (!record) return '';
    if (typeof record === 'string' || typeof record === 'number') {
      return record.toString().trim();
    }
    if (typeof record === 'object') {
      return (
        record.pincode ??
        record.Pincode ??
        record.pincodeValue ??
        record.pincode_value ??
        ''
      ).toString().trim();
    }
    return '';
  }

  getModalTitle(): string {
    switch (this.mode) {
      case 'create': return 'Create New Task';
      case 'edit': return 'Edit Task';
      case 'view': return 'View Task';
      default: return 'Task';
    }
  }

  getModalIcon(): string {
    switch (this.mode) {
      case 'create': return 'bi bi-plus-circle';
      case 'edit': return 'bi bi-pencil-square';
      case 'view': return 'bi bi-eye';
      default: return 'bi bi-task';
    }
  }

  getStateName(id: number | string | null | undefined): string {
    if (id === null || id === undefined || id === '') return '';
    const numericId = typeof id === 'string' ? Number(id) : id;
    const state = this.states.find(s => s.id === numericId);
    return state?.name || '';
  }

  getCityName(id: number | string | null | undefined): string {
    if (id === null || id === undefined || id === '') return '';
    const numericId = typeof id === 'string' ? Number(id) : id;
    const city = this.cities.find(c => c.id === numericId);
    return city?.name || '';
  }

  canDelete(): boolean {
    return this.mode === 'edit' && !!this.task;
  }
}
