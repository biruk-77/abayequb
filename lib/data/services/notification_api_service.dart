import 'package:dio/dio.dart';
import '../../core/utils/logger.dart';

class NotificationApiService {
  final Dio _dio;

  NotificationApiService(this._dio);

  Future<List<dynamic>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications/user');
      final data = response.data['data'];

      if (data is List) return data;
      if (data is Map && data['notifications'] is List) {
        return data['notifications'];
      }

      return [];
    } catch (e) {
      AppLogger.error('API Error in getNotifications', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> markAsRead(String id) async {
    try {
      final response = await _dio.patch('/notifications/$id/read');
      return response.data['data'] ?? response.data;
    } catch (e) {
      AppLogger.error('API Error in markAsRead', e);
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.patch('/notifications/read-all');
    } catch (e) {
      AppLogger.error('API Error in markAllAsRead', e);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      await _dio.delete('/notifications');
    } catch (e) {
      AppLogger.error('API Error in clearAll', e);
      rethrow;
    }
  }
}
