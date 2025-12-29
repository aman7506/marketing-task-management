import { environment } from '../../environments/environment';

export const AppConfig = {
  useMockData: false,
  apiUrl: environment.apiUrl,
  signalRHubUrl: environment.signalRHubUrl,
  lanApiUrl: environment.lanApiUrl ?? environment.apiUrl,
  lanSignalRHubUrl: environment.lanSignalRHubUrl ?? environment.signalRHubUrl
};