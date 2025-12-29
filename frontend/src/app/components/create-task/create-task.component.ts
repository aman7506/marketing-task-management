import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { TaskService, TaskCreateDto } from '../../services/task.service';
import { NotificationService } from '../../services/notification.service';

@Component({
  selector: 'app-create-task',
  template: `
    <div class="modal-overlay" (click)="closeModal()">
      <div class="create-task-modal" (click)="$event.stopPropagation()">
        <!-- Modal Header -->
        <div class="modal-header">
          <div class="header-content">
            <div class="title-section">
              <div class="icon-wrapper">
                <i class="fas fa-plus-circle"></i>
              </div>
              <div class="title-text">
                <h2 class="modal-title">Create New Task</h2>
                <p class="modal-subtitle">Add a new task to your project workflow</p>
              </div>
            </div>
            <button class="close-btn" (click)="closeModal()">
              <i class="fas fa-times"></i>
            </button>
          </div>
        </div>
        
        <!-- Modal Body -->
        <div class="modal-body">
          <form [formGroup]="taskForm" (ngSubmit)="onSubmit()" class="task-form">
            <!-- Task Details Section -->
            <div class="form-section">
              <h3 class="section-title">
                <i class="fas fa-tasks"></i>
                Task Details
              </h3>
              
              <div class="form-row">
                <div class="form-group full-width">
                  <label class="form-label" for="description">Task Description *</label>
                  <div class="input-wrapper">
                    <i class="fas fa-align-left input-icon"></i>
                    <textarea 
                      id="description" 
                      class="form-control"
                      formControlName="description" 
                      rows="4"
                      placeholder="Describe the task in detail..."
                      required>
                    </textarea>
                  </div>
                </div>
              </div>

              <div class="form-row">
        <div class="form-group">
                  <label class="form-label" for="employeeId">Employee ID</label>
                  <div class="input-wrapper">
                    <i class="fas fa-id-badge input-icon"></i>
                    <input 
                      type="number" 
                      id="employeeId" 
                      class="form-control"
                      formControlName="employeeId"
                      placeholder="Enter employee ID">
                  </div>
        </div>
        
        <div class="form-group">
                  <label class="form-label" for="priority">Priority Level</label>
                  <div class="input-wrapper">
                    <i class="fas fa-flag input-icon"></i>
                    <select id="priority" class="form-control" formControlName="priority">
                      <option value="Low">🟢 Low Priority</option>
                      <option value="Medium" selected>🟡 Medium Priority</option>
                      <option value="High">🟠 High Priority</option>
                      <option value="Urgent">🔴 Urgent</option>
          </select>
                  </div>
                </div>
        </div>
        
              <div class="form-row">
        <div class="form-group">
                  <label class="form-label" for="taskDate">Start Date *</label>
                  <div class="input-wrapper">
                    <i class="fas fa-calendar-alt input-icon"></i>
                    <input 
                      type="date" 
                      id="taskDate" 
                      class="form-control"
                      formControlName="taskDate" 
                      required>
                  </div>
        </div>
        
        <div class="form-group">
                  <label class="form-label" for="deadline">Deadline *</label>
                  <div class="input-wrapper">
                    <i class="fas fa-calendar-check input-icon"></i>
                    <input 
                      type="date" 
                      id="deadline" 
                      class="form-control"
                      formControlName="deadline" 
                      required>
                  </div>
                </div>
        </div>
        
              <div class="form-row">
        <div class="form-group">
                  <label class="form-label" for="status">Current Status</label>
                  <div class="input-wrapper">
                    <i class="fas fa-info-circle input-icon"></i>
                    <select id="status" class="form-control" formControlName="status">
                      <option value="Not Started" selected>📋 Not Started</option>
                      <option value="In Progress">🔄 In Progress</option>
                      <option value="Completed">✅ Completed</option>
                      <option value="Postponed">⏸️ Postponed</option>
          </select>
                  </div>
        </div>
        
        <div class="form-group">
                  <label class="form-label" for="estimatedHours">Estimated Hours</label>
                  <div class="input-wrapper">
                    <i class="fas fa-clock input-icon"></i>
                    <input 
                      type="number" 
                      id="estimatedHours" 
                      class="form-control"
                      formControlName="estimatedHours" 
                      step="0.5"
                      placeholder="8.0">
                  </div>
                </div>
              </div>
        </div>
        
            <!-- Project Information Section -->
            <div class="form-section">
              <h3 class="section-title">
                <i class="fas fa-project-diagram"></i>
                Project Information
              </h3>
              
              <div class="form-row">
        <div class="form-group">
                  <label class="form-label" for="department">Department</label>
                  <div class="input-wrapper">
                    <i class="fas fa-building input-icon"></i>
                    <input 
                      type="text" 
                      id="department" 
                      class="form-control"
                      formControlName="department"
                      placeholder="Enter department name">
                  </div>
        </div>
        
        <div class="form-group">
                  <label class="form-label" for="clientName">Client Name</label>
                  <div class="input-wrapper">
                    <i class="fas fa-user-tie input-icon"></i>
                    <input 
                      type="text" 
                      id="clientName" 
                      class="form-control"
                      formControlName="clientName"
                      placeholder="Enter client name">
                  </div>
                </div>
        </div>
        
              <div class="form-row">
        <div class="form-group">
                  <label class="form-label" for="projectCode">Project Code</label>
                  <div class="input-wrapper">
                    <i class="fas fa-code input-icon"></i>
                    <input 
                      type="text" 
                      id="projectCode" 
                      class="form-control"
                      formControlName="projectCode"
                      placeholder="e.g., PRJ-2024-001">
                  </div>
        </div>
        
        <div class="form-group">
                  <label class="form-label" for="customLocation">Location</label>
                  <div class="input-wrapper">
                    <i class="fas fa-map-marker-alt input-icon"></i>
                    <input 
                      type="text" 
                      id="customLocation" 
                      class="form-control"
                      formControlName="customLocation"
                      placeholder="Enter task location">
                  </div>
                </div>
              </div>
        </div>
        
            <!-- Action Buttons -->
            <div class="form-actions">
              <button type="button" class="btn btn-secondary" (click)="closeModal()">
                <i class="fas fa-times"></i>
                Cancel
              </button>
              <button 
                type="submit" 
                class="btn btn-primary"
                [disabled]="taskForm.invalid || isSubmitting">
                <i class="fas fa-plus" *ngIf="!isSubmitting"></i>
                <i class="fas fa-spinner fa-spin" *ngIf="isSubmitting"></i>
                {{ isSubmitting ? 'Creating Task...' : 'Create Task' }}
        </button>
            </div>
        
            <!-- Messages -->
            <div *ngIf="successMessage" class="alert alert-success">
              <i class="fas fa-check-circle"></i>
          {{ successMessage }}
        </div>
        
            <div *ngIf="errorMessage" class="alert alert-error">
              <i class="fas fa-exclamation-triangle"></i>
          {{ errorMessage }}
        </div>
      </form>
        </div>
      </div>
    </div>
  `,
  styles: [`
    /* Modal Overlay */
    .modal-overlay {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0, 0, 0, 0.6);
      backdrop-filter: blur(8px);
      display: flex;
      justify-content: center;
      align-items: center;
      z-index: 1000;
      animation: fadeIn 0.3s ease;
    }

    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }

    /* Modal Container */
    .create-task-modal {
      background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
      border-radius: 20px;
      box-shadow: 0 25px 50px rgba(0, 0, 0, 0.25);
      max-width: 800px;
      width: 90%;
      max-height: 90vh;
      overflow-y: auto;
      animation: slideIn 0.3s ease;
      border: 1px solid rgba(255, 255, 255, 0.2);
    }

    @keyframes slideIn {
      from { 
        opacity: 0;
        transform: translateY(-50px) scale(0.9);
      }
      to { 
        opacity: 1;
        transform: translateY(0) scale(1);
      }
    }

    /* Modal Header */
    .modal-header {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      padding: 25px 30px;
      border-radius: 20px 20px 0 0;
      position: relative;
      overflow: hidden;
    }

    .modal-header::before {
      content: '';
      position: absolute;
      top: -50%;
      right: -50%;
      width: 200%;
      height: 200%;
      background: radial-gradient(circle, rgba(255, 255, 255, 0.1) 0%, transparent 70%);
      animation: shimmer 3s ease-in-out infinite;
    }

    @keyframes shimmer {
      0%, 100% { transform: translateX(-100%) translateY(-100%) rotate(30deg); }
      50% { transform: translateX(100%) translateY(100%) rotate(30deg); }
    }

    .header-content {
      display: flex;
      justify-content: space-between;
      align-items: center;
      position: relative;
      z-index: 2;
    }

    .title-section {
      display: flex;
      align-items: center;
      gap: 15px;
    }

    .icon-wrapper {
      width: 50px;
      height: 50px;
      background: rgba(255, 255, 255, 0.2);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      backdrop-filter: blur(10px);
      border: 1px solid rgba(255, 255, 255, 0.3);
    }

    .icon-wrapper i {
      font-size: 1.5rem;
      color: white;
      animation: pulse 2s ease-in-out infinite;
    }

    @keyframes pulse {
      0%, 100% { transform: scale(1); }
      50% { transform: scale(1.1); }
    }

    .title-text h2 {
      color: white;
      margin: 0;
      font-size: 1.8rem;
      font-weight: 700;
      text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
    }

    .title-text p {
      color: rgba(255, 255, 255, 0.9);
      margin: 5px 0 0 0;
      font-size: 0.95rem;
      font-weight: 400;
    }

    .close-btn {
      background: rgba(255, 255, 255, 0.2);
      border: 1px solid rgba(255, 255, 255, 0.3);
      color: white;
      width: 40px;
      height: 40px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: all 0.3s ease;
      backdrop-filter: blur(10px);
    }

    .close-btn:hover {
      background: rgba(255, 255, 255, 0.3);
      transform: scale(1.1);
    }

    /* Modal Body */
    .modal-body {
      padding: 30px;
    }

    .task-form {
      display: flex;
      flex-direction: column;
      gap: 25px;
    }

    /* Form Sections */
    .form-section {
      background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
      padding: 25px;
      border-radius: 15px;
      border: 1px solid rgba(102, 126, 234, 0.1);
      box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
      position: relative;
      overflow: hidden;
    }

    .form-section::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      width: 4px;
      height: 100%;
      background: linear-gradient(180deg, #667eea 0%, #764ba2 100%);
      border-radius: 0 4px 4px 0;
    }

    .section-title {
      display: flex;
      align-items: center;
      gap: 10px;
      margin: 0 0 20px 0;
      color: #2c3e50;
      font-size: 1.2rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }

    .section-title i {
      color: #667eea;
      font-size: 1.1rem;
    }

    /* Form Layout */
    .form-row {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 20px;
      margin-bottom: 20px;
    }

    .form-row:last-child {
      margin-bottom: 0;
    }

    .form-group.full-width {
      grid-column: 1 / -1;
    }

    /* Form Groups */
    .form-group {
      display: flex;
      flex-direction: column;
    }

    .form-label {
      font-weight: 700;
      color: #2c3e50;
      margin-bottom: 8px;
      font-size: 0.9rem;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }

    /* Input Wrapper */
    .input-wrapper {
      position: relative;
      display: flex;
      align-items: center;
    }

    .input-icon {
      position: absolute;
      left: 15px;
      color: #667eea;
      font-size: 1rem;
      z-index: 1;
      pointer-events: none;
    }

    .form-control {
      width: 100%;
      padding: 12px 15px 12px 45px;
      border: 2px solid #e9ecef;
      border-radius: 10px;
      font-size: 0.95rem;
      transition: all 0.3s ease;
      background: #ffffff;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.04);
      font-weight: 500;
      pointer-events: auto;
      cursor: text;
    }

    .form-control:focus {
      outline: none;
      border-color: #667eea;
      box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.15);
      transform: translateY(-1px);
    }

    .form-control:hover {
      border-color: #667eea;
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.08);
    }

    .form-control::placeholder {
      color: #adb5bd;
      font-weight: 400;
    }

    /* Form Actions */
    .form-actions {
      display: flex;
      justify-content: flex-end;
      gap: 15px;
      padding-top: 20px;
      border-top: 1px solid #e9ecef;
    }

    .btn {
      padding: 12px 24px;
      border: none;
      border-radius: 10px;
      font-size: 0.95rem;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s ease;
      display: flex;
      align-items: center;
      gap: 8px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }

    .btn-primary {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
    }

    .btn-primary:hover:not(:disabled) {
      transform: translateY(-2px);
      box-shadow: 0 8px 25px rgba(102, 126, 234, 0.6);
    }

    .btn-secondary {
      background: #6c757d;
      color: white;
    }

    .btn-secondary:hover {
      background: #5a6268;
      transform: translateY(-1px);
    }

    .btn:disabled {
      opacity: 0.6;
      cursor: not-allowed;
      transform: none !important;
    }

    /* Alerts */
    .alert {
      padding: 15px 20px;
      border-radius: 10px;
      margin-top: 15px;
      display: flex;
      align-items: center;
      gap: 10px;
      font-weight: 500;
    }

    .alert-success {
      background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%);
      color: #155724;
      border: 1px solid #c3e6cb;
    }

    .alert-error {
      background: linear-gradient(135deg, #f8d7da 0%, #f5c6cb 100%);
      color: #721c24;
      border: 1px solid #f5c6cb;
    }

    /* Responsive Design */
    @media (max-width: 768px) {
      .create-task-modal {
        width: 95%;
        margin: 10px;
      }

      .modal-header {
        padding: 20px;
      }

      .modal-body {
        padding: 20px;
      }

      .form-row {
        grid-template-columns: 1fr;
        gap: 15px;
      }

      .form-actions {
        flex-direction: column;
      }

      .btn {
        width: 100%;
        justify-content: center;
      }
    }
  `]
})
export class CreateTaskComponent implements OnInit {
  taskForm: FormGroup;
  isSubmitting = false;
  successMessage = '';
  errorMessage = '';

  constructor(
    private fb: FormBuilder,
    private taskService: TaskService,
    private notificationService: NotificationService
  ) {
    this.taskForm = this.fb.group({
      description: ['', Validators.required],
      employeeId: [1, Validators.required],
      priority: ['Medium'],
      taskDate: [new Date().toISOString().split('T')[0], Validators.required],
      deadline: [new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0], Validators.required],
      status: ['Not Started'],
      estimatedHours: [8.00],
      customLocation: [''],
      department: [''],
      clientName: [''],
      projectCode: [''],
    });
  }

  ngOnInit(): void {
  }

  closeModal(): void {
    // This method should be implemented to close the modal
    // You can emit an event or use a service to close the modal
    console.log('Close modal requested');
  }

  onSubmit(): void {
    if (this.taskForm.invalid || this.isSubmitting) {
      return;
    }

    this.isSubmitting = true;
    this.successMessage = '';
    this.errorMessage = '';

    const formValue = this.taskForm.value;
    
    // Convert date strings to ISO format and ensure required fields
    const taskData: TaskCreateDto = {
      description: formValue.description?.trim() || '',
      employeeId: formValue.employeeId || 1, // Default to employee ID 1 if not provided
      priority: formValue.priority || 'Medium',
      taskDate: formValue.taskDate ? new Date(formValue.taskDate).toISOString() : new Date().toISOString(),
      deadline: formValue.deadline ? new Date(formValue.deadline).toISOString() : new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
      taskType: formValue.taskType || 'General',
      department: formValue.department || 'Marketing',
      clientName: formValue.clientName,
      projectCode: formValue.projectCode,
      estimatedHours: formValue.estimatedHours ? parseFloat(formValue.estimatedHours) : undefined,
      actualHours: formValue.actualHours ? parseFloat(formValue.actualHours) : undefined,
      taskCategory: formValue.taskCategory || 'Field Work',
      additionalNotes: formValue.additionalNotes,
      isUrgent: formValue.isUrgent || false,
      customLocation: formValue.customLocation,
      locationId: formValue.locationId,
      consultantFeedback: formValue.consultantFeedback
    };

    this.taskService.createTask(taskData).subscribe({
      next: (task) => {
        this.isSubmitting = false;
        this.successMessage = `Task created successfully with ID: ${task.taskId}`;
        this.taskForm.reset({
          employeeId: 1,
          priority: 'Medium',
          taskDate: new Date().toISOString().split('T')[0],
          deadline: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
          status: 'Not Started',
          estimatedHours: 8.00
        });
        
        // Notify via SignalR
        this.notificationService.sendTaskNotification('created', task.taskId, task.description);
      },
      error: (error) => {
        this.isSubmitting = false;
        this.errorMessage = `Error creating task: ${error.message || 'Unknown error'}`;
        console.error('Error creating task:', error);
      }
    });
  }
}