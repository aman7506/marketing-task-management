import { Injectable } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

@Injectable({
  providedIn: 'root'
})
export class RoleGuard implements CanActivate {
  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  canActivate(route: ActivatedRouteSnapshot): boolean {
    const requiredRole = route.data['role'];
    const currentUser = this.authService.getCurrentUser();

    if (currentUser && currentUser.role === requiredRole) {
      return true;
    } else {
      // Redirect to appropriate dashboard based on user role
      if (currentUser?.role === 'Admin') {
        this.router.navigate(['/admin/dashboard']);
      } else if (currentUser?.role === 'Employee') {
        this.router.navigate(['/employee/dashboard']);
      } else {
        this.router.navigate(['/login']);
      }
      return false;
    }
  }
} 