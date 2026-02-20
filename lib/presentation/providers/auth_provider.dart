import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/network_error_handler.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _hasSeenOnboarding = false;
  bool _hasSeenHomeShowcase = false;

  AuthProvider(this._authRepository) {
    _init();
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get hasSeenHomeShowcase => _hasSeenHomeShowcase;

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    try {
      AppLogger.info('Initializing AuthProvider...');

      // key-value storage check
      final prefs = await SharedPreferences.getInstance();
      _hasSeenOnboarding = prefs.getBool('onboarding_completed') ?? false;
      _hasSeenHomeShowcase = prefs.getBool('home_showcase_completed') ?? false;

      _user = await _authRepository.getSavedUser();
      if (_user != null) {
        AppLogger.success('Welcome back, ${_user!.fullName}!');
      }
    } catch (e) {
      AppLogger.warning('Failed to load saved user: $e');
      _error = _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to update state when onboarding finishes
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  Future<void> completeHomeShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('home_showcase_completed', true);
    _hasSeenHomeShowcase = true;
    notifyListeners();
  }

  Future<void> login(String identifier, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AppLogger.info('Provider: Attempting login for $identifier');
      _user = await _authRepository.signIn(identifier, password);
      // Ensure onboarding is marked as seen on login just in case
      completeOnboarding();
      AppLogger.success('Provider: Login successful for ${_user!.fullName}');
    } catch (e) {
      AppLogger.error('Provider: Login failed', e);
      _error = _handleError(e);
      throw _error!;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestOtp(String phone, {bool isRegister = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      AppLogger.info(
        'Provider: Requesting OTP for $phone (Register: $isRegister)',
      );
      if (isRegister) {
        await _authRepository.requestRegistrationOtp(phone);
      } else {
        await _authRepository.requestLoginOtp(phone);
      }
      AppLogger.success('Provider: OTP request successful');
    } catch (e) {
      AppLogger.error('Provider: OTP request failed', e);
      _error = _handleError(e);
      throw _error!;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp({
    required String phone,
    required String otp,
    bool isRegister = false,
    String? fullName,
    String? email,
    String? password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      AppLogger.info(
        'Provider: Verifying OTP for $phone (Register: $isRegister)',
      );
      if (isRegister) {
        // 1. Verify OTP and create user
        final user = await _authRepository.verifyRegistrationOtp(
          phone: phone,
          otp: otp,
          fullName: fullName!,
          email: email!,
          password: password!,
        );

        // 2. Check if we're authenticated (tokens saved?)
        final token = await _authRepository.getToken();

        if (token == null) {
          AppLogger.info(
            'Provider: No token received after register. Auto-logging in...',
          );
          // 3. Fallback: Auto-login with credentials
          await login(email, password);
        } else {
          _user = user; // Set user if token exists
          completeOnboarding();
        }
      } else {
        _user = await _authRepository.verifyLoginOtp(phone: phone, otp: otp);
        completeOnboarding();
      }
      AppLogger.success(
        'Provider: OTP verification successful for ${_user!.fullName}',
      );
    } catch (e) {
      AppLogger.error('Provider: OTP verification failed', e);
      if (e is DioException) {
        AppLogger.debug('🚨 Raw Error Response: ${e.response?.data}');
      }
      _error = _handleError(e);
      throw _error!;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? password,
    String? profileImageUrl,
    bool? otp,
    bool? removeProfile,
  }) async {
    if (_user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AppLogger.info('Provider: Updating profile for ${_user!.id}');

      final Map<String, dynamic> data = {};
      if (fullName != null) data['fullName'] = fullName;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (password != null) data['password'] = password;
      if (profileImageUrl != null) data['profile'] = profileImageUrl;
      if (otp != null) data['otp'] = otp.toString();
      if (removeProfile != null)
        data['removeProfile'] = removeProfile.toString();

      _user = await _authRepository.updateProfile(
        userId: _user!.id,
        data: data,
      );
      AppLogger.success('Provider: Profile updated successfully');
    } catch (e) {
      AppLogger.error('Provider: Profile update failed', e);
      _error = _handleError(e);
      throw _error!;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    if (_user == null) return;
    try {
      AppLogger.info('Provider: Refreshing user data for ${_user!.id}...');
      final updatedUser = await _authRepository.getUserProfile(_user!.id);
      _user = updatedUser;
      notifyListeners();
      AppLogger.success('Provider: User data refreshed');
    } catch (e) {
      AppLogger.error('Provider: User refresh failed', e);
    }
  }

  Future<void> logout() async {
    try {
      AppLogger.info('Provider: Logging out...');
      await _authRepository.signOut();
      _user = null;
      AppLogger.success('Provider: Logged out successfully');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Provider: Logout failed', e);
      _error = _handleError(e);
    }
  }

  Future<void> requestForgotPassword(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      AppLogger.info('Provider: Requesting forgot password OTP for $phone');
      await _authRepository.requestForgotPassword(phone);
      AppLogger.success('Provider: Forgot password OTP sent');
    } catch (e) {
      AppLogger.error('Provider: Forgot password request failed', e);
      _error = _handleError(e);
      throw _error!;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyForgotPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      AppLogger.info('Provider: Verifying forgot password OTP for $phone');
      await _authRepository.verifyForgotPassword(
        phone: phone,
        otp: otp,
        newPassword: newPassword,
      );
      AppLogger.success('Provider: Password reset verification successful');
    } catch (e) {
      AppLogger.error('Provider: Password reset verification failed', e);
      _error = _handleError(e);
      throw _error!;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _handleError(dynamic e) {
    // Check for network errors first
    if (NetworkErrorHandler.isNetworkError(e)) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (e is DioException) {
      AppLogger.debug('Handling DioException: ${e.response?.statusCode}');

      final data = e.response?.data;
      if (data != null) {
        if (data is Map) {
          if (data['message'] != null) return data['message'].toString();
          if (data['error'] != null) return data['error'].toString();
          if (data['errors'] != null && data['errors'] is List) {
            return (data['errors'] as List).join('\n');
          }
        } else if (data is String) {
          return data;
        }
      }

      // Fallback for status codes if no body
      switch (e.response?.statusCode) {
        case 400:
          return 'Invalid Request (400)';
        case 401:
          return 'Unauthorized (401)';
        case 403:
          return 'Forbidden (403)';
        case 404:
          return 'Resource not found (404)';
        case 429:
          return 'Too many requests. Please try again later.';
        case 500:
          return 'Server Error (500)';
      }

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout. Please check your internet.';
        case DioExceptionType.receiveTimeout:
          return 'Server response timeout.';
        default:
          return 'An unexpected network error occurred (${e.response?.statusCode ?? "Unknown"}).';
      }
    }
    return e.toString();
  }
}
