import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { TaskType } from './task-type.service';
import { TaskReschedule } from '../models/task.model';
import { map } from 'rxjs/operators';

export interface Task {
  taskId: number;
  description: string;
  status: string;
  priority: string;
  employeeId: number;
  employeeName: string;
  employee?: {
    employeeId: number;
    name: string;
    designation: string;
    contact: string;
    employeeCode: string;
  };
  locationId?: number;
  location?: {
    locationId: number;
    locationName: string;
  };
  customLocation?: string;
  taskDate: string;
  deadline: string;
  taskType?: string;
  department?: string;
  consultantName?: string;
  campCode?: string;
  estimatedHours?: number;
  actualHours?: number;
  taskCategory?: string;
  additionalNotes?: string;
  isUrgent: boolean;
  createdAt: string;
  updatedAt: string;
  assignedByUserId: number;
  assignedByUserName: string;
  employeeCode?: string;
  stateId?: number;
  stateName?: string;
  cityId?: number;
  cityName?: string;
  areaId?: number;
  areaName?: string;
  pincodeId?: number;
  pincodeValue?: string;
  localityName?: string;
  consultantFeedback?: string;
  taskTypes: Array<{
    taskTypeId: number;
    taskTypeName: string;
  }>;
  locations: Array<{
    locationId: number;
    locationName: string;
  }>;
  feedback?: Array<{
    feedbackId: number;
    remarks: string;
    createdAt: string;
    employeeName: string;
  }>;
}

export interface TaskCreateDto {
  employeeId: number;
  locationId?: number;
  customLocation?: string;
  description: string;
  priority: string;
  taskDate: string | Date;
  deadline: string | Date;
  taskType?: string;
  department?: string;
  clientName?: string;
  projectCode?: string;
  consultantName?: string;
  campCode?: string;
  estimatedHours?: number;
  actualHours?: number;
  taskCategory?: string;
  additionalNotes?: string;
  isUrgent?: boolean;
  employeeCode?: string;
  
  // Location hierarchy fields
  stateId?: number;
  stateName?: string;
  cityId?: number;
  cityName?: string;
  areaId?: number;
  areaName?: string;
  pincodeId?: number;
  pincodeValue?: string;
  localityName?: string;
  
  // Marketing specific fields
  consultantFeedback?: string;
  taskTypeIds?: number[];
  locationIds?: number[];
  areaIds?: number[];
  areaNames?: string[];
  
  // Campaign specific fields
  expectedReach?: number;
  conversionGoal?: string;
  kpis?: string;
  marketingMaterials?: string;
  approvalRequired?: boolean;
  approvalContact?: string;
  budgetCode?: string;
  departmentCode?: string;
}

export interface TaskUpdateDto {
  employeeId: number;
  locationId?: number;
  customLocation?: string;
  description: string;
  priority: string;
  taskDate: string | Date;
  deadline: string | Date;
  status: string;
  taskType?: string;
  department?: string;
  clientName?: string;
  projectCode?: string;
  consultantName?: string;
  campCode?: string;
  estimatedHours?: number;
  actualHours?: number;
  taskCategory?: string;
  additionalNotes?: string;
  isUrgent?: boolean;
  employeeCode?: string;
  
  // Location hierarchy fields
  stateId?: number;
  stateName?: string;
  cityId?: number;
  cityName?: string;
  areaId?: number;
  areaName?: string;
  pincodeId?: number;
  pincodeValue?: string;
  localityName?: string;
  
  // Marketing specific fields
  consultantFeedback?: string;
  taskTypeIds?: number[];
  locationIds?: number[];
  areaIds?: number[];
  areaNames?: string[];
  
  // Campaign specific fields
  expectedReach?: number;
  conversionGoal?: string;
  kpis?: string;
  marketingMaterials?: string;
  approvalRequired?: boolean;
  approvalContact?: string;
  budgetCode?: string;
  departmentCode?: string;
}

export { TaskReschedule } from '../models/task.model';

@Injectable({
  providedIn: 'root'
})
export class TaskService {
  private apiUrl = `${environment.apiUrl}/tasks`;

  constructor(private http: HttpClient) { }

  getAllTasks(status?: string, employeeId?: number): Observable<Task[]> {
    let url = this.apiUrl;
    const params = new URLSearchParams();
    
    if (status) {
      params.append('status', status);
    }
    
    if (employeeId) {
      params.append('employeeId', employeeId.toString());
    }
    
    if (params.toString()) {
      url += `?${params.toString()}`;
    }
    
    return this.http.get<Task[]>(url);
  }

  getTaskById(id: number): Observable<Task> {
    return this.http.get<Task>(`${this.apiUrl}/${id}`);
  }

  createTask(task: TaskCreateDto): Observable<any> {
    return this.http.post<any>(this.apiUrl, task).pipe(
      map(response => {
        console.log('Task created successfully:', response);
        return response;
      })
    );
  }

  updateTask(id: number, task: TaskUpdateDto): Observable<any> {
    return this.http.put<any>(`${this.apiUrl}/${id}`, task).pipe(
      map(response => {
        console.log('Task updated successfully:', response);
        return response;
      })
    );
  }

  deleteTask(id: number): Observable<any> {
    return this.http.delete<any>(`${this.apiUrl}/${id}`).pipe(
      map(response => {
        console.log('Task deleted successfully:', response);
        return response;
      })
    );
  }
  
  getTasks(status?: string, employeeId?: number): Observable<Task[]> {
    return this.getAllTasks(status, employeeId);
  }
  
  updateTaskStatus(taskId: number, status: string, remarks?: string): Observable<any> {
    return this.http.put<any>(`${this.apiUrl}/${taskId}/status`, { status, remarks });
  }

  getTaskTypes(): Observable<TaskType[]> {
    // You may want to inject TaskTypeService instead, but for now, call the endpoint directly
    return this.http.get<TaskType[]>(`${environment.apiUrl}/tasktypes`);
  }

  rescheduleTask(taskId: number, reschedule: TaskReschedule): Observable<any> {
    return this.http.put<any>(`${this.apiUrl}/${taskId}/reschedule`, reschedule);
  }

  getCurrentUserRole(): Observable<string> {
    // Dummy implementation, replace with real API if available
    return new Observable(observer => {
      observer.next('admin');
      observer.complete();
    });
  }
}