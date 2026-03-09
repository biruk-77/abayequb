// lib/data/repositories/notification_repository.dart
import '../services/notification_api_service.dart';
import '../models/notification_model.dart';
import '../../core/utils/logger.dart';

class NotificationRepository {
  final NotificationApiService _apiService;

  NotificationRepository(this._apiService);

  Future<List<NotificationModel>> getNotifications() async {
    try {
      AppLogger.info('fetching latest notifications...');
      final data = await _apiService.getNotifications();
      final notifications = data
          .map((json) => NotificationModel.fromJson(json))
          .toList();
      AppLogger.success(
        'successfully loaded ${notifications.length} notifications',
      );
      return notifications;
    } catch (e) {
      AppLogger.error('failed to get notifications', e);
      rethrow;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      AppLogger.info('marking notification $id as read...');
      await _apiService.markAsRead(id);
      AppLogger.success('notification marked as read');
    } catch (e) {
      AppLogger.error('failed to mark notification as read', e);
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      AppLogger.info('marking all notifications as read...');
      await _apiService.markAllAsRead();
      AppLogger.success('all notifications marked as read');
    } catch (e) {
      AppLogger.error('failed to mark all notifications as read', e);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      AppLogger.info('clearing all notifications...');
      await _apiService.clearAll();
      AppLogger.success('all notifications cleared');
    } catch (e) {
      AppLogger.error('failed to clear notifications', e);
      rethrow;
    }
  }
}
