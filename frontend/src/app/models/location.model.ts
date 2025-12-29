export interface State {
  stateId: number;
  name: string;
}

export interface City {
  cityId: number;
  stateId: number;
  name: string;
}

export interface Area {
  areaId: number;
  cityId: number;
  stateId: number;
  name: string;
}

export interface Pincode {
  id: number;
  areaId: number;
  code: string;
}
