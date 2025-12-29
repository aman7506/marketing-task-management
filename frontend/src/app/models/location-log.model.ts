export interface LocationLog {
  logId: number;
  employeeId: number;
  latitude: number;
  longitude: number;
  timestamp: string;
}

export interface LocationUpdateRequest {
  employeeId: number;
  latitude: number;
  longitude: number;
  timestamp?: string;
}

export interface SimulateTripRequest {
  employeeId: number;
  startLatitude: number;
  startLongitude: number;
  endLatitude: number;
  endLongitude: number;
  waypoints: number;
  intervalSeconds: number;
}

