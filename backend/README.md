# WardSync Backend

Real-time Field Hospital Management System — Backend API

> Tech stack: **Node.js + TypeScript + Express + Firebase Admin SDK**

---

## 📋 Prerequisites

ก่อนเริ่ม install ของพวกนี้ก่อน:

- **Node.js** 18+ ([download](https://nodejs.org/))
- **npm** 9+ (มากับ Node.js)
- **Firebase project** (ฟรี - สร้างที่ [console.firebase.google.com](https://console.firebase.google.com))

---

## 🚀 Setup (ทำครั้งเดียว)

### 1. สร้าง Firebase Project

1. ไปที่ [Firebase Console](https://console.firebase.google.com)
2. กด **Add project** → ตั้งชื่อ `wardsync` (หรือชื่ออื่น)
3. ปิด Google Analytics ก่อนได้ (ไม่จำเป็น)
4. รอ project สร้างเสร็จ

### 2. Enable Services ใน Firebase

ใน Firebase Console เปิด services พวกนี้:

| Service | วิธีเปิด |
|---------|---------|
| **Authentication** | Build > Authentication > Get started > Email/Password (enable) |
| **Firestore** | Build > Firestore Database > Create database > Start in production mode > Choose region (asia-southeast1) |
| **Storage** | Build > Storage > Get started > Start in production mode |
| **Cloud Messaging** | Build > Cloud Messaging (auto-enabled) |

### 3. Download Service Account Key

1. Firebase Console > **Project Settings** (⚙️ icon)
2. Tab **Service Accounts**
3. กด **Generate new private key**
4. ดาวน์โหลดไฟล์ JSON
5. **เปลี่ยนชื่อเป็น `firebase-service-account.json`**
6. **วางไว้ใน `backend/` folder** (root ของ backend)

⚠️ **อย่า commit ไฟล์นี้ขึ้น Git!** (`.gitignore` กันไว้แล้ว)

### 4. Setup Environment Variables

```bash
cd backend
cp .env.example .env
```

แก้ไข `.env`:

```bash
PORT=3000
NODE_ENV=development

FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
FIREBASE_STORAGE_BUCKET=wardsync.appspot.com   # ← เปลี่ยนตาม project id

CORS_ORIGIN=http://localhost:8080
LOG_LEVEL=debug
```

> Bucket name หาได้จาก Firebase Console > Storage (ขึ้นต้นด้วย gs://...)

### 5. Install Dependencies

```bash
cd backend
npm install
```

### 6. Run!

```bash
npm run dev
```

ถ้าทุกอย่างถูกต้อง จะเห็น:

```
[INFO] Firebase Admin SDK initialized successfully
[INFO] 🚀 WardSync Backend running on port 3000
[INFO] 📍 Environment: development
[INFO] 🏥 Health check: http://localhost:3000/health
```

ทดสอบเปิด browser:
- http://localhost:3000 → welcome message
- http://localhost:3000/health → `{"status":"ok",...}`

✅ **ถ้าเห็น JSON ตอบกลับ = setup สำเร็จ!**

---

## 📁 Folder Structure

```
backend/
├── src/
│   ├── config/                # ⚙️ config files
│   │   ├── env.config.ts      # load .env
│   │   └── firebase.config.ts # init Firebase Admin
│   │
│   ├── core/                  # 🔧 utilities ที่ใช้ร่วมกัน
│   │   ├── types/             # TypeScript types
│   │   └── utils/             # logger, error classes
│   │
│   ├── middleware/            # 🛡️ Express middleware
│   │   └── error-handler.middleware.ts
│   │
│   ├── modules/               # 📦 features (Day 2+)
│   │   ├── auth/
│   │   ├── patients/
│   │   ├── vital-signs/
│   │   ├── treatments/
│   │   ├── users/
│   │   └── notifications/
│   │
│   ├── app.ts                 # Express app setup
│   └── server.ts              # entry point (start server)
│
├── firestore/                 # 📋 Firestore docs (Day 2)
│   ├── schema.md
│   ├── rules.txt
│   └── indexes.json
│
├── scripts/                   # 🛠️ utility scripts (เช่น seed data)
├── .env                       # ❌ DO NOT COMMIT
├── .env.example               # ✅ template
├── .gitignore
├── firebase-service-account.json  # ❌ DO NOT COMMIT
├── nodemon.json
├── package.json
├── tsconfig.json
└── README.md
```

---

## 📜 Available Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start dev server with auto-reload |
| `npm run build` | Compile TypeScript to `dist/` |
| `npm start` | Run compiled JS (production) |
| `npm run type-check` | Check TypeScript without compiling |
| `npm run lint` | Lint TypeScript files |

---

## 🌐 API Endpoints (พัฒนาต่อ)

### Day 1 (Setup) ✅
- `GET /` — welcome message
- `GET /health` — health check

### Day 2 (Auth) — coming soon
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/logout`

### Day 3 (Patients) — coming soon
- `POST /api/patients` — Triage nurse adds new patient
- `GET /api/patients` — list patients (with filters)
- `GET /api/patients/:id` — get patient detail
- `PATCH /api/patients/:id/status` — update status

### Day 4-6 — see project plan

---

## 🐛 Troubleshooting

### ❌ `Error: Missing required environment variable`
→ ตรวจสอบว่า `.env` มีครบทุก variable

### ❌ `Cannot find module 'firebase-service-account.json'`
→ Download service account จาก Firebase Console → วางใน `backend/`

### ❌ `Permission denied` ตอน Firebase init
→ Service account key เก่า/ผิด project → download ใหม่

### ❌ Port 3000 ถูกใช้แล้ว
→ เปลี่ยน `PORT=3001` ใน `.env`

---

## 📖 Related Documentation

- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)
- [Express.js](https://expressjs.com/)
- [TypeScript](https://www.typescriptlang.org/)
- WardSync Submission 1 documents (in project root)

---

**Last updated:** Day 1 — Setup complete ✅
