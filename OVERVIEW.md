# WardSync — What the Backend Can Do

A quick overview for the team. No technical jargon — just what exists and who can use it.

---

## The 3 Roles

**Nurse**
- Registers new patients (fills in wristband number, triage color, photo, sex, age range)
- Records and edits vital signs
- Searches and views patient list
- Views room capacity and medication list

**Doctor**
- Views patients in their assigned room (can request to see all rooms)
- Changes patient status (waiting → in treatment → discharged / deceased)
- Records and edits both vital signs and treatments
- Selects medications from inventory when creating a treatment

**Admin**
- Creates and manages staff accounts (nurse / doctor / admin)
- Manages medication inventory (add, edit, restock, delete)
- Sets maximum bed count for each room
- Views statistics and charts

---

## Features

### 1. Login & Profile Setup
Staff log in with email and password. First-time users must fill in their name, role, and assigned room before they can use the app. Doctors and admins must have an assigned room (Red / Yellow / Green / Black). Nurses do not need one.

---

### 2. Patient Registration
Nurses register patients at the triage point. Each patient gets a wristband number, triage color, sex, age range, and optionally a photo. Once registered, doctors in the same room receive a push notification immediately.

---

### 3. Patient List & Search
Anyone can view the patient list. Filters available:
- By room, status, or triage color
- By wristband number (type part of it)
- Only today's patients
- Custom time range (e.g. patients admitted between 8am–5pm)

All filters can be combined.

---

### 4. Push Notifications
The app sends automatic notifications — no manual trigger needed:

| Situation | Who gets notified |
|---|---|
| New patient registered | Doctors in that room |
| Vital signs reach critical level | Doctors in that room |
| Medication stock falls low | All admins |
| Medication runs out | All admins |

For notifications to work, the Flutter app must save the device's FCM token to the server after login.

---

### 5. Vital Signs
Nurses and doctors can record vital signs for a patient. The system automatically checks if any value is dangerous:

| Measurement | Safe Range |
|---|---|
| Blood Pressure | 90–180 systolic / 60–120 diastolic |
| Heart Rate | 40–150 bpm |
| Temperature | 35–39.5 °C |
| SpO2 | 90% and above |
| Respiratory Rate | 8–30 per minute |

If a value is outside the safe range, the app should highlight it in red, and the doctor receives a push notification.

Vital signs can be added, edited, and deleted individually (not just the whole record).

---

### 6. Treatments
Doctors record diagnosis, treatment plan, and notes. They can also attach medications from the inventory — when they do, stock is automatically reduced by one per medication added.

Treatments can be edited and deleted.

---

### 7. Admin Dashboard
Admins can see a summary of the whole hospital:
- How many patients total, broken down by triage color, room, and status

---

### 8. Medication Inventory
Admins manage the medication list. Each medication has a name, default dosage, current stock, and a low-stock warning level.

- When stock drops to or below the warning level → admins get a push notification
- When stock hits zero → medication is marked Out of Stock and cannot be prescribed
- Admins can restock by adding or removing any amount

Nurses and doctors can browse the medication list (for reference or to select when writing a treatment).

---

### 9. Room Capacity
Each room (Red / Yellow / Green / Black) has a maximum bed count set by the admin. The system shows how full each room currently is, as a number and a percentage.

Color indicators:
- **Normal** — below 80%
- **Yellow warning** — 80% or more
- **Red warning** — 95% or more

Capacity updates automatically as patients are admitted or discharged.

---

### 10. Search & Filter
Already covered in Feature 3 above — all filters work together. Clearing filters just means sending no filter at all.

---

### 11. Statistics Charts (Admin only)
The admin dashboard can show charts for any time period (default: last 7 days):
- **Patients per day** — bar chart
- **Patients by triage color** — pie chart
- **Daily mortality rate** — line graph
- **Average response time** — how long from patient arrival to starting treatment (in minutes)

---

## How It All Connects (for the Flutter team)

1. **Login** → get a token → store it → attach it to every request
2. **On app start** → check if profile is complete → if not, show setup screen
3. **After login** → save FCM token to the server (so notifications work)
4. **Before the treatment form** → load the medication list so the doctor can pick from it
5. **When showing vitals** → check the alerts field → highlight anything critical in red
6. **Room capacity screen** → use the warning field to decide which color to show
7. **Admin charts** → call the stats endpoint and map the data to chart widgets
