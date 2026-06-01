# WardSync Backend API — Integration Guide

Base URL (dev): `http://localhost:3000`  
Auth: Bearer Token (Firebase ID Token) ใส่ใน header ทุก request

```
Authorization: Bearer <idToken>
```

---

## Role Permissions

| Action | nurse | doctor | admin |
|--------|-------|--------|-------|
| สร้าง patient | ✅ | ❌ | ❌ |
| ดู patient list | ✅ | ✅ (เฉพาะห้องตัวเอง) | ✅ |
| ดู patient detail | ✅ | ✅ | ✅ |
| เปลี่ยน patient status | ❌ | ✅ | ❌ |
| บันทึก vital signs | ✅ | ✅ | ❌ |
| บันทึก treatment | ❌ | ✅ | ❌ |
| จัดการ medication inventory | ❌ | ❌ | ✅ |
| ดู medication list | ✅ | ✅ | ✅ |
| ดู room capacity | ✅ | ✅ | ✅ |
| ตั้งค่า room capacity | ❌ | ❌ | ✅ |
| ดู stats/charts | ❌ | ❌ | ✅ |
| จัดการ users | ❌ | ❌ | ✅ |

> **หมายเหตุ**: Doctor เห็น patient เฉพาะห้องที่ assign ไว้ ถ้าอยาก override ส่ง `?room=all`

---

## F1 — Authentication & User Management

### Login
```
POST http://localhost:9099/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-key
Body: { "email": "...", "password": "...", "returnSecureToken": true }
Response: { "idToken": "..." }  ← ใช้ token นี้ใส่ใน Authorization header
```

### Profile
```
GET    /api/users/profile          — ดู profile ตัวเอง
PATCH  /api/users/profile          — กรอก profile ครั้งแรก (completeProfile)
PATCH  /api/users/fcm-token        — อัพเดท FCM token { "fcmToken": "..." }
```

### Admin — จัดการ Users
```
GET    /api/users                  — list users ทั้งหมด
POST   /api/users                  — สร้าง user ใหม่
PATCH  /api/users/:uid/role        — เปลี่ยน role/assignedRoom
```

**CompleteProfile body:**
```json
{ "displayName": "นายแพทย์ สมชาย", "role": "doctor", "assignedRoom": "red" }
```

> nurse ไม่มี assignedRoom — doctor และ admin ต้องมี assignedRoom

---

## F2 & F3 — Patient Registration & List

### สร้าง Patient (nurse only) — multipart/form-data
```
POST /api/patients
Fields: wristbandNumber, triageColor (red|yellow|green|black), sex (male|female),
        ageRange (infant|child|adult|elder)
File:   photo (optional, field name: "photo")
```

### List & Filter Patients
```
GET /api/patients
Query params:
  ?room=red|yellow|green|black|all
  ?status=waiting|inTreatment|discharged|deceased
  ?triageColor=red|yellow|green|black
  ?wristband=003          ← prefix search (F10)
  ?today=true             ← เฉพาะวันนี้ (F10)
  ?fromTime=2026-06-01T08:00:00Z&toTime=2026-06-01T17:00:00Z  ← custom range (F10)
```

### Patient Detail & Status
```
GET   /api/patients/:id
PATCH /api/patients/:id/status     — { "status": "inTreatment" } (doctor only)
```

**Patient Status flow:** `waiting` → `inTreatment` → `discharged` หรือ `deceased`

---

## F4 — Push Notifications (FCM)

Backend ส่ง FCM อัตโนมัติ ไม่ต้องเรียก endpoint:

| Event | ส่งถึงใคร |
|-------|-----------|
| สร้าง patient ใหม่ | Doctor ทุกคนในห้องเดียวกัน |
| vital signs เกิน threshold | Doctor ทุกคนในห้องเดียวกัน |
| stock ต่ำกว่า threshold / หมด | Admin ทุกคน |

**Flutter ต้องทำ:**
1. ขอ FCM permission จาก user
2. Get FCM token แล้ว PATCH `/api/users/fcm-token`
3. Handle incoming notification payload:
   - `type: "new_patient"` → patientId ใน data
   - `type: "vital_alert"` → patientId ใน data
   - `type: "low_stock"` / `"out_of_stock"` → medicationId ใน data

---

## F5 — Patient Detail: Vitals & Treatments

### Vital Signs
```
POST   /api/patients/:id/vitals              — บันทึก vitals ใหม่
GET    /api/patients/:id/vitals              — list vitals ทั้งหมด
PATCH  /api/patients/:id/vitals/:vitalId     — แก้ vitals
DELETE /api/patients/:id/vitals/:vitalId     — ลบ
```

**POST/PATCH body:**
```json
{
  "bloodPressure": "120/80",
  "heartRate": 75,
  "temperature": 37.0,
  "oxygenSaturation": 98,
  "respiratoryRate": 16
}
```

**Response** มี `alerts` field บอก field ไหน critical:
```json
{ "heartRate": 30, ..., "alerts": { "heartRate": "HR critical: 30 bpm" } }
```
> ใช้ `alerts` เพื่อแสดงสีแดงใน UI (T2.3)

### Treatments
```
POST   /api/patients/:id/treatments              — บันทึก treatment (doctor only)
GET    /api/patients/:id/treatments
PATCH  /api/patients/:id/treatments/:treatmentId
DELETE /api/patients/:id/treatments/:treatmentId
```

**POST body:**
```json
{
  "diagnosis": "Suspected sepsis",
  "treatment": "Fluid resuscitation",
  "notes": "Monitor BP every 15 min",
  "medications": [
    { "medicationId": "<id>", "dosage": "500ml IV bolus" }
  ]
}
```

---

## F6 — Admin Dashboard Stats

```
GET /api/patients/stats
Response:
{
  "total": 10,
  "byColor": { "red": 9, "yellow": 0, "green": 0, "black": 1 },
  "byRoom":  { "red": 9, "yellow": 0, "green": 0, "black": 1 },
  "byStatus": { "waiting": 5, "inTreatment": 3, "discharged": 2, "deceased": 0 }
}
```

---

## F7 — Vital Signs Alert

อัตโนมัติเมื่อ POST/PATCH vitals — ค่า threshold:

| Vital | Critical |
|-------|----------|
| Blood Pressure | systolic < 90 หรือ > 180 / diastolic < 60 หรือ > 120 |
| Heart Rate | < 40 หรือ > 150 bpm |
| Temperature | < 35 หรือ > 39.5 °C |
| SpO2 | < 90% |
| Respiratory Rate | < 8 หรือ > 30 /min |

---

## F8 — Medication Inventory

### Admin — จัดการ Inventory
```
POST   /api/medications              — { "name": "Normal Saline", "dosage": "500ml IV bolus", "quantity": 50, "lowStockThreshold": 10 }
GET    /api/medications?search=sal   — list + search by name
GET    /api/medications/:id
PATCH  /api/medications/:id          — แก้ name/dosage/threshold
DELETE /api/medications/:id
PATCH  /api/medications/:id/stock    — { "delta": 10 } หรือ { "delta": -5 }
```

**Medication status:**
- `inStock` — ปกติ
- `lowStock` — ≤ lowStockThreshold (FCM แจ้ง admin)
- `outOfStock` — quantity = 0 (FCM แจ้ง admin + ไม่สามารถสั่งได้)

**Flutter ต้องทำ:** GET `/api/medications` ก่อนแสดง medication picker ใน treatment form

---

## F9 — Room Capacity

```
GET /api/rooms/capacity              — ทุกห้อง
GET /api/rooms/capacity/:room        — ห้องเดียว (red|yellow|green|black)
PUT /api/rooms/capacity/:room        — { "maxCapacity": 10 } (admin only)
```

**Response:**
```json
{ "room": "red", "current": 8, "maxCapacity": 10, "percentage": 80, "warning": "nearFull" }
```

**warning levels:**
- `normal` — < 80%
- `nearFull` — ≥ 80% (แสดงสีเหลือง)
- `full` — ≥ 95% (แสดงสีแดง)

---

## F10 — Search & Filter

ดูส่วน **List & Filter Patients** ด้านบน — รองรับ combine หลาย params พร้อมกัน

---

## F11 — Statistics Charts

```
GET /api/stats/charts?days=7
GET /api/stats/charts?fromDate=2026-06-01&toDate=2026-06-01
```

**Response:**
```json
{
  "patientsPerDay": [{ "date": "2026-06-01", "count": 10 }],
  "byColor": { "red": 9, "yellow": 0, "green": 0, "black": 1 },
  "mortalityRate": [{ "date": "2026-06-01", "deceased": 0, "total": 10, "rate": 0 }],
  "avgResponseTimeMinutes": 54.5
}
```

---

## Error Format

```json
{ "error": "Not Found", "message": "Patient not found", "statusCode": 404 }
```

| Code | ความหมาย |
|------|----------|
| 400 | Bad Request — ข้อมูลไม่ถูกต้อง |
| 401 | Unauthorized — token หมดอายุหรือไม่มี |
| 403 | Forbidden — role ไม่มีสิทธิ์ |
| 404 | Not Found |
| 409 | Conflict — wristband ซ้ำ |

---

## Checklist สำหรับ Integrator

- [ ] ติดตั้ง Firebase (google-services.json / GoogleService-Info.plist)
- [ ] Login → เก็บ idToken → ใส่ใน Authorization header ทุก request
- [ ] ตอน app start → GET `/api/users/profile` เช็คว่า profile complete แล้วหรือยัง
- [ ] ถ้า profile ยังไม่ครบ → route ไป complete profile screen
- [ ] ขอ FCM permission → PATCH `/api/users/fcm-token`
- [ ] Handle FCM notification และ navigate ตาม `type` ใน data payload
- [ ] GET `/api/medications` ก่อนแสดง treatment form
- [ ] ใช้ `alerts` field จาก vitals response แสดงสีแดงใน UI
- [ ] ใช้ `warning` field จาก room capacity แสดง color indicator
