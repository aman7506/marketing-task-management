import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { AuthService } from './auth.service';
import { environment } from '../../environments/environment';

export interface EmployeeFeedback {
  feedbackId: number;
  taskId: number;
  taskDescription: string;
  employeeId: number;
  employeeName: string;
  consultantName?: string;
  feedbackText: string;
  meetingDate?: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateEmployeeFeedbackRequest {
  taskId: number;
  consultantName?: string;
  feedbackText: string;
  meetingDate?: string;
}

export interface UpdateEmployeeFeedbackRequest {
  consultantName?: string;
  feedbackText: string;
  meetingDate?: string;
}

@Injectable({
  providedIn: 'root'
})
export class EmployeeFeedbackService {
  private apiUrl = `${environment.apiUrl}/employeefeedback`;

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) {}

  private getHttpOptions() {
    const token = this.authService.getToken();
    return {
      headers: new HttpHeaders({
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      })
    };
  }

  // Get all feedback for the current employee
  getMyFeedback(): Observable<EmployeeFeedback[]> {
    return this.http.get<EmployeeFeedback[]>(`${this.apiUrl}/my-feedback`, this.getHttpOptions());
  }

  // Get feedback for a specific task
  getFeedbackByTask(taskId: number): Observable<EmployeeFeedback[]> {
    return this.http.get<EmployeeFeedback[]>(`${this.apiUrl}/task/${taskId}`, this.getHttpOptions());
  }

  // Get feedback by ID
  getFeedbackById(feedbackId: number): Observable<EmployeeFeedback> {
    return this.http.get<EmployeeFeedback>(`${this.apiUrl}/${feedbackId}`, this.getHttpOptions());
  }

  // Create new feedback
  createFeedback(request: CreateEmployeeFeedbackRequest): Observable<EmployeeFeedback> {
    return this.http.post<EmployeeFeedback>(this.apiUrl, request, this.getHttpOptions());
  }

  // Update feedback
  updateFeedback(feedbackId: number, request: UpdateEmployeeFeedbackRequest): Observable<EmployeeFeedback> {
    return this.http.put<EmployeeFeedback>(`${this.apiUrl}/${feedbackId}`, request, this.getHttpOptions());
  }

  // Delete feedback
  deleteFeedback(feedbackId: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${feedbackId}`, this.getHttpOptions());
  }

  getFeedbackByEmployee(employeeId: number): Observable<EmployeeFeedback[]> {
    return this.http.get<EmployeeFeedback[]>(`${this.apiUrl}/employee/${employeeId}`, this.getHttpOptions());
  }
}
