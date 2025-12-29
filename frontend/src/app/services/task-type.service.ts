import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface TaskType {
  taskTypeId: number;
  typeName: string;
  description?: string;
  isActive: boolean;
}

@Injectable({
  providedIn: 'root'
})
export class TaskTypeService {
  private apiUrl = `${environment.apiUrl}/tasktypes`;

  constructor(private http: HttpClient) { }

  getAllTaskTypes(): Observable<TaskType[]> {
    return this.http.get<TaskType[]>(this.apiUrl);
  }

  getTaskTypeById(id: number): Observable<TaskType> {
    return this.http.get<TaskType>(`${this.apiUrl}/${id}`);
  }

  createTaskType(taskType: Partial<TaskType>): Observable<TaskType> {
    return this.http.post<TaskType>(this.apiUrl, taskType);
  }

  updateTaskType(id: number, taskType: Partial<TaskType>): Observable<any> {
    return this.http.put<any>(`${this.apiUrl}/${id}`, taskType);
  }

  deleteTaskType(id: number): Observable<any> {
    return this.http.delete<any>(`${this.apiUrl}/${id}`);
  }
}