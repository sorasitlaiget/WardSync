# 🚀 Day 1 Setup Guide (ทำตามทีละ step)

## ขั้นที่ 1: เตรียมเครื่อง

ตรวจสอบว่ามี Node.js 18+:
```bash
node --version    # ควรขึ้น v18.x.x หรือสูงกว่า
npm --version     # ควรขึ้น 9.x.x หรือสูงกว่า
```

ถ้ายังไม่มี → ติดตั้งจาก https://nodejs.org/

---

## ขั้นที่ 2: Unzip files

แตก zip ที่ได้รับ → จะได้ folder ชื่อ `wardsync/`

```
wardsync/
├── backend/         ← มีไฟล์ครบ
├── README.md
└── .gitignore
```

---

## ขั้นที่ 3: สร้าง Firebase Project

1. เปิด https://console.firebase.google.com
2. กด **Add project**
3. ชื่อ project: `wardsync` (หรืออะไรก็ได้)
4. ปิด Google Analytics (ไม่ต้องใช้)
5. รอ project พร้อม

---

## ขั้นที่ 4: เปิด Firebase Services

ใน Firebase Console:

### 4.1 Authentication
- Build → Authentication → Get started
- Sign-in method → Email/Password → Enable → Save

### 4.2 Firestore Database
- Build → Firestore Database → Create database
- เลือก **Production mode** (ไม่ใช่ test mode)
- Location: `asia-southeast1` (Singapore)
- Done

### 4.3 Storage
- Build → Storage → Get started
- Production mode → Done

### 4.4 Cloud Messaging
- มีอยู่แล้วโดย default ไม่ต้องทำอะไร

---

## ขั้นที่ 5: Download Service Account Key

⚠️ **สำคัญมาก** — Backend ต้องใช้ไฟล์นี้

1. Firebase Console → กดเฟือง ⚙️ ข้างๆ "Project Overview"
2. **Project settings**
3. Tab **Service accounts**
4. กด **Generate new private key**
5. ยืนยัน → Download ไฟล์ JSON

**เปลี่ยนชื่อไฟล์เป็น:** `firebase-service-account.json`

**ย้ายไปวางที่:** `wardsync/backend/firebase-service-account.json`

---

## ขั้นที่ 6: หา Storage Bucket Name

1. Firebase Console → Storage
2. ดูชื่อ bucket ด้านบน เช่น `gs://wardsync-12345.appspot.com`
3. เอาแค่ `wardsync-12345.appspot.com` (ไม่เอา `gs://`)
4. **จด/copy ไว้** — ใช้ใน step ถัดไป

---

## ขั้นที่ 7: สร้าง .env file

ที่ folder `wardsync/backend/`:

```bash
cd wardsync/backend
cp .env.example .env
```

เปิด `.env` แล้วแก้:

```env
PORT=3000
NODE_ENV=development

FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
FIREBASE_STORAGE_BUCKET=wardsync-12345.appspot.com   # ← ใส่ของจริง!

CORS_ORIGIN=http://localhost:8080
LOG_LEVEL=debug
```

---

## ขั้นที่ 8: Install dependencies

```bash
cd wardsync/backend
npm install
```

รอประมาณ 1-2 นาที จนกว่าจะติดตั้งครบ

---

## ขั้นที่ 9: Run server!

```bash
npm run dev
```

ถ้าทุกอย่างถูกต้อง จะเห็นแบบนี้:

```
[INFO] Firebase Admin SDK initialized successfully
[INFO] 🚀 WardSync Backend running on port 3000
[INFO] 📍 Environment: development
[INFO] 🏥 Health check: http://localhost:3000/health
```

---

## ขั้นที่ 10: ทดสอบ

เปิด browser หรือใช้ curl:

```bash
curl http://localhost:3000/health
```

ควรได้:
```json
{
  "status": "ok",
  "service": "wardsync-backend",
  "timestamp": "2026-05-29T..."
}
```

🎉 **ถ้าได้ตรงนี้ = Day 1 setup สำเร็จ!** พร้อมไป Day 2 ต่อ

---

## ❌ Troubleshooting

### Error: `Missing required environment variable: FIREBASE_STORAGE_BUCKET`
→ ลืมแก้ `.env` ให้ใส่ bucket name

### Error: `Cannot find module 'firebase-service-account.json'`
→ ไม่ได้วาง key file ที่ `backend/firebase-service-account.json`

### Error: `Cannot read property 'project_id' of undefined`
→ Service account JSON เสีย → download ใหม่จาก Firebase Console

### Error: `EADDRINUSE: port 3000 already in use`
→ เปลี่ยนเป็น `PORT=3001` ใน `.env`

### Error: `Module not found` ตอน `npm run dev`
→ ลืม `npm install` หรือ install ไม่สมบูรณ์ ลอง:
```bash
rm -rf node_modules package-lock.json
npm install
```

---

## 📞 ถ้าติดตรงไหน

1. Copy error message
2. Screenshot terminal
3. ถามทีม / กลับมาถามผม

ขั้นต่อไป (Day 2) = สร้าง Firestore schema + Auth module
