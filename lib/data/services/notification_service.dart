import 'package:firebase_messaging/firebase_messaging.dart';
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
  NotificationProvider? _notificationProvider;
  AuthService? _authService;

  void setProvider(NotificationProvider provider) {
    _notificationProvider = provider;
  }

  void setAuthService(AuthService authService) {
    _authService = authService;
  }

  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.info('User granted FCM permission');
    } else {
      AppLogger.warning('User declined or has not accepted FCM permission');
    }

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info('Got a message whilst in the foreground!');
      AppLogger.info('Message data: ${message.data}');

      if (message.notification != null) {
        AppLogger.info(
          'Message also contained a notification: ${message.notification?.title}',
        );

        final notification = NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: message.notification?.title ?? 'Notification',
          message: message.notification?.body ?? '',
          createdAt: DateTime.now(),
          type: message.data['type'] ?? 'system',
        );

        _notificationProvider?.addNotification(notification);
      }
    });

    // Handle notification click when app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info('Notification clicked!');
    });

    // Register device if token exists
    await registerDevice();
  }

  Future<void> registerDevice() async {
    try {
      String? token = await _fcm.getToken();
      AppLogger.info('Registering FCM Token: $token');

      if (token != null && _authService != null) {
        await _authService!.updateFcmToken(token);
        AppLogger.info('FCM Token successfully registered on backend');
      }
    } catch (e) {
      AppLogger.error('Failed to register FCM Token on backend', e);
    }
  }
}

// Global background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed (though onBackgroundMessage usually handles this if called correctly)
  // await Firebase.initializeApp();
  AppLogger.info("Handling a background message: ${message.messageId}");
}
