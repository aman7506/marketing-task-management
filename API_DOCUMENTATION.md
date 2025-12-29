# 🔌 API DOCUMENTATION

## Base URL
```
Development: http://localhost:5005/api
Production: http://172.1.3.201:1010/api
```

## Authentication
All endpoints (except login/register) require JWT Bearer token.

**Header:**
```
Authorization: Bearer <your_jwt_token>
```

---

## 📋 Endpoints

### 🔐 Authentication

#### **Login**
```http
POST /api/auth/login
```

**Request Body:**
```json
{
  "email": "admin@actionmedical.com",
  "password": "Admin123!"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "name": "Admin User",
    "email": "admin@actionmedical.com",
    "role": "Admin"
  }
}
```

**Error Responses:**
- `400 Bad Request` - Missing fields
- `401 Unauthorized` - Invalid credentials

---

### 📝 Tasks

#### **Get All Tasks**
```http
GET /api/tasks
```

**Query Parameters:**
- `status` (optional) - Filter by status
- `assignedTo` (optional) - Filter by user ID

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "taskName": "Visit Locality ABC",
    "description": "Distribute pamphlets",
    "stateId": 1,
    "stateName": "Delhi",
    "cityId": 1,
    "cityName": "New Delhi",
    "localityId": 1,
    "localityName": "Connaught Place",
    "pincodeId": 1,
    "pincode": "110001",
    "assignedToId": 2,
    "assignedToName": "John Doe",
    "status": "Not Started",
    "scheduledDate": "2025-12-28T10:00:00",
    "createdAt": "2025-12-25T09:00:00"
  }
]
```

#### **Get Task by ID**
```http
GET /api/tasks/{id}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "taskName": "Visit Locality ABC",
  ...
}
```

**Error Responses:**
- `404 Not Found` - Task doesn't exist

#### **Create Task**
```http
POST /api/tasks
```

**Request Body:**
```json
{
  "taskName": "Visit Locality XYZ",
  "description": "Conduct survey",
  "stateId": 1,
  "cityId": 1,
  "localityId": 1,
  "pincodeId": 1,
  "assignedToId": 2,
  "scheduledDate": "2025-12-30T10:00:00"
}
```

**Response (201 Created):**
```json
{
  "id": 5,
  "taskName": "Visit Locality XYZ",
  ...
}
```

#### **Update Task Status**
```http
PUT /api/tasks/{id}/status
```

**Request Body:**
```json
{
  "status": "In Progress",
  "feedback": "Started the task"
}
```

**Response (200 OK):**
```json
{
  "message": "Status updated successfully"
}
```

**Valid Statuses:**
- `Not Started`
- `In Progress`
- `Completed`
- `Cancelled`

#### **Reschedule Task**
```http
POST /api/tasks/{id}/reschedule
```

**Request Body:**
```json
{
  "newDate": "2025-12-31T10:00:00",
  "reason": "Employee unavailable"
}
```

**Response (200 OK):**
```json
{
  "message": "Task rescheduled successfully"
}
```

---

### 👥 Users

#### **Get All Users**
```http
GET /api/users
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Admin User",
    "email": "admin@actionmedical.com",
    "role": "Admin",
    "phoneNumber": "9876543210"
  }
]
```

#### **Get Employees Only**
```http
GET /api/users/employees
```

**Response (200 OK):**
```json
[
  {
    "id": 2,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "Employee"
  }
]
```

#### **Create User**
```http
POST /api/users
```

**Request Body:**
```json
{
  "name": "New Employee",
  "email": "employee@example.com",
  "password": "Employee123!",
  "role": "Employee",
  "phoneNumber": "9876543210"
}
```

**Response (201 Created):**
```json
{
  "id": 10,
  "name": "New Employee",
  ...
}
```

---

### 📍 Locations (Areas)

#### **Get States**
```http
GET /api/areas/states
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Delhi"
  },
  {
    "id": 2,
    "name": "Maharashtra"
  }
]
```

#### **Get Cities by State**
```http
GET /api/areas/cities/{stateId}
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "New Delhi",
    "stateId": 1
  }
]
```

#### **Get Localities by City**
```http
GET /api/areas/localities/{cityId}
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Connaught Place",
    "cityId": 1
  }
]
```

#### **Get Pincodes by Locality**
```http
GET /api/areas/pincodes/{localityId}
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "pincode": "110001",
    "localityId": 1
  }
]
```

---

### 📢 Marketing Campaigns

#### **Get All Campaigns**
```http
GET /api/campaigns
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "campaignName": "Winter Sale 2025",
    "description": "Promote winter products",
    "stateId": 1,
    "stateName": "Delhi",
    "createdAt": "2025-12-01T00:00:00"
  }
]
```

#### **Create Campaign**
```http
POST /api/campaigns
```

**Request Body:**
```json
{
  "campaignName": "Summer Campaign",
  "description": "Summer products promotion",
  "stateId": 1,
  "cityId": 1,
  "localityId": 1,
  "pincodeId": 1
}
```

**Response (201 Created):**
```json
{
  "id": 5,
  "campaignName": "Summer Campaign",
  ...
}
```

---

## 🔔 SignalR Events

### Hub URL
```
http://localhost:5005/notificationHub
```

### Events from Server

#### **TaskUpdated**
```javascript
hubConnection.on('TaskUpdated', (taskId, status) => {
  console.log(`Task ${taskId} updated to ${status}`);
});
```

#### **NewTaskAssigned**
```javascript
hubConnection.on('NewTaskAssigned', (task) => {
  console.log('New task assigned:', task);
});
```

### Sending to Server

```typescript
await hubConnection.invoke('JoinUserGroup', userId);
await hubConnection.invoke('SendNotification', userId, message);
```

---

## 📊 Response Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Request successful |
| 201 | Created - Resource created |
| 204 | No Content - Successful, no data |
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Missing/invalid token |
| 403 | Forbidden - No permission |
| 404 | Not Found - Resource doesn't exist |
| 500 | Server Error - Internal error |

---

## 🔒 Authorization

### Roles
- **Admin** - Full access
- **Employee** - Limited access (own tasks only)

### Role-based Endpoints

**Admin Only:**
- `POST /api/tasks` - Create task
- `POST /api/users` - Create user
- `DELETE /api/tasks/{id}` - Delete task

**Employee:**
- `GET /api/tasks` - View assigned tasks only
- `PUT /api/tasks/{id}/status` - Update own tasks

---

## 📝 Error Response Format

```json
{
  "error": "Error message here",
  "field": "fieldName",
  "timestamp": "2025-12-27T10:30:00"
}
```

---

## 🧪 Testing with Swagger

Access Swagger UI at:
```
http://localhost:5005/swagger
```

**Features:**
- Test all endpoints
- View request/response schemas
- Try authentication
- See example payloads

---

## 📚 Additional Resources

- **Postman Collection:** Request from developer
- **Sample Requests:** See `DEVELOPER_GUIDE.md`
- **Database Schema:** See `DATABASE_SCHEMA.md`

---

**API Version:** 1.0  
**Last Updated:** December 2025
