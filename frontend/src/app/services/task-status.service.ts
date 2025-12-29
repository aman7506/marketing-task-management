import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface TaskStatus {
  statusId: number;
  statusName: string;
  statusCode: string;
  isActive: boolean;
}

@Injectable({
  providedIn: 'root'
})
export class TaskStatusService {
  private apiUrl = `${environment.apiUrl}/taskstatuses`;

  constructor(private http: HttpClient) { }

  getAllTaskStatuses(): Observable<TaskStatus[]> {
    return this.http.get<TaskStatus[]>(this.apiUrl);
  }

  getTaskStatusById(id: number): Observable<TaskStatus> {
    return this.http.get<TaskStatus>(`${this.apiUrl}/${id}`);
  }

  createTaskStatus(taskStatus: Partial<TaskStatus>): Observable<TaskStatus> {
    return this.http.post<TaskStatus>(this.apiUrl, taskStatus);
  }

  updateTaskStatus(id: number, taskStatus: Partial<TaskStatus>): Observable<any> {
    return this.http.put<any>(`${this.apiUrl}/${id}`, taskStatus);
  }

  deleteTaskStatus(id: number): Observable<any> {
    return this.http.delete<any>(`${this.apiUrl}/${id}`);
  }
}
