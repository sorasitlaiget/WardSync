import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/user_profile.dart';

class AuthRepository {
  final Dio _dio = DioClient.instance.dio;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserProfile> getProfile() async {
    try {
      final res = await _dio.get(ApiConstants.userProfile);
      return UserProfile.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
