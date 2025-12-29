import { Component, OnInit, OnDestroy } from '@angular/core';
import { HierarchicalLocationSelection } from '../hierarchical-location-selector/hierarchical-location-selector.component';
import { AuthService } from '../../services/auth.service';
import { TaskService, Task, TaskUpdateDto } from '../../services/task.service';
import { EmployeeService, Employee } from '../../services/employee.service';
import { NotificationService } from '../../services/notification.service';
import { MarketingFormService, MarketingCampaignData } from '../../services/marketing-form.service';
import { Router, NavigationEnd } from '@angular/router';
import { filter } from 'rxjs/operators';
import { Subscription } from 'rxjs';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { AdminTaskModalComponent } from '../admin-task-modal/admin-task-modal.component';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-admin-dashboard',
  templateUrl: './admin-dashboard.component.html',
  styleUrls: ['./admin-dashboard.component.css'],
})
export class AdminDashboardComponent implements OnInit, OnDestroy {
  apiUrl = environment.apiUrl;
  tasks: any[] = [];
  employees: Employee[] = [];
  filteredTasks: any[] = [];
  marketingCampaigns: MarketingCampaignData[] = [];
  filteredCampaigns: MarketingCampaignData[] = [];
  isLoading = false;
  isLoadingCampaigns = false;
  currentUser: any;
  selectedStatus = 'all';
  selectedEmployee = 'all';
  selectedTask: any | null = null;
  selectedCampaign: MarketingCampaignData | null = null;
  showTaskDetails = false;
  showCampaignDetails = false;
  showAdminTaskModal = false;
  adminTaskModalMode: 'create' | 'edit' | 'view' = 'view';
  showEditModal = false;
  showDeleteModal = false;
  editForm: any = {};
  activeTab: 'tasks' | 'campaigns' = 'tasks';
  private routerSubscription: Subscription = new Subscription();

  statTiles = [
    { label: 'TOTAL TASKS', value: 0, color: 'blue', filterValue: 'all' },
    { label: 'NOT STARTED', value: 0, color: 'purple', filterValue: 'Not Started' },
    { label: 'IN PROGRESS', value: 0, color: 'teal', filterValue: 'In Progress' },
    { label: 'COMPLETED', value: 0, color: 'yellow', filterValue: 'Completed' },
    { label: 'PARTIAL CLOSE', value: 0, color: 'red', filterValue: 'Partial Close' },
    { label: 'OVERDUE', value: 0, color: 'orange', filterValue: 'overdue' },
    { label: 'Today', value: 0, color: 'indigo', filterValue: 'completed-today' }
  ];

  statusOptions: { value: string; label: string }[] = [
    { value: 'all', label: 'All Tasks' },
    { value: 'Not Started', label: 'Not Started' },
    { value: 'In Progress', label: 'In Progress' },
    { value: 'Completed', label: 'Completed' },
    { value: 'Partial Close', label: 'Partial Close' },
    { value: 'Postponed', label: 'Postponed' },
    { value: 'On Hold', label: 'On Hold' }
  ];
  priorityOptions: { value: string; label: string }[] = [
    { value: 'Low', label: 'Low' },
    { value: 'Medium', label: 'Medium' },
    { value: 'High', label: 'High' },
    { value: 'Urgent', label: 'Urgent' }
  ];
  locationOptions: { value: string; label: string }[] = [];

  constructor(
    public authService: AuthService,
    private taskService: TaskService,
    private employeeService: EmployeeService,
    private notificationService: NotificationService,
    private marketingFormService: MarketingFormService,
    private router: Router
  ) { }

  ngOnInit() {
    this.currentUser = this.authService.getCurrentUser();
    this.loadTasks();
    this.loadEmployees();
    this.loadMarketingCampaigns();

    // Reset notification count when dashboard loads
    this.notificationService.resetNotificationCount();

    // Listen for navigation events to refresh data when returning from task assignment
    this.routerSubscription = this.router.events
      .pipe(filter(event => event instanceof NavigationEnd))
      .subscribe(event => {
        if (event instanceof NavigationEnd && event.url === '/admin/dashboard') {
          this.loadTasks();
        }
      });

    // Set up auto-refresh every 30 seconds
    setInterval(() => {
      this.loadTasks();
    }, 30000);
  }

  ngOnDestroy() {
    if (this.routerSubscription) {
      this.routerSubscription.unsubscribe();
    }
  }

  loadTasks() {
    this.isLoading = true;

    this.taskService.getTasks().subscribe({
      next: (data: any[]) => {
        console.log('Tasks loaded successfully:', data);
        this.tasks = data || [];
        this.filterTasks();
        this.updateStatTiles();
        this.isLoading = false;
      },
      error: (error: any) => {
        console.error('Error loading tasks:', error);
        console.error('Error details:', error.error);
        console.error('Error status:', error.status);

        // Show user-friendly error message
        if (error.status === 401) {
          this.notificationService.showNotification('Please login to view tasks', 'error');
        } else if (error.status === 403) {
          this.notificationService.showNotification('You do not have permission to view tasks', 'error');
        } else {
          this.notificationService.showNotification('Error loading tasks. Please check if backend is running.', 'error');
        }

        this.tasks = [];
        this.filterTasks();
        this.updateStatTiles();
        this.isLoading = false;
      }
    });
  }

  loadEmployees() {
    this.employeeService.getEmployees().subscribe({
      next: (data) => {
        this.employees = data;
      },
      error: (error) => {
        console.error('Error loading employees:', error);
      }
    });
  }

  loadMarketingCampaigns() {
    this.isLoadingCampaigns = true;
    this.marketingFormService.getAllMarketingCampaigns().subscribe({
      next: (response) => {
        this.isLoadingCampaigns = false;
        if (response.success && response.data) {
          this.marketingCampaigns = response.data;
          this.filteredCampaigns = [...this.marketingCampaigns];
          console.log('Marketing campaigns loaded:', this.marketingCampaigns);
        } else {
          console.error('Error loading marketing campaigns:', response.message);
          this.notificationService.showNotification('Error loading marketing campaigns: ' + response.message, 'error');
        }
      },
      error: (error) => {
        this.isLoadingCampaigns = false;
        console.error('Error loading marketing campaigns:', error);
        this.notificationService.showNotification('Error loading marketing campaigns: ' + error.message, 'error');
      }
    });
  }

  filterTasks() {
    const normalized = (this.tasks || []).map((t: any) => ({
      taskId: t.taskId ?? t.TaskId,
      description: t.description ?? t.Description,
      status: t.status ?? t.Status,
      priority: t.priority ?? t.Priority,
      employeeId: t.employeeId ?? t.EmployeeId,
      employeeName: t.employeeName ?? t.EmployeeName ?? t.Employee?.Name,
      employeeDesignation: t.employeeDesignation ?? t.EmployeeDesignation ?? t.Employee?.Designation,
      employeeContact: t.employeeContact ?? t.EmployeeContact ?? t.Employee?.Contact,
      locationId: t.locationId ?? t.LocationId,
      locationName: t.locationName ?? t.LocationName ?? t.Location?.LocationName,
      customLocation: t.customLocation ?? t.CustomLocation,
      taskDate: t.taskDate ?? t.TaskDate,
      deadline: t.deadline ?? t.Deadline,
      taskType: t.taskType ?? t.TaskType,
      department: t.department ?? t.Department,
      clientName: t.clientName ?? t.ClientName,
      projectCode: t.projectCode ?? t.ProjectCode,
      estimatedHours: t.estimatedHours ?? t.EstimatedHours,
      actualHours: t.actualHours ?? t.ActualHours,
      taskCategory: t.taskCategory ?? t.TaskCategory,
      additionalNotes: t.additionalNotes ?? t.AdditionalNotes,
      isUrgent: t.isUrgent ?? t.IsUrgent,
      createdAt: t.createdAt ?? t.CreatedAt,
      updatedAt: t.updatedAt ?? t.UpdatedAt,
      assignedByUserName: t.assignedByUserName ?? t.AssignedByUserName
    }));

    let filtered: any[] = [...normalized];

    if (this.selectedStatus !== 'all') {
      if (this.selectedStatus === 'overdue') {
        filtered = this.getOverdueTasks();
      } else if (this.selectedStatus === 'completed-today') {
        filtered = this.getTasksCompletedToday();
      } else {
        filtered = filtered.filter(task => task.status === this.selectedStatus);
      }
    }

    if (this.selectedEmployee !== 'all') {
      const selectedEmpId = parseInt(this.selectedEmployee);
      filtered = filtered.filter(task => task.employeeId === selectedEmpId);
    }

    this.filteredTasks = filtered as any;
  }

  onStatusFilterChange() {
    this.filterTasks();
  }

  onEmployeeFilterChange() {
    this.filterTasks();
  }

  onHeaderLocationChange(selection: HierarchicalLocationSelection) {
    // Optionally filter tasks by selected hierarchical location if needed
    // Here we simply log to verify UI dependency works
    console.log('Header location selection:', selection);
  }

  viewTaskDetails(task: Task) {
    this.selectedTask = {
      ...task,
      employeeName: (task as any).employeeName ?? (task as any).Employee?.Name ?? '',
      employeeDesignation: (task as any).employeeDesignation ?? (task as any).Employee?.Designation ?? '',
      employeeContact: (task as any).employeeContact ?? (task as any).Employee?.Contact ?? ''
    } as any;
    this.showTaskDetails = true;
  }

  closeTaskDetails() {
    this.showTaskDetails = false;
    this.selectedTask = null;
  }

  // Admin Task Modal Methods
  openCreateTaskModal() {
    this.selectedTask = null;
    this.adminTaskModalMode = 'create';
    this.showAdminTaskModal = true;
  }

  openEditTaskModal(task: any) {
    this.selectedTask = task;
    this.adminTaskModalMode = 'edit';
    this.showAdminTaskModal = true;
    console.log('Opening edit modal for task:', task.taskId);
  }

  openViewTaskModal(task: any) {
    this.selectedTask = task;
    this.adminTaskModalMode = 'view';
    this.showAdminTaskModal = true;
    console.log('Opening view modal for task:', task.taskId);
  }

  openAdminTaskModal(task: Task | null, mode: 'create' | 'edit' | 'view') {
    this.selectedTask = task;
    this.adminTaskModalMode = mode;
    this.showAdminTaskModal = true;
  }

  closeAdminTaskModal() {
    this.showAdminTaskModal = false;
    this.selectedTask = null;
    this.adminTaskModalMode = 'view';
  }

  onTaskSaved(task: any) {
    // Refresh the task list to show the newly created/updated task
    // Optimistically update UI if task present
    if (task && task.taskId) {
      const idx = this.tasks.findIndex(t => t.taskId === task.taskId);
      if (idx >= 0) {
        this.tasks[idx] = task;
      } else {
        this.tasks.unshift(task);
      }
      this.filterTasks();
    } else {
      this.loadTasks();
    }
    this.closeAdminTaskModal();
    const wasUpdate = !!(task && task.taskId);
    this.notificationService.showNotification(
      `Task ${wasUpdate ? 'updated' : 'created'} successfully!`,
      'success'
    );
  }

  onTaskDeleted(taskId: number) {
    // Refresh the task list to ensure data consistency after deletion
    this.loadTasks();
    this.closeAdminTaskModal();
    this.notificationService.showNotification('Task deleted successfully!', 'success');
  }

  onTaskCreated() {
    // Refresh the task list when a new task is created
    this.loadTasks();
    this.notificationService.showNotification('New task created successfully!', 'success');
  }

  // Removed navigateToAssignTask method as Assign Task functionality is now merged into Create Task

  getTaskCountByStatus(status: string): number {
    return this.tasks.filter(task => task.status === status).length;
  }



  isOverdue(deadline: string): boolean {
    return new Date(deadline) < new Date();
  }

  getOverdueTasks(): Task[] {
    return this.tasks.filter(task =>
      this.isOverdue(task.deadline) && task.status !== 'Completed'
    );
  }

  getTasksCompletedToday(): Task[] {
    const today = new Date().toDateString();
    return this.tasks.filter(task =>
      task.status === 'Completed' &&
      new Date(task.updatedAt).toDateString() === today
    );
  }



  filterByStatus(status: string) {
    this.selectedStatus = status;
    this.filterTasks();
  }

  filterByOverdue() {
    this.selectedStatus = 'overdue';
    this.filterTasks();
  }

  filterByCompletedToday() {
    this.selectedStatus = 'completed-today';
    this.filterTasks();
  }

  // Handle stat tile clicks
  onStatTileClick(stat: any) {
    if (stat.filterValue) {
      this.selectedStatus = stat.filterValue;
      this.filterTasks();
    }
  }

  // Handle stat tile hover effects
  onStatTileHover(event: MouseEvent, stat: any, isEntering: boolean) {
    const target = event.currentTarget as HTMLElement;
    if (!target) return;

    if (isEntering) {
      // Mouse enter - scale up
      target.style.transform = 'scale(1.05)';
    } else {
      // Mouse leave - scale back based on selection state
      const isSelected = stat.filterValue && this.selectedStatus === stat.filterValue;
      target.style.transform = isSelected ? 'scale(1.05)' : 'scale(1)';
    }
  }

  // Admin editing functionality
  openEditModal(task: any) {
    this.selectedTask = task;
    this.editForm = {
      taskId: task.taskId,
      description: task.description,
      priority: task.priority,
      status: task.status,
      taskDate: task.taskDate,
      deadline: task.deadline,
      taskType: task.taskType || 'General',
      department: task.department || 'Marketing',
      clientName: task.clientName || '',
      projectCode: task.projectCode || '',
      estimatedHours: task.estimatedHours || 0,
      actualHours: task.actualHours || 0,
      taskCategory: task.taskCategory || 'Field Work',
      additionalNotes: task.additionalNotes || '',
      isUrgent: task.isUrgent || false
    };
    this.showEditModal = true;
  }

  closeEditModal() {
    this.showEditModal = false;
    this.editForm = {};
    this.selectedTask = null;
  }

  submitEdit() {
    if (!this.selectedTask || !this.editForm.description || !this.editForm.priority) {
      this.notificationService.showNotification('Please fill in all required fields', 'error');
      return;
    }

    // Validate dates
    if (new Date(this.editForm.deadline) <= new Date(this.editForm.taskDate)) {
      this.notificationService.showNotification('Deadline must be after task date', 'error');
      return;
    }

    // Prepare the update data with proper formatting
    const updateData: TaskUpdateDto = {
      description: this.editForm.description?.trim() || '',
      employeeId: this.editForm.employeeId || this.selectedTask.employeeId,
      priority: this.editForm.priority?.trim() || 'Medium',
      status: this.editForm.status || this.selectedTask.status,
      taskDate: this.editForm.taskDate ? new Date(this.editForm.taskDate).toISOString() : this.selectedTask.taskDate,
      deadline: this.editForm.deadline ? new Date(this.editForm.deadline).toISOString() : this.selectedTask.deadline,
      taskType: this.editForm.taskType || this.selectedTask.taskType || 'General',
      department: this.editForm.department || this.selectedTask.department || 'Marketing',
      clientName: this.editForm.clientName || this.selectedTask.clientName,
      projectCode: this.editForm.projectCode || this.selectedTask.projectCode,
      estimatedHours: this.editForm.estimatedHours ? parseFloat(this.editForm.estimatedHours) : this.selectedTask.estimatedHours,
      actualHours: this.editForm.actualHours ? parseFloat(this.editForm.actualHours) : this.selectedTask.actualHours,
      taskCategory: this.editForm.taskCategory || this.selectedTask.taskCategory || 'Field Work',
      additionalNotes: this.editForm.additionalNotes || this.selectedTask.additionalNotes,
      isUrgent: this.editForm.isUrgent !== undefined ? this.editForm.isUrgent : this.selectedTask.isUrgent,
      customLocation: this.editForm.customLocation || this.selectedTask.customLocation,
      locationId: this.editForm.locationId || this.selectedTask.locationId,
      consultantFeedback: this.editForm.consultantFeedback || this.selectedTask.consultantFeedback
    };

    this.taskService.updateTask(this.selectedTask.taskId, updateData).subscribe({
      next: (updatedTask) => {
        // Update the task in the local array
        const taskIndex = this.tasks.findIndex(t => t.taskId === this.selectedTask!.taskId);
        if (taskIndex !== -1) {
          this.tasks[taskIndex] = { ...this.tasks[taskIndex], ...updateData };
          this.filterTasks();
        }

        this.notificationService.showNotification('Task updated successfully');
        this.closeEditModal();
      },
      error: (error) => {
        console.error('Error updating task:', error);
        this.notificationService.showNotification('Error updating task. Please try again.', 'error');
      }
    });
  }

  openDeleteModal(task: Task) {
    this.selectedTask = task;
    this.showDeleteModal = true;
  }

  closeDeleteModal() {
    this.showDeleteModal = false;
    this.selectedTask = null;
  }

  confirmDelete() {
    if (!this.selectedTask) return;

    this.taskService.deleteTask(this.selectedTask.taskId).subscribe({
      next: () => {
        // Remove the task from the local array
        this.tasks = this.tasks.filter(t => t.taskId !== this.selectedTask!.taskId);
        this.filterTasks();

        this.notificationService.showNotification('Task deleted successfully');
        this.closeDeleteModal();
      },
      error: (error) => {
        console.error('Error deleting task:', error);
        this.notificationService.showNotification('Error deleting task. Please try again.', 'error');
      }
    });
  }

  loadAllTasks(): void {
    this.taskService.getTasks().subscribe({
      next: (tasks) => {
        this.tasks = tasks;
      },
      error: (error) => {
        console.error('Error loading tasks:', error);
      }
    });
  }

  updateTaskStatus(taskId: number, status: string): void {
    this.taskService.updateTaskStatus(taskId, status).subscribe({
      next: () => {
        this.loadAllTasks();
      },
      error: (error) => {
        console.error('Error updating task status:', error);
      }
    });
  }

  getCurrentDate(): string {
    return new Date().toISOString().split('T')[0];
  }

  logout() {
    this.authService.logout();
    this.router.navigate(['/login']);
  }

  // Add this method for demo/testing
  createRandomTasks(count: number = 5) {
    for (let i = 0; i < count; i++) {
      const randomTask = {
        description: 'Random Task ' + Math.floor(Math.random() * 10000),
        employeeId: this.employees.length > 0 ? this.employees[Math.floor(Math.random() * this.employees.length)].employeeId : 1,
        state: '',
        city: '',
        pincode: '110001', // Adding required pincode
        localityName: 'Random Locality', // Adding required localityName
        customLocation: 'Random Location ' + Math.floor(Math.random() * 100),
        priority: ['Low', 'Medium', 'High'][Math.floor(Math.random() * 3)],
        status: ['Not Started', 'In Progress', 'Completed'][Math.floor(Math.random() * 3)],
        taskDate: new Date().toISOString().split('T')[0],
        deadline: new Date(Date.now() + Math.floor(Math.random() * 7) * 86400000).toISOString().split('T')[0],
        taskType: 'Field Work',
        department: 'Marketing',
        clientName: 'Client ' + Math.floor(Math.random() * 100),
        projectCode: 'PRJ-' + Math.floor(Math.random() * 10000),
        estimatedHours: Math.random() * 10 + 1,
        actualHours: Math.random() * 10,
        taskCategory: 'Field Work',
        additionalNotes: 'Random note ' + Math.floor(Math.random() * 1000),
        isUrgent: Math.random() > 0.5,
        taskTypeIds: [], // Adding missing taskTypeIds array
        locationIds: []  // Adding missing locationIds array
      };
      this.taskService.createTask(randomTask).subscribe({
        next: (task) => {
          this.tasks.unshift(task);
          this.filterTasks();
        },
        error: (err) => {
          console.error('Error creating random task:', err);
        }
      });
    }
  }

  updateStatTiles() {
    this.statTiles[0].value = this.tasks.length;
    this.statTiles[1].value = this.getTaskCountByStatus('Not Started');
    this.statTiles[2].value = this.getTaskCountByStatus('In Progress');
    this.statTiles[3].value = this.getTaskCountByStatus('Completed');
    this.statTiles[4].value = this.getTaskCountByStatus('Partial Close');
    this.statTiles[5].value = this.getOverdueTasks().length;
    this.statTiles[6].value = this.getTasksCompletedToday().length;
  }

  // Tab switching methods
  switchTab(tab: 'tasks' | 'campaigns') {
    this.activeTab = tab;
  }

  // Format date for display
  formatDate(dateString: string): string {
    if (!dateString) return '';
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  }

  // Format date and time for display
  formatDateTime(dateString: string): string {
    if (!dateString) return '';
    const date = new Date(dateString);
    return date.toLocaleString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  }

  // Get priority badge class
  getPriorityClass(priority: string): string {
    switch (priority.toLowerCase()) {
      case 'urgent': return 'badge-danger';
      case 'high': return 'badge-warning';
      case 'medium': return 'badge-info';
      case 'low': return 'badge-success';
      default: return 'badge-secondary';
    }
  }

  // Get status badge class
  getStatusClass(status: string): string {
    switch (status.toLowerCase()) {
      case 'completed': return 'badge-success';
      case 'in progress': return 'badge-warning';
      case 'not started': return 'badge-secondary';
      case 'on hold': return 'badge-danger';
      case 'postponed': return 'badge-info';
      default: return 'badge-secondary';
    }
  }

  // View campaign details
  viewCampaign(campaign: MarketingCampaignData) {
    this.selectedCampaign = campaign;
    this.showCampaignDetails = true;
  }

  closeCampaignDetails() {
    this.showCampaignDetails = false;
    this.selectedCampaign = null;
  }

  // Print campaign form
  printCampaignForm(): void {
    if (!this.selectedCampaign) {
      console.error('No campaign selected for printing');
      return;
    }

    const printWindow = window.open('', '_blank', 'width=900,height=700');

    if (!printWindow) {
      alert('Please allow popups for this site to print');
      return;
    }

    const printContent = `
    <!DOCTYPE html>
    <html>
    <head>
        <title>Marketing Campaign Form - Print</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            
            body { 
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
                background: #fff;
                padding: 20px;
                line-height: 1.6; 
            }
            
            .print-buttons {
                text-align: center;
                margin: 20px 0 30px;
                padding: 15px;
                background: #f0f9ff;
                border-radius: 8px;
            }
            
            .print-btn {
                padding: 12px 30px;
                margin: 5px;
                background: linear-gradient(135deg, #0ea5e9 0%, #06b6d4 100%);
                color: white;
                border: none;
                border-radius: 6px;
                cursor: pointer;
                font-size: 16px;
                font-weight: 600;
            }
            
            .print-btn:hover {
                background: linear-gradient(135deg, #0284c7 0%, #0ea5e9 100%);
            }
            
            .header {
                text-align: center;
                margin-bottom: 30px;
                padding-bottom: 20px;
                border-bottom: 3px solid #0ea5e9;
            }
            
            .header h1 {
                color: #0f172a;
                font-size: 28px;
                margin-bottom: 10px;
            }
            
            .header h2 {
                color: #64748b;
                font-size: 18px;
                font-weight: 400;
            }
            
            .generated-info {
                text-align: center;
                color: #666;
                font-size: 14px;
                margin-bottom: 30px;
                padding: 10px;
                background: #f8fafc;
                border-left: 4px solid #0ea5e9;
                border-radius: 4px;
            }
            
            .section {
                margin-bottom: 30px;
                border: 2px solid #e2e8f0;
                padding: 20px;
                border-radius: 8px;
                background: #fafafa;
            }
            
            .section-title {
                font-weight: 700;
                font-size: 18px;
                color: #0ea5e9;
                margin-bottom: 18px;
                padding-bottom: 10px;
                border-bottom: 2px solid #0ea5e9;
                text-transform: uppercase;
            }
            
            .field {
                margin-bottom: 12px;
                padding: 8px 0;
                display: flex;
                border-bottom: 1px solid #e2e8f0;
            }
            
            .field:last-child {
                border-bottom: none;
            }
            
            .field-label {
                font-weight: 600;
                color: #334155;
                min-width: 220px;
                padding-right: 15px;
            }
            
            .field-value {
                color: #1e293b;
                flex: 1;
            }
            
            @media print {
                body {
                    padding: 0;
                    margin: 0;
                }
                
                .print-buttons {
                    display: none !important;
                }
                
                .section {
                    page-break-inside: avoid;
                }
            }
        </style>
    </head>
    <body>
        <!-- Professional Compact Header -->
        <div style="background: linear-gradient(135deg, #0ea5e9 0%, #06b6d4 50%, #0284c7 100%); padding: 15px 20px; margin-bottom: 25px; border-radius: 6px; box-shadow: 0 3px 10px rgba(14, 165, 233, 0.2);">
            <div style="text-align: center;">
                <div style="font-size: 9px; text-transform: uppercase; letter-spacing: 1.5px; margin-bottom: 5px; color: #1f2937; font-weight: 600;">Official Document</div>
                <h1 style="font-size: 20px; color: #000000; margin: 0 0 6px 0; font-weight: 700; letter-spacing: -0.3px;">Marketing Campaign Form</h1>
                <h2 style="font-size: 13px; color: #1f2937; margin: 0 0 6px 0; font-weight: 500;">Sri Balaji Action Medical Institute & Action Cancer Hospital</h2>
                <div style="display: inline-block; background: #67e8f9; padding: 4px 12px; border-radius: 15px; margin-top: 4px; box-shadow: 0 2px 6px rgba(0,0,0,0.12);">
                    <span style="font-size: 11px; color: #0c4a6e; font-weight: 600;">📅 ${new Date().toLocaleString('en-IN', { timeZone: 'Asia/Kolkata', dateStyle: 'long', timeStyle: 'short' })}</span>
                </div>
            </div>
        </div>


        <div class="section">
            <div class="section-title">Campaign Information</div>
            <div class="field"><span class="field-label">Campaign ID:</span> <span class="field-value">#${this.selectedCampaign.campaignId || 'N/A'}</span></div>
            <div class="field"><span class="field-label">Campaign Manager:</span> <span class="field-value">${this.selectedCampaign.campaignManager || 'N/A'}</span></div>
            <div class="field"><span class="field-label">Employee Code:</span> <span class="field-value">${this.selectedCampaign.employeeCode || 'N/A'}</span></div>
            <div class="field"><span class="field-label">Description:</span> <span class="field-value">${this.selectedCampaign.taskDescription || 'N/A'}</span></div>
            <div class="field"><span class="field-label">Start Date:</span> <span class="field-value">${this.formatDate(this.selectedCampaign.taskDate)}</span></div>
            <div class="field"><span class="field-label">Deadline:</span> <span class="field-value">${this.formatDate(this.selectedCampaign.deadline)}</span></div>
            <div class="field"><span class="field-label">Priority:</span> <span class="field-value">${this.selectedCampaign.priority || 'N/A'}</span></div>
        </div>

        <div class="section">
            <div class="section-title">Project & Client Information</div>
            <div class="field"><span class="field-label">Client Name:</span> <span class="field-value">${this.selectedCampaign.clientName || 'N/A'}</span></div>
            <div class="field"><span class="field-label">Project Code:</span> <span class="field-value">${this.selectedCampaign.projectCode || 'N/A'}</span></div>
            <div class="field"><span class="field-label">Consultant Name:</span> <span class="field-value">${this.selectedCampaign.consultantName || 'N/A'}</span></div>
            <div class="field"><span class="field-label">Campaign Code:</span> <span class="field-value">${this.selectedCampaign.campaignCode || 'N/A'}</span></div>
        </div>

        <div class="section">
            <div class="section-title">Location Details</div>
            <div class="field"><span class="field-label">Location:</span> <span class="field-value">${this.selectedCampaign.locality || 'N/A'}, ${this.selectedCampaign.pincode || 'N/A'}</span></div>
        </div>

        <div class="section">
            <div class="section-title">Campaign Metrics</div>
            <div class="field"><span class="field-label">Estimated Hours:</span> <span class="field-value">${this.selectedCampaign.estimatedHours || 'N/A'}</span></div>
            <div class="field"><span class="field-label">Expected Reach:</span> <span class="field-value">${this.selectedCampaign.expectedReach ? this.selectedCampaign.expectedReach.toLocaleString() : 'N/A'}</span></div>
            <div class="field"><span class="field-label">Conversion Goal:</span> <span class="field-value">${this.selectedCampaign.conversionGoal || 'N/A'}</span></div>
            <div class="field"><span class="field-label">KPIs:</span> <span class="field-value">${this.selectedCampaign.kpis || 'N/A'}</span></div>
            <div class="field"><span class="field-label">Marketing Materials:</span> <span class="field-value">${this.selectedCampaign.marketingMaterials || 'N/A'}</span></div>
        </div>

        <div class="section">
            <div class="section-title">Additional Information</div>
            <div class="field"><span class="field-label">Approval Required:</span> <span class="field-value">${this.selectedCampaign.approvalRequired ? 'YES' : 'NO'}</span></div>
            <div class="field"><span class="field-label">Approval Contact:</span> <span class="field-value">${this.selectedCampaign.approvalContact || 'N/A'}</span></div>
            <div class="field"><span class="field-label">Budget Code:</span> <span class="field-value">${this.selectedCampaign.budgetCode || 'N/A'}</span></div>
            <div class="field"><span class="field-label">Additional Notes:</span> <span class="field-value">${this.selectedCampaign.additionalNotes || 'N/A'}</span></div>
            <div class="field"><span class="field-label">Consultant Feedback:</span> <span class="field-value">${this.selectedCampaign.consultantFeedback || 'N/A'}</span></div>
        </div>

        <div class="section">
            <div class="section-title">Status</div>
            <div class="field"><span class="field-label">Status:</span> <span class="field-value" style="color: #059669; font-weight: bold;">${this.selectedCampaign.status || 'Active'}</span></div>
            <div class="field"><span class="field-label">Created:</span> <span class="field-value">${this.formatDateTime(this.selectedCampaign.createdAt || '')}</span></div>
            <div class="field"><span class="field-label">Last Updated:</span> <span class="field-value">${this.formatDateTime(this.selectedCampaign.updatedAt || '')}</span></div>
        </div>
        
        <!-- Print Buttons at Bottom -->
        <div class="print-buttons">
            <button class="print-btn" style="background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);" onclick="window.print()">🖨️ PRINT NOW</button>
            <button class="print-btn" style="background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); color: white;" onclick="window.close()"><span style="color: white; font-weight: bold;">✖</span> CLOSE</button>
        </div>
    </body>
    </html>
    `;

    printWindow.document.write(printContent);
    printWindow.document.close();
    console.log('Print window opened successfully');
  }

  // Edit campaign
  editCampaign(campaign: MarketingCampaignData) {
    // Navigate to marketing form with campaign data for editing
    this.router.navigate(['/admin/marketing-form'], {
      queryParams: {
        mode: 'edit',
        campaignId: campaign.campaignId
      },
      state: { campaignData: campaign }
    });
  }

  // Delete campaign
  deleteCampaign(campaign: MarketingCampaignData) {
    if (confirm('Are you sure you want to delete this marketing campaign?')) {
      this.marketingFormService.deleteMarketingCampaign(campaign.campaignId!).subscribe({
        next: (response) => {
          if (response.success) {
            this.notificationService.showNotification('Marketing campaign deleted successfully');
            this.loadMarketingCampaigns(); // Reload the list
          } else {
            this.notificationService.showNotification('Error deleting campaign: ' + response.message, 'error');
          }
        },
        error: (error) => {
          this.notificationService.showNotification('Error deleting campaign: ' + error.message, 'error');
        }
      });
    }
  }

  // Delete task
  deleteTask(task: any) {
    if (confirm('Are you sure you want to delete this task?')) {
      this.taskService.deleteTask(task.taskId).subscribe({
        next: (response) => {
          if (response.success) {
            this.notificationService.showNotification('Task deleted successfully');
            this.loadTasks(); // Reload the list
          } else {
            this.notificationService.showNotification('Error deleting task: ' + response.message, 'error');
          }
        },
        error: (error) => {
          this.notificationService.showNotification('Error deleting task: ' + error.message, 'error');
        }
      });
    }
  }
}
