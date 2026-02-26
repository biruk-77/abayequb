import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import '../../core/utils/logger.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  NotificationProvider(this._repository);

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  static const String _storageKey = 'cached_notifications';

  Future<void> fetchNotifications() async {
    // Load from cache first for immediate UI update
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getStringList(_storageKey);

    if (cached != null && _notifications.isEmpty) {
      _notifications = cached
          .map((item) => NotificationModel.fromJson(jsonDecode(item)))
          .toList();
      notifyListeners();
    }

    _isLoading = true;
    notifyListeners();

    try {
      final latest = await _repository.getNotifications();
      _notifications = latest;
      _saveToLocal();
    } catch (e) {
      AppLogger.error('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      // Optimistic update
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _saveToLocal();
      notifyListeners();

      try {
        await _repository.markAsRead(id);
      } catch (e) {
        AppLogger.error('Failed to mark notification as read on server: $e');
        // Revert on error if needed, but usually we just log it
      }
    }
  }

  Future<void> markAllAsRead() async {
    if (_notifications.isEmpty) return;

    // Optimistic update
    final previousState = List<NotificationModel>.from(_notifications);
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    _saveToLocal();
    notifyListeners();

    try {
      await _repository.markAllAsRead();
    } catch (e) {
      AppLogger.error('Failed to mark all as read on server: $e');
      _notifications = previousState;
      _saveToLocal();
      notifyListeners();
    }
  }

  Future<void> clearAll() async {
    if (_notifications.isEmpty) return;

    final previousState = List<NotificationModel>.from(_notifications);
    _notifications = [];
    _saveToLocal();
    notifyListeners();

    try {
      await _repository.clearAll();
    } catch (e) {
      AppLogger.error('Failed to clear notifications on server: $e');
      _notifications = previousState;
      _saveToLocal();
      notifyListeners();
    }
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    _saveToLocal();
    notifyListeners();
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _notifications.map((n) => jsonEncode(n.toJson())).toList();
      await prefs.setStringList(_storageKey, data);
    } catch (e) {
      AppLogger.error('Failed to save notifications: $e');
    }
  }
}
