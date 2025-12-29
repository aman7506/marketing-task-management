import { Component, OnInit } from '@angular/core';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { TaskService, Task as ServiceTask } from '../../services/task.service';
import { EmployeeService } from '../../services/employee.service';
import { DepartmentService } from '../../services/department.service';
import { Task as ModelTask } from '../../models/task.model';
import { AdminTaskModalComponent } from '../../components/admin-task-modal/admin-task-modal.component';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css']
})
export class DashboardComponent implements OnInit {
  tasks: ServiceTask[] = [];

  constructor(
    private taskService: TaskService,
    private employeeService: EmployeeService,
    private departmentService: DepartmentService,
    private modalService: NgbModal
  ) {}

  ngOnInit(): void {
    this.loadDashboardData();
  }

  private async loadDashboardData() {
    try {
      this.tasks = await this.taskService.getAllTasks().toPromise() ?? [];
      console.log('Loaded tasks:', this.tasks);
    } catch (error) {
      console.error('Error loading tasks:', error);
      this.tasks = [];
    }
  }

  async openCreateTaskModal() {
    try {
      const modalRef = this.modalService.open(AdminTaskModalComponent, {
        size: 'lg',
        backdrop: 'static'
      });

      modalRef.result.then((result: boolean) => {
        if (result) {
          this.refreshDashboard();
        }
      });
    } catch (error) {
      console.error('Error opening create task modal:', error);
    }
  }

  async refreshDashboard() {
    await this.loadDashboardData();
  }

  viewTask(task: ServiceTask) {
    // TODO: Implement view task details
    alert(`Viewing task: ${task.description}`);
  }

  editTask(task: ServiceTask) {
    // TODO: Implement edit task
    alert(`Editing task: ${task.description}`);
  }

  async deleteTask(task: ServiceTask) {
    if (confirm(`Are you sure you want to delete the task: ${task.description}?`)) {
      try {
        await this.taskService.deleteTask(task.taskId).toPromise();
        this.refreshDashboard();
      } catch (error) {
        console.error('Error deleting task:', error);
        alert('Failed to delete task');
      }
    }
  }
}
