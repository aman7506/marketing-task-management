export interface Task {
  taskId: number;
  employeeId: number;
  employeeName?: string;
  employeeContact?: string;
  employeeDesignation?: string;
  locationId?: number;
  locationName?: string;
  customLocation?: string;
  description: string;
  priority: string;
  taskDate: string;
  deadline: string;
  status: string;
  assignedByUserId: number;
  assignedByUserName?: string;
  taskType?: string;
  department?: string;
  clientName?: string;
  projectCode?: string;
  estimatedHours?: number;
  actualHours?: number;
  taskCategory?: string;
  additionalNotes?: string;
  consultantFeedback?: string;
  isUrgent?: boolean;
  stateId?: number;
  stateName?: string;
  cityId?: number;
  cityName?: string;
  areaId?: number;
  areaName?: string;
  pincodeId?: number;
  pincodeValue?: string;
  localityName?: string;
  createdAt: string;
  updatedAt: string;
}

export interface TaskReschedule {
  taskId: number;
  newTaskDate: string;
  newDeadline: string;
  rescheduleReason: string;
}

export interface TaskRescheduleHistory {
  rescheduleId: number;
  taskId: number;
  originalTaskDate: string;
  originalDeadline: string;
  newTaskDate: string;
  newDeadline: string;
  rescheduleReason: string;
  rescheduledAt: string;
}
