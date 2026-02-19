import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/constants.dart';
import '../utils/logger.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  final _onTokenExpiredController = StreamController<void>.broadcast();

  // Guards
  bool _isLoggingOut = false;
  Completer<String?>? _refreshTokenCompleter;

  Stream<void> get onTokenExpired => _onTokenExpiredController.stream;

  ApiClient(this._dio, this._storage) {
    _dio.options.baseUrl = AppConstants.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);

    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => AppLogger.info(obj.toString()),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),
        onError: (DioException e, handler) async {
          final errorData = e.response?.data;
          final int? statusCode = e.response?.statusCode;

          AppLogger.error('❌ [NETWORK ERROR] $statusCode - ${e.message}');
          if (errorData != null) {
            AppLogger.info('🚨 Error Body: $errorData');
          }

          final bool isAuthError =
              statusCode == 401 ||
              (statusCode == 500 &&
                  (errorData.toString().contains('Invalid authentication') ||
                      errorData.toString().contains('expired access token') ||
                      errorData.toString().contains('Access token missing')));

          if (isAuthError) {
            // BREAK INFINITE LOOP: If this request was already retried, don't try again
            if (e.requestOptions.extra['refresh_retry'] == true) {
              AppLogger.warning(
                '🚫 Token refresh failed twice for this request. Forcing logout.',
              );
              _triggerLogout();
              return handler.reject(e);
            }

            // Already logging out? Reject immediately
            if (_isLoggingOut) return handler.reject(e);

            // If another request is already refreshing, wait for it
            if (_refreshTokenCompleter != null) {
              AppLogger.info('⏳ Waiting for concurrent token renewal...');
              final newToken = await _refreshTokenCompleter!.future;
              if (newToken != null) {
                e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                e.requestOptions.extra['refresh_retry'] =
                    true; // Mark as retried
                final cloneReq = await _dio.fetch(e.requestOptions);
                return handler.resolve(cloneReq);
              }
              return handler.reject(e);
            }

            // Start new refresh cycle
            _refreshTokenCompleter = Completer<String?>();
            AppLogger.info('🔄 Session expired, attempting silent renewal...');

            try {
              final refreshToken = await _storage.read(key: 'refresh_token');
              if (refreshToken == null) {
                _triggerLogout();
                _refreshTokenCompleter?.complete(null);
                _refreshTokenCompleter = null;
                return handler.reject(e);
              }

              final tokenDio = Dio(
                BaseOptions(
                  baseUrl: AppConstants.apiBaseUrl,
                  headers: {'Authorization': 'Bearer $refreshToken'},
                ),
              );
              final response = await tokenDio.post(
                '/auth/user/refresh',
                data: {'refreshToken': refreshToken},
              );

              if (response.statusCode == 200) {
                final newToken =
                    response.data['accessToken'] ??
                    response.data['data']?['accessToken'];

                if (newToken != null) {
                  await _storage.write(key: 'auth_token', value: newToken);
                  AppLogger.success('✅ Session renewed successfully');

                  _refreshTokenCompleter?.complete(newToken);
                  _refreshTokenCompleter = null;

                  e.requestOptions.headers['Authorization'] =
                      'Bearer $newToken';
                  e.requestOptions.extra['refresh_retry'] =
                      true; // Mark as retried
                  final cloneReq = await _dio.fetch(e.requestOptions);
                  return handler.resolve(cloneReq);
                }
              }

              _triggerLogout();
              _refreshTokenCompleter?.complete(null);
              _refreshTokenCompleter = null;
              return handler.reject(e);
            } catch (err) {
              AppLogger.error('❌ Session renewal failed', err);
              _triggerLogout();
              _refreshTokenCompleter?.complete(null);
              _refreshTokenCompleter = null;
              return handler.reject(e);
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  void _triggerLogout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    AppLogger.warning('🚨 Session dead. Redirecting to login...');

    // Small delay to ensure any pending write completes before delete
    // though storage is usually fairly consistent.
    await Future.delayed(const Duration(milliseconds: 100));

    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_data');

    _onTokenExpiredController.add(null);

    // Reset flag after a while to allow new logins
    Future.delayed(const Duration(seconds: 2), () {
      _isLoggingOut = false;
    });
  }

  Dio get client => _dio;
}
