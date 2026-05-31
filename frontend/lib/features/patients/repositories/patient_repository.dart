import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/patient.dart';

class PatientRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<Patient> createPatient(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post(ApiConstants.patients, data: data);
      return Patient.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<List<Patient>> getPatients({String? room, String? status}) async {
    try {
      final res = await _dio.get(
        ApiConstants.patients,
        queryParameters: {
          if (room != null) 'room': room,
          if (status != null) 'status': status,
        },
      );
      return (res.data as List).map((e) => Patient.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<Patient> getPatientById(String id) async {
    try {
      final res = await _dio.get(ApiConstants.patientById(id));
      return Patient.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<void> updateStatus(String id, PatientStatus status) async {
    try {
      await _dio.patch(ApiConstants.patientStatus(id), data: {'status': status.name});
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<void> addVitalSigns(String id, Map<String, dynamic> vitals) async {
    try {
      await _dio.post(ApiConstants.patientVitals(id), data: vitals);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<void> addTreatment(String id, Map<String, dynamic> treatment) async {
    try {
      await _dio.post(ApiConstants.patientTreatments(id), data: treatment);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }
}
