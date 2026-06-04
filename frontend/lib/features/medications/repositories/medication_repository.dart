import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';

class Medication {
  final String id;
  final String name;
  final String dosage;
  int quantity;
  final int lowStockThreshold;
  final String status;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.quantity,
    required this.lowStockThreshold,
    required this.status,
  });

  bool get isLowStock => status == 'lowStock';
  bool get isCritical => status == 'outOfStock';

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        id: json['id'] as String,
        name: json['name'] as String,
        dosage: (json['dosage'] ?? json['unit'] ?? '') as String,
        quantity: (json['quantity'] as num).toInt(),
        lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 10,
        status: (json['status'] ?? 'inStock') as String,
      );
}

class MedicationRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<List<Medication>> getMedications({String? search}) async {
    try {
      final res = await _dio.get(
        ApiConstants.medications,
        queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
      );
      return (res.data as List)
          .map((e) => Medication.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<Medication> createMedication(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post(ApiConstants.medications, data: data);
      return Medication.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<void> updateMedication(String id, {String? name, String? dosage, int? lowStockThreshold}) async {
    try {
      final data = <String, dynamic>{
        if (name != null) 'name': name,
        if (dosage != null) 'dosage': dosage,
        if (lowStockThreshold != null) 'lowStockThreshold': lowStockThreshold,
      };
      await _dio.patch(ApiConstants.medicationById(id), data: data);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<void> updateStock(String id, int delta) async {
    try {
      await _dio.patch('${ApiConstants.medicationById(id)}/stock', data: {'delta': delta});
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<void> deleteMedication(String id) async {
    try {
      await _dio.delete(ApiConstants.medicationById(id));
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }
}
