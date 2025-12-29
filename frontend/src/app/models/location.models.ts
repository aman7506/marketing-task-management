export interface State {
  id: number;
  name: string;
  code?: string;
}

export interface City {
  id: number;
  name: string;
  stateId: number;
}

export interface Area {
  id: number;
  name: string;
  cityId: number;
  pincodes: string[];
}

export interface Pincode {
  id: number;
  value: string;
  areaId: number;
  localityName?: string;
}