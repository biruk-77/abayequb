import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/logger.dart';
import '../models/notification_model.dart';
import '../../presentation/providers/notification_provider.dart';
import 'auth_service.dart';

class FirebaseNotificationService {
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationProvider? _notificationProvider;
  AuthService? _authService;
  static const _kNotif = 'notif_enabled';

  void setProvider(NotificationProvider provider) {
    _notificationProvider = provider;
  }

  void setAuthService(AuthService authService) {
    _authService = authService;
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isEnabled = prefs.getBool(_kNotif) ?? true;

    // 1. Initialize Local Notifications for Foreground Visibility
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        AppLogger.info('Local notification clicked: ${details.payload}');
        // You could handle navigation here using GoRouter if needed
      },
    );

    // 2. Request FCM permission
    if (isEnabled) {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLogger.info('User granted FCM permission');
      } else {
        AppLogger.warning('User declined FCM permission');
      }
    }

    // 3. Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final p = await SharedPreferences.getInstance();
      if (!(p.getBool(_kNotif) ?? true)) return;

      AppLogger.info('Got FCM message whilst in the foreground!');

      if (message.notification != null) {
        // Create model and add to provider list
        final notificationModel = NotificationModel(
          id:
              message.messageId ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          title: message.notification?.title ?? 'Notification',
          message: message.notification?.body ?? '',
          createdAt: DateTime.now(),
          type: message.data['type'] ?? 'system',
        );
        _notificationProvider?.addNotification(notificationModel);

        // SHOW LOCAL POPUP (REAL WORK)
        await showLocalNotification(
          message.notification?.title ?? 'Notification',
          message.notification?.body ?? '',
          message.data['type'] ?? 'system',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info('Notification clicked to open app: ${message.data}');
    });

    if (isEnabled) {
      await registerDevice();
    }
  }

  Future<void> showLocalNotification(
    String title,
    String body,
    String type,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'abay_equb_channel',
          'Abay eQub Notifications',
          channelDescription:
              'Main channel for Abay eQub application notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
        );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    );

    await _localNotifications.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: platformDetails,
      payload: type,
    );
  }

  Future<void> registerDevice() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_kNotif) ?? true)) {
      AppLogger.info('FCM registration skipped (disabled in settings)');
      return;
    }

    try {
      String? token = await _fcm.getToken();
      if (token != null && _authService != null) {
        await _authService!.updateFcmToken(token);
        AppLogger.info('FCM Token successfully registered on backend');
      }
    } catch (e) {
      AppLogger.error('Failed to register FCM Token on backend', e);
    }
  }

  Future<void> enableNotifications() async {
    AppLogger.info('Enabling FCM Notifications');
    await registerDevice();
  }

  Future<void> disableNotifications() async {
    AppLogger.info('Disabling FCM Notifications');
    try {
      if (_authService != null) {
        await _authService!.updateFcmToken('');
        AppLogger.info('FCM Token cleared on backend');
      }
      await _fcm.deleteToken();
      AppLogger.info('FCM Token deleted locally');
    } catch (e) {
      AppLogger.error('Failed to disable FCM Notifications', e);
    }
  }
}

// Global background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed (though onBackgroundMessage usually handles this if called correctly)
  // await Firebase.initializeApp();
  AppLogger.info("Handling a background message: ${message.messageId}");
}
