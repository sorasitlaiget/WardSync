# 🏥 WardSync

**Real-time Field Hospital Management System**

> *"Synchronizing care when every second counts"*

A Flutter mobile application for managing field hospital operations in war zones, with real-time multi-user synchronization across nurses, doctors, and administrators.

---

## 📁 Project Structure

```
wardsync/
├── backend/        # Node.js + TypeScript + Express + Firebase Admin SDK
└── frontend/       # Flutter app (Android + iOS)
```

---

## 🚀 Quick Start

### Backend
```bash
cd backend
cp .env.example .env
# Add firebase-service-account.json
npm install
npm run dev
```
👉 See [backend/README.md](./backend/README.md) for full setup guide.

### Frontend (Flutter)
```bash
cd frontend
flutter pub get
flutter run
```

---

## 🎯 Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Node.js, TypeScript, Express |
| Database | Firestore (real-time NoSQL) |
| Auth | Firebase Auth |
| Storage | Firebase Storage (patient photos) |
| Notifications | Firebase Cloud Messaging (FCM) |
| Frontend | Flutter |
| Real-time Sync | Firestore SDK stream (frontend) |

---

## 👥 Team Structure

| Role | Owner |
|------|-------|
| Backend (this folder) | You |
| Frontend Flutter (4 devs) | Team |

---

## 📅 Timeline

| Date | Milestone |
|------|-----------|
| 21 May 2026 | ✅ Submission 1: Requirements Spec |
| 30 May 2026 | Tier 1 (MVP) complete |
| 3 June 2026 | Tier 2 features complete |
| 5 June 2026 | Submission 2: Final delivery + demo |

---

## 🎨 Theme

**Theme 2: Fighting Impact of Wars on the World & Its Inhabitants**

WardSync serves humanitarian medical teams (MSF, ICRC, WHO EMT) treating war casualties.

---

## 📖 Documentation

- [Concept and List of Functions](./docs/WardSync_Concept_and_List_of_Functions.pdf)
- [User Personas](./docs/WardSync_User_Persona.pdf)
- [User Journey Map](./docs/WardSync_User_Journey_Map.pdf)
- [Backend README](./backend/README.md)
