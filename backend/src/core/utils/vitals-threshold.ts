export interface VitalAlerts {
  bloodPressure?: string;
  heartRate?: string;
  temperature?: string;
  oxygenSaturation?: string;
  respiratoryRate?: string;
}

export function checkVitalThresholds(vitals: {
  bloodPressure?: string;
  heartRate?: number;
  temperature?: number;
  oxygenSaturation?: number;
  respiratoryRate?: number;
}): VitalAlerts {
  const alerts: VitalAlerts = {};

  if (vitals.bloodPressure) {
    const bpParts = vitals.bloodPressure.split('/').map(Number);
    if (bpParts.length === 2) {
      const [systolic, diastolic] = bpParts;
      if (systolic < 90 || systolic > 180 || diastolic < 60 || diastolic > 120) {
        alerts.bloodPressure = `BP critical: ${vitals.bloodPressure}`;
      }
    }
  }

  if (vitals.heartRate !== undefined && (vitals.heartRate < 40 || vitals.heartRate > 150)) {
    alerts.heartRate = `HR critical: ${vitals.heartRate} bpm`;
  }

  if (vitals.temperature !== undefined && (vitals.temperature < 35 || vitals.temperature > 39.5)) {
    alerts.temperature = `Temp critical: ${vitals.temperature}°C`;
  }

  if (vitals.oxygenSaturation !== undefined && vitals.oxygenSaturation < 90) {
    alerts.oxygenSaturation = `SpO2 critical: ${vitals.oxygenSaturation}%`;
  }

  if (vitals.respiratoryRate !== undefined && (vitals.respiratoryRate < 8 || vitals.respiratoryRate > 30)) {
    alerts.respiratoryRate = `RR critical: ${vitals.respiratoryRate}/min`;
  }

  return alerts;
}

export function hasAlerts(alerts: VitalAlerts): boolean {
  return Object.keys(alerts).length > 0;
}
