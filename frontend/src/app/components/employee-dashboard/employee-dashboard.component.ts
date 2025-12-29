import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { TaskService, Task } from '../../services/task.service';
import { NotificationService } from '../../services/notification.service';
import { EmployeeFeedbackService, EmployeeFeedback } from '../../services/employee-feedback.service';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { TaskRescheduleModalComponent } from '../task-reschedule-modal/task-reschedule-modal.component';
import { TaskReschedule } from '../../models/task.model';

@Component({
  selector: 'app-employee-dashboard',
  templateUrl: './employee-dashboard.component.html',
  styleUrls: ['./employee-dashboard.component.css'],
})
export class EmployeeDashboardComponent implements OnInit {
  tasks: Task[] = [];
  filteredTasks: Task[] = [];
  isLoading = false;
  currentUser: any;
  selectedStatus = 'all';
  selectedTask: Task | null = null;
  showTaskDetails = false;
  showFeedbackModal = false;
  showRescheduleModal = false;
  feedbackForm: any = {
    consultantName: '',
    feedbackText: '',
    meetingDate: ''
  };
  rescheduleForm: any = {
    newTaskDate: '',
    newDeadline: '',
    rescheduleReason: ''
  };
  taskFeedbacks: EmployeeFeedback[] = [];

  statusOptions = [
    { value: 'all', label: 'All Tasks' },
    { value: 'Not Started', label: 'Not Started' },
    { value: 'In Progress', label: 'In Progress' },
    { value: 'Completed', label: 'Completed' },
    { value: 'Partial Close', label: 'Partial Close' },
    { value: 'Postponed', label: 'Postponed' }
  ];

  constructor(
    private router: Router,
    private authService: AuthService,
    private taskService: TaskService,
    private notificationService: NotificationService,
    private feedbackService: EmployeeFeedbackService
  ) { }

  ngOnInit() {
    this.currentUser = this.authService.getCurrentUser();
    console.log('Current user in employee dashboard:', this.currentUser);
    this.loadTasks();

    // Reset notification count when dashboard loads
    this.notificationService.resetNotificationCount();

    // Set up auto-refresh every 30 seconds
    setInterval(() => {
      this.loadTasks();
    }, 30000);
  }

  loadTasks() {
    this.isLoading = true;

    if (this.currentUser?.employeeId) {
      // Load tasks for specific employee
      console.log('Loading tasks for employee ID:', this.currentUser.employeeId);
      this.taskService.getTasks(undefined, this.currentUser.employeeId).subscribe({
        next: (data: any) => {
          this.tasks = data;
          this.filterTasks();
          this.isLoading = false;
          console.log('Tasks loaded for employee:', data);
        },
        error: (error: any) => {
          console.error('Error loading tasks for employee:', error);
          this.isLoading = false;
          this.notificationService.showNotification('Error loading tasks. Please try again.', 'error');
        }
      });
    } else {
      console.warn('No employee ID found for current user:', this.currentUser);
      this.isLoading = false;
      this.notificationService.showNotification('Employee ID not found. Please contact administrator.', 'error');
    }
  }

  filterTasks() {
    if (this.selectedStatus === 'all') {
      this.filteredTasks = [...this.tasks];
    } else {
      this.filteredTasks = this.tasks.filter(task => task.status === this.selectedStatus);
    }
  }

  onStatusFilterChange() {
    this.filterTasks();
  }

  viewTaskDetails(task: Task) {
    this.selectedTask = task;
    this.showTaskDetails = true;
  }

  closeTaskDetails() {
    this.showTaskDetails = false;
    this.selectedTask = null;
  }

  updateTaskStatus(taskId: number, newStatus: string) {
    // If postponing, show reschedule modal
    if (newStatus === 'Postponed') {
      this.selectedTask = this.tasks.find(t => t.taskId === taskId) || null;
      this.openRescheduleModal();
      return;
    }

    console.log(`Updating task ${taskId} status to: ${newStatus}`);

    this.taskService.updateTaskStatus(taskId, newStatus, `Status updated to ${newStatus}`).subscribe({
      next: (updatedTask: any) => {
        console.log('Task status updated successfully:', updatedTask);

        // CRITICAL FIX: Reload all tasks from backend to ensure persistence
        this.loadTasks();

        // Close modal if open
        if (this.showTaskDetails) {
          this.closeTaskDetails();
        }

        this.notificationService.showNotification(`Task status updated to ${newStatus}`, 'success');
      },
      error: (error: any) => {
        console.error('Error updating task status:', error);
        this.notificationService.showNotification('Failed to update task status. Please try again.', 'error');

        // Reload tasks anyway to get the latest state from backend
        this.loadTasks();
      }
    });
  }

  openRescheduleModal() {
    if (this.selectedTask) {
      // Set minimum dates to today
      const today = new Date().toISOString().split('T')[0];
      this.rescheduleForm = {
        newTaskDate: this.selectedTask.taskDate,
        newDeadline: this.selectedTask.deadline,
        rescheduleReason: ''
      };
      this.showRescheduleModal = true;
    }
  }

  closeRescheduleModal() {
    this.showRescheduleModal = false;
    this.rescheduleForm = {
      newTaskDate: '',
      newDeadline: '',
      rescheduleReason: ''
    };
  }

  onTaskRescheduled(reschedule: TaskReschedule) {
    // Find and update the task with the new dates
    const taskIndex = this.tasks.findIndex(t => t.taskId === reschedule.taskId);
    if (taskIndex !== -1) {
      this.tasks[taskIndex].taskDate = reschedule.newTaskDate || reschedule.newDeadline;
      this.tasks[taskIndex].deadline = reschedule.newDeadline;
      this.tasks[taskIndex].status = 'Postponed';
      this.filterTasks();
    }
    this.loadTasks(); // Refresh the task list
  }

  submitReschedule() {
    if (!this.selectedTask || !this.rescheduleForm.newTaskDate || !this.rescheduleForm.newDeadline) {
      this.notificationService.showNotification('Please fill in all required fields', 'error');
      return;
    }

    // Validate that new deadline is after new task date
    if (new Date(this.rescheduleForm.newDeadline) <= new Date(this.rescheduleForm.newTaskDate)) {
      this.notificationService.showNotification('Deadline must be after task date', 'error');
      return;
    }

    const rescheduleData = {
      taskId: this.selectedTask.taskId,
      newTaskDate: this.rescheduleForm.newTaskDate,
      newDeadline: this.rescheduleForm.newDeadline,
      rescheduleReason: this.rescheduleForm.rescheduleReason
    };

    this.taskService.rescheduleTask(this.selectedTask.taskId, rescheduleData).subscribe({
      next: (updatedTask: any) => {
        console.log('Task rescheduled successfully:', updatedTask);

        // Reload all tasks to ensure we have the latest data
        this.loadTasks();

        this.notificationService.showNotification('Task rescheduled successfully', 'success');
        this.closeRescheduleModal();
      },
      error: (error: any) => {
        console.error('Error rescheduling task:', error);
        this.notificationService.showNotification('Failed to reschedule task. Please try again.', 'error');
      }
    });
  }

  getPriorityClass(priority: string): string {
    switch (priority.toLowerCase()) {
      case 'high': return 'priority-high';
      case 'medium': return 'priority-medium';
      case 'low': return 'priority-low';
      default: return '';
    }
  }

  getStatusClass(status: string): string {
    switch (status.toLowerCase()) {
      case 'completed': return 'status-completed';
      case 'in progress': return 'status-in-progress';
      case 'not started': return 'status-not-started';
      case 'partial close': return 'status-partial-close';
      case 'postponed': return 'status-postponed';
      case 'on hold': return 'status-on-hold';
      default: return '';
    }
  }

  formatDate(dateString: string): string {
    return new Date(dateString).toLocaleDateString();
  }

  getCurrentDate(): string {
    return new Date().toISOString().split('T')[0];
  }

  getPriorityBadgeClass(priority: string): string {
    switch (priority.toLowerCase()) {
      case 'high': return 'bg-danger';
      case 'medium': return 'bg-warning text-dark';
      case 'low': return 'bg-success';
      default: return 'bg-secondary';
    }
  }

  getStatusBadgeClass(status: string): string {
    switch (status.toLowerCase()) {
      case 'completed': return 'bg-success';
      case 'in progress': return 'bg-primary';
      case 'not started': return 'bg-secondary';
      case 'postponed': return 'bg-warning text-dark';
      case 'partial close': return 'bg-info';
      case 'on hold': return 'bg-info';
      default: return 'bg-secondary';
    }
  }

  isOverdue(deadline: string): boolean {
    return new Date(deadline) < new Date() && this.selectedTask?.status !== 'Completed';
  }

  getTaskCountByStatus(status: string): number {
    return this.tasks.filter(task => task.status === status).length;
  }

  filterByStatus(status: string) {
    this.selectedStatus = status;
    this.filterTasks();
  }

  // Feedback functionality
  openFeedbackModal(task: Task) {
    this.selectedTask = task;
    this.showFeedbackModal = true;
    this.feedbackForm = {
      consultantName: '',
      feedbackText: '',
      meetingDate: ''
    };
    this.loadTaskFeedbacks(task.taskId);
  }

  closeFeedbackModal() {
    this.showFeedbackModal = false;
    this.selectedTask = null;
    this.feedbackForm = {
      consultantName: '',
      feedbackText: '',
      meetingDate: ''
    };
    this.taskFeedbacks = [];
  }

  loadTaskFeedbacks(taskId: number) {
    this.feedbackService.getFeedbackByTask(taskId).subscribe({
      next: (feedbacks: EmployeeFeedback[]) => {
        this.taskFeedbacks = feedbacks;
        console.log('Feedbacks loaded:', feedbacks);
      },
      error: (error: any) => {
        console.error('Error loading feedbacks:', error);
        this.taskFeedbacks = [];
      }
    });
  }

  submitFeedback() {
    if (!this.selectedTask || !this.feedbackForm.feedbackText.trim()) {
      this.notificationService.showNotification('Please fill in the feedback text', 'error');
      return;
    }

    const feedbackData = {
      taskId: this.selectedTask.taskId,
      consultantName: this.feedbackForm.consultantName || undefined,
      feedbackText: this.feedbackForm.feedbackText,
      meetingDate: this.feedbackForm.meetingDate || undefined
    };

    this.feedbackService.createFeedback(feedbackData).subscribe({
      next: (response: any) => {
        console.log('Feedback submitted successfully:', response);
        this.notificationService.showNotification('Feedback submitted successfully!');
        this.loadTaskFeedbacks(this.selectedTask!.taskId); // Reload feedbacks
        this.closeFeedbackModal();
      },
      error: (error: any) => {
        console.error('Error submitting feedback:', error);
        this.notificationService.showNotification('Error submitting feedback. Please try again.', 'error');
      }
    });
  }

  logout() {
    console.log('Logging out...');
    this.authService.logout();
    this.router.navigate(['/login']);
  }

  // Helper method to get count of tasks by status
  getStatusCount(status: string): number {
    return this.tasks.filter(task => task.status === status).length;
  }

  // Go back to previous page
  goBack() {
    window.history.back();
  }
}