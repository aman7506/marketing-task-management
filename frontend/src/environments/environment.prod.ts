const serverBaseUrl = 'http://localhost:5005';

export const environment = {
  production: true,
  backendBaseUrl: serverBaseUrl,
  apiUrl: `${serverBaseUrl}/api`,
  apiBaseUrl: `${serverBaseUrl}/api`,
  signalRHubUrl: `${serverBaseUrl}/notificationHub`,
  trackingHubUrl: `${serverBaseUrl}/trackingHub`,
  lanTrackingHubUrl: `${serverBaseUrl}/trackingHub`
};