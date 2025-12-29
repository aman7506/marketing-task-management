import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { HttpClientModule } from '@angular/common/http';
import { ReactiveFormsModule, FormsModule } from '@angular/forms';
import { RouterModule, Routes } from '@angular/router';
import { NgbModule } from '@ng-bootstrap/ng-bootstrap';

// Components
import { AppComponent } from './app.component';
import { LoginComponent } from './components/login/login.component';
import { TaskAssignmentComponent } from './components/task-assignment/task-assignment.component';
import { EmployeeDashboardComponent } from './components/employee-dashboard/employee-dashboard.component';
import { AdminDashboardComponent } from './components/admin-dashboard/admin-dashboard.component';
import { HierarchicalLocationSelectorComponent } from './components/hierarchical-location-selector/hierarchical-location-selector.component';
import { TaskRescheduleModalComponent } from './components/task-reschedule-modal/task-reschedule-modal.component';
import { SearchableDropdownComponent } from './components/searchable-dropdown/searchable-dropdown.component';
import { AdminTaskModalComponent } from './components/admin-task-modal/admin-task-modal.component';
import { MarketingFormComponent } from './components/marketing-form/marketing-form.component';
import { TrackingComponent } from './components/tracking/tracking.component';
import { LocationSelectorComponent } from './components/location-selector/location-selector.component';
// Services
import { AuthService } from './services/auth.service';
import { LocationHierarchyService } from './services/location-hierarchy.service';
import { TaskService } from './services/task.service';
import { EmployeeService } from './services/employee.service';
import { LocationService } from './services/location.service';
import { NotificationService } from './services/notification.service';

// Guards
import { AuthGuard } from './guards/auth.guard';
import { RoleGuard } from './guards/role.guard';

// Interceptors
import { AuthInterceptor } from './interceptors/auth.interceptor';
import { HTTP_INTERCEPTORS } from '@angular/common/http';

export const routes: Routes = [
  { path: '', redirectTo: '/login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },

  {
    path: 'admin',
    canActivate: [AuthGuard, RoleGuard],
    data: { role: 'Admin' },
    children: [
      { path: 'dashboard', component: AdminDashboardComponent },
      { path: 'assign-task', component: TaskAssignmentComponent },
      { path: 'marketing-form', component: MarketingFormComponent },
      { path: 'tracking', component: TrackingComponent },
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' }
    ]
  },

  {
    path: 'employee',
    canActivate: [AuthGuard, RoleGuard],
    data: { role: 'Employee' },
    children: [
      { path: 'dashboard', component: EmployeeDashboardComponent },
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' }
    ]
  },

  { path: '**', redirectTo: '/login' }
];

@NgModule({
  declarations: [
    AppComponent,
    LoginComponent,
    TaskAssignmentComponent,
    EmployeeDashboardComponent,
    AdminDashboardComponent,
    HierarchicalLocationSelectorComponent,
    TaskRescheduleModalComponent,
    SearchableDropdownComponent,
    AdminTaskModalComponent,
    MarketingFormComponent,
    TrackingComponent,
    LocationSelectorComponent
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    HttpClientModule,
    ReactiveFormsModule,
    FormsModule,
    RouterModule.forRoot(routes),
    NgbModule
  ],
  providers: [
    AuthService,
    TaskService,
    EmployeeService,
    LocationService,
    LocationHierarchyService,
    NotificationService,
    AuthGuard,
    RoleGuard,
    {
      provide: HTTP_INTERCEPTORS,
      useClass: AuthInterceptor,
      multi: true
    }
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
