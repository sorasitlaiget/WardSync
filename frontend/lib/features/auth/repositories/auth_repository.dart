import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> register(String email, String password, String name, String role) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'name': name,
        'role': role,
        'isProfileComplete': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw AppException(e.message ?? 'Registration failed');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<UserProfile> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return await getProfile();
    } on FirebaseAuthException catch (e) {
      throw AppException(e.message ?? 'Authentication failed');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<UserProfile> updateProfile(Map<String, dynamic> data) async {
    try {
      final res = await _dio.patch(ApiConstants.userProfile, data: data);
      return UserProfile.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
