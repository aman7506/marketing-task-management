import { Injectable, EventEmitter, OnDestroy } from '@angular/core';
import { HubConnection, HubConnectionBuilder, HttpTransportType, LogLevel } from '@microsoft/signalr';
import { BehaviorSubject, Observable } from 'rxjs';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class NotificationService implements OnDestroy {
  private hubConnection: HubConnection | null = null;
  private notificationCountSubject = new BehaviorSubject<number>(0);
  private notificationMessageSubject = new BehaviorSubject<string>('');
  private isConnected = false;
  
  public notificationReceived = new EventEmitter<any>();
  public connectionStateChanged = new EventEmitter<boolean>();

  public notificationCount$ = this.notificationCountSubject.asObservable();
  public notificationMessage$ = this.notificationMessageSubject.asObservable();

  constructor() {
    this.initializeConnection();
  }

  public initializeConnection(): void {
    try {
      const hubUrl = (environment as any).signalRHubUrl || (environment as any).hubUrl;
      console.log('Initializing SignalR connection to:', hubUrl);
      
      // If there's an existing connection, stop it first
      if (this.hubConnection) {
        this.stopConnection();
      }
      
      // Get token for authentication
      const token = localStorage.getItem('token') || '';
      console.log('Token available for SignalR:', token ? 'Yes' : 'No');
      
      this.hubConnection = new HubConnectionBuilder()
        .withUrl(hubUrl, {
          transport: HttpTransportType.WebSockets | HttpTransportType.LongPolling,
          skipNegotiation: false,
          accessTokenFactory: () => token
        })
        .withAutomaticReconnect({
          nextRetryDelayInMilliseconds: retryContext => {
            // Exponential backoff with max delay of 30 seconds
            const nextRetry = Math.pow(2, retryContext.previousRetryCount) * 1000;
            return Math.min(nextRetry, 30000);
          }
        })
        .configureLogging(LogLevel.Information)
        .build();

      // Set up connection state change handlers
      this.hubConnection.onreconnecting(error => {
        console.log('SignalR reconnecting due to error:', error);
        this.isConnected = false;
        this.connectionStateChanged.emit(false);
      });
      
      this.hubConnection.onreconnected(connectionId => {
        console.log('SignalR reconnected with connectionId:', connectionId);
        this.isConnected = true;
        this.connectionStateChanged.emit(true);
      });
      
      this.hubConnection.onclose(error => {
        console.log('SignalR connection closed due to error:', error);
        this.isConnected = false;
        this.connectionStateChanged.emit(false);
        
        // Try to reconnect after 10 seconds
        setTimeout(() => this.startConnection(), 10000);
      });

      this.setupSignalRHandlers();
      this.startConnection();
    } catch (error) {
      console.warn('SignalR connection initialization failed - backend may not be running:', error);
      this.isConnected = false;
      this.connectionStateChanged.emit(false);
      
      // Don't retry immediately to avoid spam - wait 30 seconds
      setTimeout(() => {
        console.log('Retrying SignalR connection...');
        this.initializeConnection();
      }, 30000);
    }
  }

  public async startConnection(): Promise<void> {
    if (!this.hubConnection) {
      this.initializeConnection();
      return;
    }

    // Check if already connected or connecting
    if (this.hubConnection.state === 'Connected') {
      console.log('SignalR already connected');
      this.isConnected = true;
      this.connectionStateChanged.emit(true);
      return;
    }

    if (this.hubConnection.state === 'Connecting') {
      console.log('SignalR connection already in progress');
      return;
    }

    const hubUrl = (environment as any).signalRHubUrl || (environment as any).hubUrl;
    console.log('Attempting to connect to SignalR hub at:', hubUrl);
    
    try {
      await this.hubConnection.start();
      console.log('SignalR Connected successfully');
      this.isConnected = true;
      this.connectionStateChanged.emit(true);
    } catch (err) {
      console.warn('SignalR Connection Error - backend may not be running:', err);
      this.isConnected = false;
      this.connectionStateChanged.emit(false);
      
      // Retry connection after 30 seconds to avoid spam
      setTimeout(() => {
        console.log('Retrying SignalR connection...');
        this.startConnection();
      }, 30000);
    }
  }

  private setupSignalRHandlers() {
    if (!this.hubConnection) return;

    this.hubConnection.on('TaskNotification', (action: string, taskId: number, taskDescription: string) => {
      const message = `${action} - Task #${taskId}: ${taskDescription}`;
      this.showNotification(message);
      this.incrementNotificationCount();
      this.notificationReceived.emit({ action, taskId, taskDescription });
    });

    this.hubConnection.on('ReceiveMessage', (user: string, message: string) => {
      const notificationMessage = `${user}: ${message}`;
      this.showNotification(notificationMessage);
      this.notificationReceived.emit({ user, message });
    });

    this.hubConnection.on('TaskAssigned', (taskId: number, employeeName: string) => {
      const message = `New task assigned to ${employeeName}`;
      this.showNotification(message);
      this.incrementNotificationCount();
      this.notificationReceived.emit({ action: 'TaskAssigned', taskId, employeeName });
    });

    this.hubConnection.on('UserConnected', (connectionId: string) => {
      console.log('User connected with connection ID:', connectionId);
    });

    this.hubConnection.on('UserDisconnected', (connectionId: string) => {
      console.log('User disconnected with connection ID:', connectionId);
    });
  }

  showNotification(message: string, type: 'success' | 'error' | 'info' = 'success') {
    this.notificationMessageSubject.next(message);
    
    // Show toast notification
    this.showToast(message, type);
  }

  private showToast(message: string, type: 'success' | 'error' | 'info') {
    // Create toast element
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.textContent = message;
    
    // Style the toast
    Object.assign(toast.style, {
      position: 'fixed',
      top: '20px',
      right: '20px',
      padding: '12px 20px',
      borderRadius: '8px',
      color: 'white',
      fontWeight: '500',
      zIndex: '10000',
      maxWidth: '400px',
      boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
      backgroundColor: type === 'success' ? '#28a745' : type === 'error' ? '#dc3545' : '#17a2b8',
      wordWrap: 'break-word'
    });
    
    document.body.appendChild(toast);
    
    // Remove toast after 3 seconds
    setTimeout(() => {
      if (toast.parentNode) {
        toast.parentNode.removeChild(toast);
      }
    }, 3000);
  }

  private incrementNotificationCount() {
    this.notificationCountSubject.next(this.notificationCountSubject.value + 1);
  }

  public async stopConnection(): Promise<void> {
    if (this.hubConnection && this.hubConnection.state === 'Connected') {
      try {
        await this.hubConnection.stop();
        console.log('SignalR Disconnected');
        this.isConnected = false;
        this.connectionStateChanged.emit(false);
      } catch (err) {
        console.error('Error stopping SignalR connection: ' + err);
      }
    }
  }

  public sendMessage(user: string, message: string): void {
    if (this.hubConnection && this.hubConnection.state === 'Connected') {
      this.hubConnection.invoke('SendMessage', user, message)
        .catch(err => console.error('SendMessage error: ' + err));
    }
  }

  public sendTaskNotification(action: string, taskId: number, taskDescription: string): void {
    if (this.hubConnection && this.hubConnection.state === 'Connected') {
      this.hubConnection.invoke('SendTaskNotification', action, taskId, taskDescription)
        .catch(err => console.error('SendTaskNotification error: ' + err));
    }
  }

  ngOnDestroy(): void {
    this.stopConnection();
  }

  resetNotificationCount() {
    this.notificationCountSubject.next(0);
  }
}
