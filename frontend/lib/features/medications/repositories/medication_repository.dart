import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';

class Medication {
  final String id;
  final String name;
  final String unit;
  int quantity;
  final int lowStockThreshold;

  Medication({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.lowStockThreshold,
  });

  bool get isLowStock => quantity <= lowStockThreshold;
  bool get isCritical => quantity == 0;

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        id: json['id'] as String,
        name: json['name'] as String,
        unit: json['unit'] as String? ?? 'unit',
        quantity: (json['quantity'] as num).toInt(),
        lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 10,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'unit': unit,
        'quantity': quantity,
        'lowStockThreshold': lowStockThreshold,
      };
}

class MedicationRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<List<Medication>> getMedications() async {
    try {
      final res = await _dio.get(ApiConstants.medications);
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

  Future<void> updateMedication(String id, Map<String, dynamic> data) async {
    try {
      await _dio.patch(ApiConstants.medicationById(id), data: data);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<void> updateStock(String id, int quantity) async {
    try {
      await _dio.patch('${ApiConstants.medicationById(id)}/stock',
          data: {'quantity': quantity});
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
