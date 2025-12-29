// This file can be replaced during build by using the `fileReplacements` array.
// `ng build` replaces `environment.ts` with `environment.prod.ts`.
// The list of file replacements can be found in `angular.json`.

const localBackendBaseUrl = 'http://localhost:5005';
const lanBackendBaseUrl = 'http://172.1.3.201:1010';

export const environment = {
  production: false,
  backendBaseUrl: localBackendBaseUrl,
  apiUrl: `${localBackendBaseUrl}/api`,
  apiBaseUrl: `${localBackendBaseUrl}/api`,
  signalRHubUrl: `${localBackendBaseUrl}/notificationHub`,
  trackingHubUrl: `${localBackendBaseUrl}/trackingHub`,
  lanBackendBaseUrl,
  lanApiUrl: `${lanBackendBaseUrl}/api`,
  lanSignalRHubUrl: `${lanBackendBaseUrl}/notificationHub`,
  lanTrackingHubUrl: `${lanBackendBaseUrl}/trackingHub`
};
