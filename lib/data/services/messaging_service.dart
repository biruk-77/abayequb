// lib/data/services/messaging_service.dart
import 'package:dio/dio.dart';
import '../../core/utils/logger.dart';

class MessagingService {
  final Dio _dio;

  MessagingService(this._dio);

  Future<Map<String, dynamic>> sendSms(String phone, String message) async {
    try {
      final response = await _dio.post(
        '/messages/sms',
        data: {
          'phoneNumber': phone,
          'message': message,
        },
      );
      return response.data;
    } catch (e) {
      AppLogger.error('API Error in sendSms', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendBulkSms(List<String> phones, String message) async {
    try {
      final response = await _dio.post(
        '/messages/bulk-sms',
        data: {
          'phoneNumbers': phones,
          'message': message,
        },
      );
      return response.data;
    } catch (e) {
      AppLogger.error('API Error in sendBulkSms', e);
      rethrow;
    }
  }
}
