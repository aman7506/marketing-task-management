import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BehaviorSubject, Observable, of, throwError } from 'rxjs';
import { map, catchError, retry } from 'rxjs/operators';
import { environment } from '../../environments/environment';

export interface User {
  userId: number;
  username: string;
  role: string;
  employeeId?: number;
  employeeName?: string;
}

export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  user: {
    userId: number;
    username: string;
    role: string;
    employeeId?: number;
    employeeName?: string;
  };
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private apiUrl = environment.apiUrl;
  private currentUserSubject: BehaviorSubject<User | null>;
  public currentUser$: Observable<User | null>;

  constructor(private http: HttpClient) {
    this.currentUserSubject = new BehaviorSubject<User | null>(this.getUserFromStorage());
    this.currentUser$ = this.currentUserSubject.asObservable();
    console.log('Auth Service - apiUrl:', this.apiUrl);
  }

  public get currentUserValue(): User | null {
    return this.currentUserSubject.value;
  }

  login(loginData: LoginRequest): Observable<LoginResponse> {
    const url = `${this.apiUrl}/auth/login`;
    console.log('Auth Service - Making API login call to:', url);
    
    // For development/testing when backend is unavailable
    if (!environment.production) {
      console.log('Auth Service - Using mock login in development mode');
      
      // Check if credentials match test accounts
      if (loginData.username === 'admin' && loginData.password === 'admin123') {
        const mockResponse: LoginResponse = {
          token: 'mock-jwt-token-for-admin-role',
          user: {
            userId: 1,
            username: 'admin',
            role: 'Admin'
          }
        };
        
        // Store token and user info
        localStorage.setItem('token', mockResponse.token);
        localStorage.setItem('user', JSON.stringify(mockResponse.user));
        this.currentUserSubject.next(mockResponse.user);
        
        return of(mockResponse);
      } else if (loginData.username === 'employee' && loginData.password === 'employee123') {
        const mockResponse: LoginResponse = {
          token: 'mock-jwt-token-for-employee-role',
          user: {
            userId: 2,
            username: 'employee',
            role: 'Employee',
            employeeId: 1,
            employeeName: 'Test Employee'
          }
        };
        
        // Store token and user info
        localStorage.setItem('token', mockResponse.token);
        localStorage.setItem('user', JSON.stringify(mockResponse.user));
        this.currentUserSubject.next(mockResponse.user);
        
        return of(mockResponse);
      }
    }
    
    return this.http.post<LoginResponse>(url, loginData)
      .pipe(
        retry(2), // Retry up to 2 times
        map(response => {
          console.log('Auth Service - Login response received:', response);
          
          // Store token and user info
          localStorage.setItem('token', response.token);
          console.log('Auth Service - Token stored in localStorage');
          
          const user: User = {
            userId: response.user.userId,
            username: response.user.username,
            role: response.user.role,
            employeeId: response.user.employeeId,
            employeeName: response.user.employeeName
          };
          
          localStorage.setItem('user', JSON.stringify(user));
          console.log('Auth Service - User stored in localStorage:', user);
          this.currentUserSubject.next(user);
          return response;
        }),
        catchError(error => {
          console.error('Auth Service - Login error:', error);
          
          // If connection error and we're in development, use mock login
          if (error.status === 0 && !environment.production) {
            console.log('Auth Service - Connection error, using mock login in development');
            
            // Default to admin login for connection errors
            const mockResponse: LoginResponse = {
              token: 'mock-jwt-token-for-admin-role',
              user: {
                userId: 1,
                username: 'admin',
                role: 'Admin'
              }
            };
            
            // Store token and user info
            localStorage.setItem('token', mockResponse.token);
            localStorage.setItem('user', JSON.stringify(mockResponse.user));
            this.currentUserSubject.next(mockResponse.user);
            
            return of(mockResponse);
          }
          
          return throwError(() => error);
        })
      );
  }

  logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    this.currentUserSubject.next(null);
  }

  isLoggedIn(): boolean {
    return !!this.getToken();
  }

  getToken(): string | null {
    return localStorage.getItem('token');
  }

  getCurrentUser(): User | null {
    return this.currentUserValue;
  }

  isAdmin(): boolean {
    const user = this.currentUserValue;
    return user?.role === 'Admin';
  }

  isEmployee(): boolean {
    const user = this.currentUserValue;
    return user?.role === 'Employee';
  }

  private getUserFromStorage(): User | null {
    const userStr = localStorage.getItem('user');
    return userStr ? JSON.parse(userStr) : null;
  }
}