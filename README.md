# WardSync

ระบบบริหารจัดการโรงพยาบาลสนามแบบ Real-time

> **Tech stack:** Flutter (Frontend) · Node.js + TypeScript + Express (Backend) · Firebase (Auth, Firestore, Storage, Messaging)

---

## ข้อกำหนดเบื้องต้น

ติดตั้งสิ่งเหล่านี้ก่อน:

| เครื่องมือ | Version | ดาวน์โหลด |
|---|---|---|
| Flutter SDK | 3.x+ | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Dart SDK | มากับ Flutter | — |
| Node.js | 18+ | [nodejs.org](https://nodejs.org/) |
| Firebase CLI | latest | `npm install -g firebase-tools` |

---

## ขั้นตอน Setup (ทำครั้งเดียวหลัง clone)

### 1. Clone repository

```bash
git clone https://github.com/sorasitlaiget/WardSync.git
cd WardSync
```

### 2. ขอไฟล์ Firebase จากสมาชิกในทีม

ไฟล์เหล่านี้ **ไม่ได้อยู่ใน repo** เพราะมี API keys — ขอจากเพื่อนในทีมผ่าน Line/Discord แล้ววางตามตำแหน่งนี้:

```
WardSync/
├── firebase.json                              ← วางตรงนี้
└── frontend/
    ├── android/app/google-services.json       ← วางตรงนี้
    └── lib/firebase_options.dart              ← วางตรงนี้
```

> ถ้าไม่มีไฟล์พวกนี้ แอปจะ build ไม่ผ่าน

### 3. Setup Frontend (Flutter)

```bash
cd frontend
flutter pub get
```

ทดสอบว่า Flutter พร้อมใช้งาน:

```bash
flutter doctor
```

### 4. Setup Backend

ดูขั้นตอนละเอียดได้ที่ [backend/README.md](backend/README.md)

สรุปย่อ:

```bash
cd backend
cp .env.example .env
# แก้ไข .env ตามที่ backend/README.md บอก
npm install
```

---

## วิธีรันโปรเจกต์

### รันทุกอย่างพร้อมกัน (แนะนำ)

จาก root folder:

```bash
npm install        # ติดตั้ง concurrently (ครั้งแรกครั้งเดียว)
npm run dev        # รัน Firebase Emulator + Backend พร้อมกัน
```

### รัน Frontend

```bash
cd frontend
flutter run        # เลือก device/emulator ที่ต้องการ
```

### รันแยกส่วน

```bash
# Firebase Emulator
npm run emulator

# Backend เฉพาะ
npm run backend

# Frontend
cd frontend && flutter run
```

---

## โครงสร้างโปรเจกต์

```
WardSync/
├── frontend/                  # Flutter app
│   ├── lib/
│   │   ├── core/              # network, errors, constants
│   │   ├── features/          # auth, patients, notifications, ...
│   │   ├── screens/           # UI screens แยกตาม role
│   │   └── shared/            # models, widgets ที่ใช้ร่วมกัน
│   └── pubspec.yaml
│
├── backend/                   # Node.js + Express API
│   ├── src/
│   └── README.md              # Backend setup guide (ละเอียด)
│
├── package.json               # root scripts (dev, emulator, backend)
└── README.md
```

---

## ไฟล์ที่ต้องขอจากทีม (ไม่อยู่ใน repo)

| ไฟล์ | ใช้สำหรับ |
|---|---|
| `frontend/android/app/google-services.json` | Firebase Android config |
| `frontend/lib/firebase_options.dart` | Firebase Flutter config |
| `firebase.json` | Firebase project config |
| `backend/firebase-service-account.json` | Firebase Admin SDK (backend) |
| `backend/.env` | Environment variables (backend) |

---

## Troubleshooting

**`firebase_options.dart` not found**
→ ขอไฟล์จากทีมแล้ววางใน `frontend/lib/`

**`google-services.json` not found**
→ ขอไฟล์จากทีมแล้ววางใน `frontend/android/app/`

**Flutter pub get ล้มเหลว**
→ รัน `flutter doctor` เพื่อเช็คว่า Flutter SDK ติดตั้งครบ

**Backend ไม่ start**
→ ดู [backend/README.md](backend/README.md) หัวข้อ Troubleshooting
