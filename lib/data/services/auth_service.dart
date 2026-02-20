import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  // --- OTP Registration ---

  Future<Map<String, dynamic>> requestRegistrationOtp(String phone) async {
    try {
      final response = await _dio.post(
        '/auth/otp/register',
        data: {'phone': phone},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyRegistrationOtp({
    required String phone,
    required String otp,
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/otp/verify',
        data: {
          'phone': phone,
          'otp': otp,
          'fullName': fullName,
          'email': email,
          'password': password,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // --- OTP Login ---

  Future<Map<String, dynamic>> requestLoginOtp(String phone) async {
    try {
      final response = await _dio.post(
        '/auth/otp/login/request',
        data: {'phone': phone},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyLoginOtp(String phone, String otp) async {
    try {
      final response = await _dio.post(
        '/auth/otp/login/verify',
        data: {'phone': phone, 'otp': otp},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // --- Forgot Password ---

  Future<Map<String, dynamic>> requestForgotPassword(String phone) async {
    try {
      final response = await _dio.post(
        '/auth/otp/forgot/password/request',
        data: {'phone': phone},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyForgotPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/otp/forgot/password/verify',
        data: {'phone': phone, 'otp': otp, 'newPassword': newPassword},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // --- Password Sign In ---

  Future<Map<String, dynamic>> signIn(
    String identifier,
    String password,
  ) async {
    try {
      // Identifier can be phone or email based on backend schema
      final data = identifier.contains('@')
          ? {'email': identifier, 'password': password}
          : {'phone': identifier, 'password': password};

      final response = await _dio.post('/auth/user/signin', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final response = await _dio.post('/auth/user/refresh');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final formDataMap = Map<String, dynamic>.from(data);

      // Convert local file path to MultipartFile for Dio FormData
      if (formDataMap['profile'] != null &&
          formDataMap['profile'] is String &&
          !formDataMap['profile'].toString().startsWith('http')) {
        final String path = formDataMap['profile'];
        // Basic check for local path
        if (path.startsWith('/') || path.contains('\\') || path.contains(':')) {
          formDataMap['profile'] = await MultipartFile.fromFile(
            path,
            filename: path.split(RegExp(r'[/\\]')).last,
          );
        }
      }

      final formData = FormData.fromMap(formDataMap);

      // Use /users/me for self-updates to avoid permission issues with ID-based routes
      final response = await _dio.put('/users/me', data: formData);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      // Use /users/me as the primary source as seen in Postman collection
      // this avoids permission issues when fetching self by ID
      final response = await _dio.get('/users/me');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _dio.post('/auth/user/signout');
    } catch (e) {
      // Ignore signout errors for now
    }
  }
}
