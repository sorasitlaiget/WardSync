import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';

class NotificationRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<void> registerFcmToken(String token) async {
    try {
      await _dio.post(ApiConstants.registerFcmToken, data: {'token': token});
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }
}
