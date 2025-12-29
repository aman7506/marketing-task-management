import { Component, Input, Output, EventEmitter, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { TaskService } from '../../services/task.service';
import { NotificationService } from '../../services/notification.service';
import { Task, TaskReschedule } from '../../models/task.model';

@Component({
  selector: 'app-task-reschedule-modal',
  templateUrl: './task-reschedule-modal.component.html',
  styleUrls: ['./task-reschedule-modal.component.css'],
})
export class TaskRescheduleModalComponent implements OnInit {
  @Input() task: Task | null = null;
  @Input() show = false;
  @Output() close = new EventEmitter<void>();
  @Output() taskRescheduled = new EventEmitter<TaskReschedule>();

  rescheduleForm: FormGroup;
  isSubmitting = false;
  minDate: string;
  minDeadlineDate: string;

  constructor(
    private fb: FormBuilder,
    private taskService: TaskService,
    private notificationService: NotificationService
  ) {
    this.rescheduleForm = this.fb.group({
      newTaskDate: ['', Validators.required],
      newDeadline: ['', Validators.required],
      rescheduleReason: ['', [Validators.required, Validators.maxLength(500)]]
    });

    const today = new Date();
    this.minDate = today.toISOString().split('T')[0];
    this.minDeadlineDate = this.minDate;
  }

  ngOnInit() {
    this.rescheduleForm.get('newTaskDate')?.valueChanges.subscribe(taskDate => {
      if (taskDate) {
        const taskDateObj = new Date(taskDate);
        taskDateObj.setDate(taskDateObj.getDate() + 1);
        this.minDeadlineDate = taskDateObj.toISOString().split('T')[0];

        const currentDeadline = this.rescheduleForm.get('newDeadline')?.value;
        if (currentDeadline && new Date(currentDeadline) <= new Date(taskDate)) {
          this.rescheduleForm.get('newDeadline')?.setValue('');
        }
      }
    });
  }

  onSubmit() {
    if (this.rescheduleForm.valid && this.task && !this.isSubmitting) {
      this.isSubmitting = true;

      const rescheduleData: TaskReschedule = {
        taskId: this.task.taskId,
        newTaskDate: this.rescheduleForm.value.newTaskDate,
        newDeadline: this.rescheduleForm.value.newDeadline,
        rescheduleReason: this.rescheduleForm.value.rescheduleReason
      };

      this.taskService.rescheduleTask(this.task.taskId, rescheduleData).subscribe({
        next: (rescheduledTask) => {
          console.log('Task rescheduled successfully:', rescheduledTask);
          this.notificationService.showNotification('Task rescheduled successfully', 'success');
          this.taskRescheduled.emit(rescheduleData);
          this.onClose();
          this.isSubmitting = false;
        },
        error: (error) => {
          console.error('Error rescheduling task:', error);
          const errorMessage = error?.error?.details || error?.error?.error || 'Error rescheduling task. Please try again.';
          this.notificationService.showNotification(errorMessage, 'error');
          this.isSubmitting = false;
        }
      });
    } else {
      this.markFormGroupTouched();
    }
  }

  onClose() {
    this.rescheduleForm.reset();
    this.isSubmitting = false;
    this.close.emit();
  }

  private markFormGroupTouched() {
    Object.keys(this.rescheduleForm.controls).forEach(key => {
      const control = this.rescheduleForm.get(key);
      control?.markAsTouched();
    });
  }

  get newTaskDate() {
    return this.rescheduleForm.get('newTaskDate');
  }

  get newDeadline() {
    return this.rescheduleForm.get('newDeadline');
  }

  get rescheduleReason() {
    return this.rescheduleForm.get('rescheduleReason');
  }

  formatDate(dateString: string): string {
    return new Date(dateString).toLocaleDateString();
  }

  formatDateTime(dateString: string): string {
    return new Date(dateString).toLocaleString();
  }

  getRemainingCharacters(): number {
    const reason = this.rescheduleReason?.value || '';
    return 500 - reason.length;
  }

  isDeadlineValid(): boolean {
    const taskDate = this.newTaskDate?.value;
    const deadline = this.newDeadline?.value;
    if (!taskDate || !deadline) return true;
    return new Date(deadline) > new Date(taskDate);
  }
}