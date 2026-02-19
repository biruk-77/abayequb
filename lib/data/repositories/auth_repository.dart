import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../../core/utils/logger.dart';
import 'dart:convert';

class AuthRepository {
  final AuthService _authService;
  final FlutterSecureStorage _storage;

  AuthRepository(this._authService, this._storage);

  Future<UserModel> signIn(String identifier, String password) async {
    try {
      AppLogger.info('Attempting sign in for: $identifier');
      final data = await _authService.signIn(identifier, password);

      // 1. Save tokens first so they are available for subsequent calls
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];

      if (accessToken != null) {
        await _storage.write(key: 'auth_token', value: accessToken);
      }
      if (refreshToken != null) {
        await _storage.write(key: 'refresh_token', value: refreshToken);
      }

      // 2. Extract user data
      final userMap =
          data['data'] ??
          data['user'] ??
          (data['id'] != null || data['fullName'] != null ? data : null);

      if (userMap != null) {
        final user = UserModel.fromJson(userMap);
        await _storage.write(
          key: 'user_data',
          value: jsonEncode(user.toJson()),
        );
        AppLogger.success('Sign in successful for: ${user.fullName}');
        return user;
      } else {
        // Look for ID in various places including JWT
        final userId =
            data['id']?.toString() ??
            data['userId']?.toString() ??
            _getUserIdFromToken(accessToken);

        if (userId != null) {
          AppLogger.warning(
            'User details missing, auto-fetching profile for user $userId',
          );
          final user = await getUserProfile(userId);
          await _storage.write(
            key: 'user_data',
            value: jsonEncode(user.toJson()),
          );
          return user;
        }

        throw Exception("Login succeeded but could not identify user.");
      }
    } catch (e) {
      AppLogger.error('Sign in failed', e);
      rethrow;
    }
  }

  Future<void> requestRegistrationOtp(String phone) async {
    try {
      AppLogger.info('Requesting registration OTP for: $phone');
      await _authService.requestRegistrationOtp(phone);
      AppLogger.success('Registration OTP sent to $phone');
    } catch (e) {
      AppLogger.error('Registration OTP request failed', e);
      rethrow;
    }
  }

  Future<UserModel> verifyRegistrationOtp({
    required String phone,
    required String otp,
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('Verifying registration OTP for: $phone');
      final data = await _authService.verifyRegistrationOtp(
        phone: phone,
        otp: otp,
        fullName: fullName,
        email: email,
        password: password,
      );

      // 1. Save tokens first
      final accessToken = data['accessToken'] ?? data['token'];
      final refreshToken = data['refreshToken'];

      if (accessToken != null) {
        await _storage.write(key: 'auth_token', value: accessToken);
      }
      if (refreshToken != null) {
        await _storage.write(key: 'refresh_token', value: refreshToken);
      }

      // 2. Extract user
      final userMap =
          data['user'] ??
          data['data'] ??
          (data['id'] != null || data['fullName'] != null ? data : null);

      if (userMap != null) {
        final user = UserModel.fromJson(userMap);
        await _storage.write(
          key: 'user_data',
          value: jsonEncode(user.toJson()),
        );
        AppLogger.success('Registration verified for: ${user.fullName}');
        return user;
      } else {
        // Fallback: Use tokens to fetch profile if we have a way to identify the user
        final userId =
            data['id']?.toString() ??
            data['userId']?.toString() ??
            _getUserIdFromToken(accessToken);
        if (userId != null && accessToken != null) {
          AppLogger.warning(
            'User details missing, auto-fetching profile for user $userId',
          );
          final user = await getUserProfile(userId);
          await _storage.write(
            key: 'user_data',
            value: jsonEncode(user.toJson()),
          );
          return user;
        }

        throw Exception("Registration succeeded but could not identify user.");
      }
    } catch (e) {
      AppLogger.error('Registration OTP verification failed', e);
      rethrow;
    }
  }

  Future<void> requestLoginOtp(String phone) async {
    try {
      AppLogger.info('Requesting login OTP for: $phone');
      await _authService.requestLoginOtp(phone);
      AppLogger.success('Login OTP sent to $phone');
    } catch (e) {
      AppLogger.error('Login OTP request failed', e);
      rethrow;
    }
  }

  Future<UserModel> verifyLoginOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      AppLogger.info('Verifying login OTP for: $phone');
      final data = await _authService.verifyLoginOtp(phone, otp);

      // Save tokens first
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];

      if (accessToken != null) {
        await _storage.write(key: 'auth_token', value: accessToken);
      }
      if (refreshToken != null) {
        await _storage.write(key: 'refresh_token', value: refreshToken);
      }

      // Extract user
      final userMap =
          data['data'] ??
          data['user'] ??
          (data['id'] != null || data['fullName'] != null ? data : null);

      if (userMap != null) {
        final user = UserModel.fromJson(userMap);
        await _storage.write(
          key: 'user_data',
          value: jsonEncode(user.toJson()),
        );
        AppLogger.success('Login OTP verified. User: ${user.fullName}');
        return user;
      } else {
        final userId =
            data['id']?.toString() ??
            data['userId']?.toString() ??
            _getUserIdFromToken(accessToken);
        if (userId != null) {
          AppLogger.warning(
            'User details missing, auto-fetching profile for user $userId',
          );
          final user = await getUserProfile(userId);
          await _storage.write(
            key: 'user_data',
            value: jsonEncode(user.toJson()),
          );
          return user;
        }
        throw Exception("OTP verified but could not identify user.");
      }
    } catch (e) {
      AppLogger.error('Login OTP verification failed', e);
      rethrow;
    }
  }

  Future<void> requestForgotPassword(String phone) async {
    try {
      AppLogger.info('Requesting forgot password OTP for: $phone');
      await _authService.requestForgotPassword(phone);
      AppLogger.success('Forgot password OTP sent to $phone');
    } catch (e) {
      AppLogger.error('Forgot password OTP request failed', e);
      rethrow;
    }
  }

  Future<void> verifyForgotPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    try {
      AppLogger.info('Verifying forgot password OTP for: $phone');
      await _authService.verifyForgotPassword(
        phone: phone,
        otp: otp,
        newPassword: newPassword,
      );
      AppLogger.success('Password reset successfully for $phone');
    } catch (e) {
      AppLogger.error('Password reset failed', e);
      rethrow;
    }
  }

  Future<void> refreshToken() async {
    try {
      AppLogger.info('Refreshing access token...');
      final data = await _authService.refreshToken();
      await _storage.write(key: 'auth_token', value: data['accessToken']);
      AppLogger.success('Access token refreshed');
    } catch (e) {
      AppLogger.error('Token refresh failed', e);
      rethrow;
    }
  }

  Future<UserModel> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      AppLogger.info('Updating profile for user: $userId');
      final response = await _authService.updateProfile(
        userId: userId,
        data: data,
      );

      // Update local storage with new user data
      final updatedUser = UserModel.fromJson(response['data']);
      await _storage.write(
        key: 'user_data',
        value: jsonEncode(updatedUser.toJson()),
      );

      AppLogger.success(
        'Profile updated successfully for: ${updatedUser.fullName}',
      );
      return updatedUser;
    } catch (e) {
      AppLogger.error('Profile update failed', e);
      rethrow;
    }
  }

  Future<UserModel> getUserProfile(String userId) async {
    try {
      AppLogger.info('fetching user profile for: $userId');
      final response = await _authService.getUserProfile(userId);
      final user = UserModel.fromJson(response['data']);
      return user;
    } catch (e) {
      AppLogger.error('failed to get user profile', e);
      rethrow;
    }
  }

  // --- Helper Methods ---

  String? _getUserIdFromToken(String? token) {
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final Map<String, dynamic> data = jsonDecode(payload);
      return data['sub']?.toString() ?? data['id']?.toString();
    } catch (e) {
      AppLogger.debug('Could not decode JWT: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      AppLogger.info('Signing out user...');

      // Attempt to hit the signout endpoint, but don't let it block clean-up
      try {
        await _authService.signOut();
      } catch (e) {
        AppLogger.warning(
          'Remote signout failed, continuing with local cleanup',
        );
      }

      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'refresh_token');
      await _storage.delete(key: 'user_data');
      AppLogger.success('User signed out successfully');
    } catch (e) {
      AppLogger.error('Sign out cleanup failed', e);
      rethrow;
    }
  }

  Future<UserModel?> getSavedUser() async {
    final userData = await _storage.read(key: 'user_data');
    if (userData != null) {
      AppLogger.debug('Loaded saved user data');
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}
