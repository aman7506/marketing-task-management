import { Injectable } from '@angular/core';
import { HttpInterceptor, HttpRequest, HttpHandler, HttpEvent, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { Router } from '@angular/router';

@Injectable()
export class AuthInterceptor implements HttpInterceptor {
  constructor(private router: Router) {}

  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    const token = localStorage.getItem('token');

    let headers = req.headers;
    if (!headers.has('Content-Type') && !(req.body instanceof FormData)) {
      headers = headers.set('Content-Type', 'application/json');
    }
    if (token && !headers.has('Authorization')) {
      headers = headers.set('Authorization', `Bearer ${token}`);
    }

    const authReq = req.clone({ headers });

    return next.handle(authReq).pipe(
      catchError((error: HttpErrorResponse) => {
        if (error.status === 401) {
          // Token missing/expired/invalid – force logout and redirect
          localStorage.removeItem('token');
          localStorage.removeItem('user');
          try { this.router.navigate(['/login']); } catch {}
        }
        return throwError(() => error);
      })
    );
  }
}