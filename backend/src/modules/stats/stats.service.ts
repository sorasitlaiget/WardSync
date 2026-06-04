import { db, Timestamp } from '../../config/firebase.config';
import { Patient, StatusLog } from '../patients/patients.types';

const PATIENTS = 'patients';

function toDateString(ts: FirebaseFirestore.Timestamp): string {
  return ts.toDate().toISOString().split('T')[0];
}

function buildDateRange(days: number): { start: Date; end: Date; labels: string[] } {
  const now = new Date();
  const todayUTC = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
  const startUTC = new Date(todayUTC.getTime() - (days - 1) * 24 * 60 * 60 * 1000);
  const endUTC = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(), 23, 59, 59, 999));

  const labels: string[] = [];
  for (let i = 0; i < days; i++) {
    const d = new Date(startUTC.getTime() + i * 24 * 60 * 60 * 1000);
    labels.push(d.toISOString().split('T')[0]);
  }
  return { start: startUTC, end: endUTC, labels };
}

export async function getChartStats(
  days = 7,
  fromDate?: Date,
  toDate?: Date
): Promise<{
  patientsPerDay: { date: string; count: number }[];
  byColor: Record<string, number>;
  mortalityRate: { date: string; deceased: number; total: number; rate: number }[];
  avgResponseTimeMinutes: number | null;
}> {
  let start: Date;
  let end: Date;
  let labels: string[];

  if (fromDate && toDate) {
    start = fromDate;
    end = toDate;
    labels = [];
    const cur = new Date(start);
    cur.setHours(0, 0, 0, 0);
    while (cur <= end) {
      labels.push(cur.toISOString().split('T')[0]);
      cur.setDate(cur.getDate() + 1);
    }
  } else {
    ({ start, end, labels } = buildDateRange(days));
  }

  const snapshot = await db()
    .collection(PATIENTS)
    .where('createdAt', '>=', Timestamp.fromDate(start))
    .where('createdAt', '<=', Timestamp.fromDate(end))
    .orderBy('createdAt')
    .get();

  const patients = snapshot.docs.map((d) => ({ id: d.id, ...d.data() }) as Patient);

  // T3.1 - patients per day
  const perDayCount: Record<string, number> = {};
  labels.forEach((l) => (perDayCount[l] = 0));

  // T3.2 - by color
  const byColor: Record<string, number> = { red: 0, yellow: 0, green: 0, black: 0 };

  // T3.3 - mortality per day
  const deceasedPerDay: Record<string, number> = {};
  labels.forEach((l) => (deceasedPerDay[l] = 0));

  // T3.4 - response time
  const responseTimes: number[] = [];

  for (const p of patients) {
    const dateStr = toDateString(p.createdAt as FirebaseFirestore.Timestamp);
    if (dateStr in perDayCount) perDayCount[dateStr]++;
    if (p.assignedRoom in byColor) byColor[p.assignedRoom]++;
    if (p.status === 'deceased' && dateStr in deceasedPerDay) deceasedPerDay[dateStr]++;

    const history = (p.statusHistory ?? []) as StatusLog[];
    const inTreatmentEntry = history.find((h) => h.status === 'inTreatment');
    if (inTreatmentEntry) {
      const createdMs = (p.createdAt as FirebaseFirestore.Timestamp).toDate().getTime();
      const treatedMs = (inTreatmentEntry.changedAt as FirebaseFirestore.Timestamp).toDate().getTime();
      const diffMin = (treatedMs - createdMs) / 60000;
      if (diffMin >= 0) responseTimes.push(diffMin);
    }
  }

  const patientsPerDay = labels.map((date) => ({ date, count: perDayCount[date] ?? 0 }));

  const mortalityRate = labels.map((date) => {
    const total = perDayCount[date] ?? 0;
    const deceased = deceasedPerDay[date] ?? 0;
    const rate = total > 0 ? Math.round((deceased / total) * 1000) / 1000 : 0;
    return { date, deceased, total, rate };
  });

  const avgResponseTimeMinutes =
    responseTimes.length > 0
      ? Math.round((responseTimes.reduce((a, b) => a + b, 0) / responseTimes.length) * 10) / 10
      : null;

  return { patientsPerDay, byColor, mortalityRate, avgResponseTimeMinutes };
}
