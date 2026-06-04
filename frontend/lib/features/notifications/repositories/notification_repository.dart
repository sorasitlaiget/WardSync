import 'package:dio/dio.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';

class NotificationRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<void> registerFcmToken(String token) async {
    try {
      await _dio.patch('/api/users/fcm-token', data: {'fcmToken': token});
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }
}
