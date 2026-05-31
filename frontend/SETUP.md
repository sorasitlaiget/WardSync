# WardSync Frontend — Setup Guide

## Prerequisites
- Flutter SDK 3.22+ ([install](https://docs.flutter.dev/get-started/install))
- Dart 3.3+
- Android Studio / Xcode (สำหรับ emulator/simulator)
- Firebase CLI (`npm install -g firebase-tools`)

---

## Step 1: Generate Platform Files (ทำครั้งเดียว)

```bash
cd frontend
flutter create . --project-name wardsync
```

> ไม่ต้องกลัว — คำสั่งนี้จะไม่ทับไฟล์ที่มีอยู่แล้ว แค่สร้าง android/ ios/ web/ ให้

---

## Step 2: Firebase Setup

1. ไปที่ [Firebase Console](https://console.firebase.google.com) → เลือก project `wardsync`
2. ติดตั้ง FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
3. รันคำสั่งนี้ใน folder `frontend/`:
   ```bash
   flutterfire configure --project=<your-firebase-project-id>
   ```
   คำสั่งนี้จะสร้าง `lib/firebase_options.dart` และ `google-services.json` / `GoogleService-Info.plist` ให้อัตโนมัติ

> ⚠️ **ห้าม commit** `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist` ขึ้น Git

---

## Step 3: Install Dependencies

```bash
flutter pub get
```

---

## Step 4: Set Base URL

แก้ไฟล์ [lib/core/constants/api_constants.dart](lib/core/constants/api_constants.dart):

```dart
// Android emulator
static const String baseUrl = 'http://10.0.2.2:3000';

// iOS simulator
static const String baseUrl = 'http://localhost:3000';

// Physical device (ใส่ IP ของเครื่องที่รัน backend)
static const String baseUrl = 'http://192.168.x.x:3000';
```

---

## Step 5: Run

```bash
flutter run
```

---

## Project Structure

```
lib/
├── main.dart                     ← entry point
├── firebase_options.dart         ← generated (ห้าม commit)
│
├── core/
│   ├── constants/
│   │   └── api_constants.dart   ← base URL + all endpoints
│   ├── network/
│   │   ├── dio_client.dart      ← Dio singleton (ใช้ DioClient.instance.dio)
│   │   └── auth_interceptor.dart← auto-inject Firebase token ทุก request
│   └── errors/
│       └── app_exception.dart   ← custom error class
│
├── shared/
│   ├── models/
│   │   ├── patient.dart         ← Patient, VitalSigns, Treatment models
│   │   └── user_profile.dart    ← UserProfile, UserRole, TriageRoom
│   └── widgets/                 ← shared UI components
│
└── features/
    ├── auth/
    │   ├── repositories/
    │   │   └── auth_repository.dart
    │   └── screens/             ← LoginScreen, ProfileSetupScreen
    ├── nurse/
    │   └── screens/             ← TriageFormScreen, NurseHomeScreen
    ├── doctor/
    │   └── screens/             ← DoctorDashboardScreen, PatientDetailScreen
    └── admin/
        └── screens/             ← AdminDashboardScreen, InventoryScreen
```

---

## How to Call the API (ตัวอย่าง)

```dart
import 'package:wardsync/core/network/dio_client.dart';
import 'package:wardsync/core/constants/api_constants.dart';

final dio = DioClient.instance.dio;

// GET patients in red room
final res = await dio.get(
  ApiConstants.patients,
  queryParameters: {'room': 'red'},
);

// POST new patient
await dio.post(ApiConstants.patients, data: {
  'wristbandNumber': '042',
  'sex': 'male',
  'ageRange': 'adult',
  'triageColor': 'red',
  'photoUrl': 'https://...',
});
```

Firebase Auth token จะถูก inject อัตโนมัติทุก request ผ่าน `AuthInterceptor` — ไม่ต้องทำเอง

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_auth` | Login / token |
| `cloud_firestore` | Real-time patient stream |
| `firebase_messaging` | Push notifications (FCM) |
| `firebase_storage` | Upload patient photos |
| `dio` | HTTP client หา backend API |
| `provider` | State management |
| `go_router` | Navigation |
| `camera` / `image_picker` | ถ่ายรูป patient |
