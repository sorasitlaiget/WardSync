# WardSync Backend — Integration Guide

## What is WardSync?

WardSync is a real-time field hospital management system. It handles patient triage, vital signs monitoring, treatment records, medication inventory, and room capacity tracking. The backend is built with **Express.js + TypeScript + Firebase (Firestore, Auth, Storage, FCM)**.

This document is written for the Flutter frontend team. If you are using an AI assistant to help you integrate, share this entire file as context.

---

## Base URLs

| Environment | URL |
|-------------|-----|
| Local (emulator) | `http://localhost:3000` |
| Production | TBD |

---

## Authentication

Every request (except login) requires a Firebase ID Token in the Authorization header:

```
Authorization: Bearer <idToken>
```

### How to get a token (Login)

```
POST http://localhost:9099/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-key

Body (JSON):
{
  "email": "user@example.com",
  "password": "password123",
  "returnSecureToken": true
}

Response:
{
  "idToken": "eyJhbGci..."   ← use this as Bearer token
}
```

> In production, use the real Firebase Auth SDK in Flutter (`signInWithEmailAndPassword`). The `idToken` is obtained via `user.getIdToken()`.

### First-time login flow

1. User logs in → gets `idToken`
2. Call `GET /api/users/profile`
3. If response has `isProfileComplete: false` → redirect to profile setup screen
4. User fills in name, role, assigned room → `PATCH /api/users/profile`
5. After profile is complete → proceed to main app

---

## Roles & Permissions

There are 3 roles: `nurse`, `doctor`, `admin`.

| Endpoint / Action | nurse | doctor | admin |
|---|:---:|:---:|:---:|
| View own profile | ✅ | ✅ | ✅ |
| Complete profile | ✅ | ✅ | ✅ |
| Update FCM token | ✅ | ✅ | ✅ |
| List all users | ❌ | ❌ | ✅ |
| Create user account | ❌ | ❌ | ✅ |
| Change user role | ❌ | ❌ | ✅ |
| Create patient | ✅ | ❌ | ❌ |
| List patients | ✅ (all rooms) | ✅ (own room only) | ✅ (all rooms) |
| View patient detail | ✅ | ✅ | ✅ |
| Change patient status | ❌ | ✅ | ❌ |
| Add / edit vitals | ✅ | ✅ | ❌ |
| Add / edit treatments | ❌ | ✅ | ❌ |
| View vitals & treatments | ✅ | ✅ | ✅ |
| View medication list | ✅ | ✅ | ✅ |
| Manage medication inventory | ❌ | ❌ | ✅ |
| View room capacity | ✅ | ✅ | ✅ |
| Set room capacity | ❌ | ❌ | ✅ |
| View statistics charts | ❌ | ❌ | ✅ |

> **Doctor room filter**: Doctors automatically see only patients in their assigned room. To see all rooms, add `?room=all`.

> **Nurse**: Does not have an `assignedRoom`. Can see all patients across all rooms.

---

## Error Response Format

All errors follow this format:

```json
{
  "statusCode": 404,
  "error": "Not Found",
  "message": "Patient not found"
}
```

| Status Code | Meaning |
|---|---|
| 400 | Bad Request — invalid or missing fields |
| 401 | Unauthorized — missing or expired token |
| 403 | Forbidden — role does not have permission |
| 404 | Not Found |
| 409 | Conflict — e.g. wristband number already in use |

---

## User Management (F1)

### Get my profile
```
GET /api/users/profile

Response:
{
  "uid": "abc123",
  "email": "nurse@hospital.com",
  "displayName": "Nurse Anna",
  "role": "nurse",
  "assignedRoom": null,
  "isProfileComplete": true,
  "fcmToken": "..."
}
```

### Complete / update profile
```
PATCH /api/users/profile

Body:
{
  "displayName": "Dr. Smith",
  "role": "doctor",
  "assignedRoom": "red"
}
```

> `assignedRoom` is required for `doctor` and `admin`. Valid values: `red`, `yellow`, `green`, `black`.  
> `nurse` does not need `assignedRoom`.

### Update FCM token (call this on every app launch)
```
PATCH /api/users/fcm-token

Body:
{ "fcmToken": "<token from Firebase Messaging>" }
```

### Admin: List all users
```
GET /api/users
```

### Admin: Create a new user account
```
POST /api/users

Body:
{
  "email": "doctor@hospital.com",
  "password": "initial123",
  "displayName": "Dr. Smith",
  "role": "doctor",
  "assignedRoom": "red"
}
```

### Admin: Change user role
```
PATCH /api/users/:uid/role

Body:
{
  "role": "doctor",
  "assignedRoom": "yellow"
}
```

---

## Patient Management (F2, F3, F5)

### Create patient (nurse only) — multipart/form-data
```
POST /api/patients
Content-Type: multipart/form-data

Fields:
  wristbandNumber  string   e.g. "003"
  triageColor      string   red | yellow | green | black
  sex              string   male | female
  ageRange         string   infant | child | adult | elder

File (optional):
  photo            image file (jpg/png)

Response: Patient object (see below)
```

### Patient object structure
```json
{
  "id": "abc123",
  "wristbandNumber": "003",
  "triageColor": "red",
  "sex": "male",
  "ageRange": "adult",
  "status": "waiting",
  "assignedRoom": "red",
  "photoUrl": "https://storage.../photo.jpg",
  "statusHistory": [
    { "status": "waiting", "changedBy": "uid", "changedAt": "timestamp" }
  ],
  "createdBy": "uid",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### List patients (with filters)
```
GET /api/patients

Query parameters (all optional, can be combined):
  room=red|yellow|green|black|all
  status=waiting|inTreatment|discharged|deceased
  triageColor=red|yellow|green|black
  wristband=00           ← prefix search, e.g. finds "001", "003", "009"
  today=true             ← only patients admitted today
  fromTime=2026-06-01T08:00:00Z
  toTime=2026-06-01T17:00:00Z

Response:
{
  "patients": [ ...Patient objects ],
  "total": 10
}
```

### Get single patient
```
GET /api/patients/:id
```

### Change patient status (doctor only)
```
PATCH /api/patients/:id/status

Body:
{ "status": "inTreatment" }

Valid status flow: waiting → inTreatment → discharged | deceased
```

### Admin: Get patient counts summary
```
GET /api/patients/stats

Response:
{
  "total": 10,
  "byColor":  { "red": 5, "yellow": 3, "green": 2, "black": 0 },
  "byRoom":   { "red": 5, "yellow": 3, "green": 2, "black": 0 },
  "byStatus": { "waiting": 4, "inTreatment": 3, "discharged": 2, "deceased": 1 }
}
```

---

## Vital Signs (F5, F7)

### Add vitals
```
POST /api/patients/:id/vitals

Body:
{
  "bloodPressure": "120/80",
  "heartRate": 75,
  "temperature": 37.0,
  "oxygenSaturation": 98,
  "respiratoryRate": 16
}

Response includes an "alerts" field:
{
  "id": "vitalId",
  "heartRate": 30,
  ...
  "alerts": {
    "heartRate": "HR critical: 30 bpm"
  }
}
```

> If `alerts` is not empty `{}`, highlight those fields in **red** in the UI.  
> A FCM push notification is also automatically sent to the doctor in the same room.

### Critical thresholds (auto-checked on save)

| Vital | Critical Range |
|---|---|
| Blood Pressure | systolic < 90 or > 180 / diastolic < 60 or > 120 |
| Heart Rate | < 40 or > 150 bpm |
| Temperature | < 35 or > 39.5 °C |
| SpO2 | < 90% |
| Respiratory Rate | < 8 or > 30 /min |

### List vitals
```
GET /api/patients/:id/vitals
```

### Update vitals (partial update — only send fields you want to change)
```
PATCH /api/patients/:id/vitals/:vitalId

Body (all fields optional):
{
  "heartRate": 85,
  "temperature": 37.5
}
```

### Delete vitals
```
DELETE /api/patients/:id/vitals/:vitalId
```

---

## Treatments (F5)

### Add treatment (doctor only)
```
POST /api/patients/:id/treatments

Body:
{
  "diagnosis": "Suspected sepsis",
  "treatment": "Fluid resuscitation",
  "notes": "Monitor BP every 15 min",
  "medications": [
    { "medicationId": "<id from medication list>", "dosage": "500ml IV bolus" }
  ]
}
```

> `medications` is optional. When provided, stock is automatically decremented.  
> If a medication is `outOfStock`, the request will be rejected with a 400 error.

### List treatments
```
GET /api/patients/:id/treatments

Response: array of Treatment objects
{
  "id": "...",
  "diagnosis": "...",
  "treatment": "...",
  "notes": "...",
  "medications": [
    { "medicationId": "...", "name": "Normal Saline", "dosage": "500ml IV bolus" }
  ],
  "recordedBy": "uid",
  "recordedAt": "timestamp"
}
```

### Update treatment
```
PATCH /api/patients/:id/treatments/:treatmentId

Body (all optional):
{ "diagnosis": "Updated diagnosis", "notes": "New note" }
```

### Delete treatment
```
DELETE /api/patients/:id/treatments/:treatmentId
```

---

## Push Notifications (F4)

Backend sends FCM automatically. Flutter must:

1. Request notification permission from user
2. Get FCM token: `FirebaseMessaging.instance.getToken()`
3. Send token to backend: `PATCH /api/users/fcm-token`
4. Refresh token when it rotates: `FirebaseMessaging.instance.onTokenRefresh`

### Notification types and payload

| `type` in data | Trigger | Navigate to |
|---|---|---|
| `new_patient` | New patient admitted in doctor's room | Patient detail screen (use `patientId`) |
| `vital_alert` | Critical vital sign recorded | Patient vitals screen (use `patientId`) |
| `low_stock` | Medication stock ≤ threshold | Medication inventory screen (use `medicationId`) |
| `out_of_stock` | Medication quantity = 0 | Medication inventory screen (use `medicationId`) |

---

## Medication Inventory (F8)

### List medications (all roles)
```
GET /api/medications
GET /api/medications?search=saline    ← search by name

Response: array of:
{
  "id": "...",
  "name": "Normal Saline",
  "dosage": "500ml IV bolus",
  "quantity": 45,
  "lowStockThreshold": 10,
  "status": "inStock",    ← inStock | lowStock | outOfStock
  "createdAt": "...",
  "updatedAt": "..."
}
```

### Get single medication
```
GET /api/medications/:id
```

### Admin: Create medication
```
POST /api/medications

Body:
{
  "name": "Normal Saline",
  "dosage": "500ml IV bolus",
  "quantity": 100,
  "lowStockThreshold": 10
}
```

> `lowStockThreshold` is optional, defaults to 10.

### Admin: Update medication details
```
PATCH /api/medications/:id

Body (all optional):
{
  "name": "Updated Name",
  "dosage": "250ml IV",
  "lowStockThreshold": 15
}
```

### Admin: Update stock count
```
PATCH /api/medications/:id/stock

Body:
{ "delta": 50 }    ← positive = add stock, negative = remove stock

Response: updated Medication object
```

### Admin: Delete medication
```
DELETE /api/medications/:id
```

---

## Room Capacity (F9)

### Get all rooms capacity
```
GET /api/rooms/capacity

Response: array of:
{
  "room": "red",
  "current": 8,
  "maxCapacity": 10,
  "percentage": 80,
  "warning": "nearFull"   ← normal | nearFull | full
}
```

| Warning | Condition | Display |
|---|---|---|
| `normal` | < 80% | No indicator |
| `nearFull` | ≥ 80% | Yellow warning |
| `full` | ≥ 95% | Red warning |

### Get single room
```
GET /api/rooms/capacity/:room
```

### Admin: Set room capacity
```
PUT /api/rooms/capacity/:room

Body:
{ "maxCapacity": 15 }
```

---

## Statistics Charts (F11)

```
GET /api/stats/charts              ← default: last 7 days
GET /api/stats/charts?days=30
GET /api/stats/charts?fromDate=2026-06-01&toDate=2026-06-07

Response:
{
  "patientsPerDay": [
    { "date": "2026-05-26", "count": 3 },
    { "date": "2026-05-27", "count": 5 },
    ...
  ],
  "byColor": {
    "red": 9, "yellow": 3, "green": 5, "black": 1
  },
  "mortalityRate": [
    { "date": "2026-05-26", "deceased": 1, "total": 3, "rate": 0.333 }
  ],
  "avgResponseTimeMinutes": 54.5
}
```

> All dates are in **UTC**. Convert to local time before displaying.

---

## Frontend Integration Checklist

Complete these in order before testing any feature:

- [ ] Add `google-services.json` (Android) / `GoogleService-Info.plist` (iOS) to Flutter project
- [ ] Implement login screen → call Firebase Auth → store `idToken`
- [ ] On every app launch: `GET /api/users/profile`
  - If `isProfileComplete: false` → show profile setup screen
  - If complete → route by role (`nurse`, `doctor`, `admin`)
- [ ] After profile check: get FCM token → `PATCH /api/users/fcm-token`
- [ ] Set up FCM `onMessage` and `onMessageOpenedApp` handlers (see Notification Types above)
- [ ] Before showing treatment form: fetch `GET /api/medications` for the medication picker
- [ ] When displaying vitals: check `alerts` field → show critical fields in red
- [ ] When displaying room status: map `warning` field to UI color (`normal`=green, `nearFull`=yellow, `full`=red)
- [ ] Admin stats screen: call `GET /api/stats/charts?days=7` and map to chart widgets
