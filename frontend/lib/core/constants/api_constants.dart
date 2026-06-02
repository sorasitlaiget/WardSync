class ApiConstants {
  ApiConstants._();

  // เปลี่ยนตาม environment:
  // - Android emulator  → http://10.0.2.2:3000
  // - iOS simulator     → http://localhost:3000
  // - Physical device   → http://<your-local-ip>:3000
  static const String baseUrl = 'http://10.0.2.2:3000';

  // Auth / Users
  static const String userProfile = '/api/users/profile';
  static const String registerFcmToken = '/api/notifications/register-token';

  // Patients
  static const String patients = '/api/patients';
  static String patientById(String id) => '/api/patients/$id';
  static String patientStatus(String id) => '/api/patients/$id/status';
  static String patientVitals(String id) => '/api/patients/$id/vitals';
  static String patientTreatments(String id) => '/api/patients/$id/treatments';

  // Admin
  static const String medications = '/api/medications';
  static String medicationById(String id) => '/api/medications/$id';
  static const String roomCapacity = '/api/rooms/capacity';
}
