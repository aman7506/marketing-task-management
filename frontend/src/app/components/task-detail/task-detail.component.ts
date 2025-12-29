import { Component, Input, OnInit, Output, EventEmitter } from '@angular/core';
import { Task } from '../../models/task.model';
import { TaskService } from '../../services/task.service';

@Component({
  selector: 'app-task-detail',
  templateUrl: './task-detail.component.html',
  styleUrls: ['./task-detail.component.css']
})
export class TaskDetailComponent implements OnInit {
  @Input() task!: Task;
  @Input() mode: 'view' | 'edit' = 'view';
  @Output() editRequested = new EventEmitter<Task>();
  @Output() taskUpdated = new EventEmitter<Task>();

  currentUserRole: string = '';
  canEdit: boolean = false;

  constructor(private taskService: TaskService) {}

  ngOnInit() {
    this.loadCurrentUserRole();
    this.checkEditPermission();
  }

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
    if (!this.task) return;

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

  onEditClick() {
    this.editRequested.emit(this.task);
  }

  private getCurrentUserEmployeeId(): number {
    // Assume stored in localStorage or service
    const user = JSON.parse(localStorage.getItem('user') || '{}');
    return user.employeeId || 0;
  }

  getStatusClass(status: string): string {
    switch (status) {
      case 'Completed': return 'status-completed';
      case 'In Progress': return 'status-in-progress';
      case 'Not Started': return 'status-not-started';
      default: return 'status-default';
    }
  }

  getPriorityClass(priority: string): string {
    switch (priority) {
      case 'High': return 'priority-high';
      case 'Medium': return 'priority-medium';
      case 'Low': return 'priority-low';
      default: return 'priority-default';
    }
  }
}
