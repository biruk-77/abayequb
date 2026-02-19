import 'package:dio/dio.dart';

class NetworkErrorHandler {
  static bool isNetworkError(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
             error.type == DioExceptionType.sendTimeout ||
             error.type == DioExceptionType.receiveTimeout ||
             error.type == DioExceptionType.connectionError ||
             (error.error != null && 
              (error.error.toString().contains('SocketException') ||
               error.error.toString().contains('NetworkException')));
    }
    return false;
  }

  static String getUserFriendlyMessage(dynamic error) {
    if (error is DioException) {
      if (isNetworkError(error)) {
        return 'No internet connection. Please check your network and try again.';
      }

      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      // Extract message from response if available
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }

      // Fallback messages based on status code
      switch (statusCode) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Session expired. Please login again.';
        case 403:
          return 'Access denied. You don\'t have permission.';
        case 404:
          return 'Resource not found.';
        case 429:
          return 'Too many requests. Please try again later.';
        case 500:
        case 502:
        case 503:
          return 'Server error. Please try again later.';
        default:
          if (statusCode != null && statusCode >= 500) {
            return 'Server error. Please try again later.';
          }
      }
    }

    return error.toString();
  }
}
