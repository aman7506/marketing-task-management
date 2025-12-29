import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, of } from 'rxjs';

export interface Department {
  id: number;
  name: string;
}

@Injectable({
  providedIn: 'root'
})
export class DepartmentService {
  private apiUrl = 'api/departments';

  private mockDepartments: Department[] = [
    { id: 1, name: 'Marketing' },
    { id: 2, name: 'Sales' },
    { id: 3, name: 'Operations' }
  ];

  constructor(private http: HttpClient) {}

  getDepartments(): Observable<Department[]> {
    return of(this.mockDepartments);
  }
}