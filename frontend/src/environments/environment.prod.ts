const serverBaseUrl = 'https://marketing-api-u694.onrender.com';

export const environment = {
  production: true,
  backendBaseUrl: serverBaseUrl,
  apiUrl: `${serverBaseUrl}/api`,
  apiBaseUrl: `${serverBaseUrl}/api`,
  signalRHubUrl: `${serverBaseUrl}/notificationHub`,
  trackingHubUrl: `${serverBaseUrl}/trackingHub`,
  lanTrackingHubUrl: `${serverBaseUrl}/trackingHub`
};