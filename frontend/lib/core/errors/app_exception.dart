import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  factory AppException.fromDioException(DioException e) {
    final code = e.response?.statusCode;
    final body = e.response?.data;
    final msg = (body is Map ? body['message'] : null) ?? e.message ?? 'Unknown error';
    return AppException(msg, statusCode: code);
  }

  @override
  String toString() => 'AppException($statusCode): $message';
}
