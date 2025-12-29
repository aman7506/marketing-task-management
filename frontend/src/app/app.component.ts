import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from './services/auth.service';
import { NotificationService } from './services/notification.service';
import { trigger, state, style, transition, animate } from '@angular/animations';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
  animations: [
    trigger('slideInOut', [
      state('in', style({
        transform: 'translateY(0)',
        opacity: 1
      })),
      state('out', style({
        transform: 'translateY(-100%)',
        opacity: 0
      })),
      transition('in => out', animate('300ms ease-in-out')),
      transition('out => in', animate('300ms ease-in-out'))
    ])
  ]
})
export class AppComponent implements OnInit {
  title = 'marketing-form';
  notificationMessage = '';
  showNotification = false;
  notificationCount = 0;
  isLoggedIn: boolean = false;
  public authService: AuthService;

  constructor(
    authService: AuthService,
    private notificationService: NotificationService,
    private router: Router
  ) {
    this.authService = authService;
  }

  ngOnInit() {
    this.authService.currentUser$.subscribe(user => {
      this.isLoggedIn = !!user;
    });

    // Listen for notification count changes
    this.notificationService.notificationCount$.subscribe(count => {
      this.notificationCount = count;
    });

    // Listen for notification messages
    this.notificationService.notificationMessage$.subscribe(message => {
      if (message) {
        this.showNotificationToast(message);
      }
    });

    // Start notification connection if logged in
    if (this.isLoggedIn) {
      this.notificationService.startConnection();
    }

    window.addEventListener('unhandledrejection', (event) => {
      console.warn('Unhandled promise rejection:', event.reason);
      event.preventDefault();
    });
  }

  logout() {
    this.authService.logout();
    this.notificationService.stopConnection();
    this.router.navigate(['/login']);
  }

  showNotificationToast(message: string) {
    this.notificationMessage = message;
    this.showNotification = true;
    // Auto clear after 3 seconds
    setTimeout(() => {
      this.showNotification = false;
      this.notificationMessage = '';
    }, 3000);
  }

  openNotifications() {
    // Reset notification count when opening notifications
    this.notificationService.resetNotificationCount();
  }

  closeNotification() {
    this.showNotification = false;
  }
}
