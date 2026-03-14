// lib/main.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/constants.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/equb_provider.dart';
import 'presentation/providers/wallet_provider.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/connectivity_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'package:dio/dio.dart';
import 'core/api/api_client.dart';
import 'data/services/auth_service.dart';
import 'data/services/equb_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/equb_repository.dart';
import 'core/router/router.dart';
import 'core/utils/size_config.dart';
import 'core/utils/logger.dart';
import 'data/services/notification_service.dart';
import 'data/services/notification_api_service.dart';
import 'data/services/kyc_service.dart';
import 'data/repositories/notification_repository.dart';
import 'data/services/legal_service.dart';
import 'data/services/ideas_service.dart';
import 'data/repositories/legal_repository.dart';
import 'data/repositories/ideas_repository.dart';
import 'presentation/providers/legal_provider.dart';
import 'presentation/providers/ideas_provider.dart';
import 'presentation/widgets/offline_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Storage
  const storage = FlutterSecureStorage();

  // API Layer
  final dio = Dio();
  final apiClient = ApiClient(dio, storage);
  final client = apiClient.client;

  // Services
  final authService = AuthService(client);
  final equbService = EqubService(client);
  final notificationApiService = NotificationApiService(client);
  final kycService = KYCService(client);
  final legalService = LegalService(client);
  final ideasService = IdeasService(client);

  // Repositories
  final authRepository = AuthRepository(authService, kycService, storage);
  final equbRepository = EqubRepository(equbService);
  final notificationRepository = NotificationRepository(notificationApiService);
  final legalRepository = LegalRepository(legalService);
  final ideasRepository = IdeasRepository(ideasService);

  // Providers
  final authProvider = AuthProvider(authRepository);

  // Listen for token expiration events from ApiClient
  apiClient.onTokenExpired.listen((_) {
    AppLogger.info('Received logout signal from ApiClient');
    authProvider.logout();
  });
  final equbProvider = EqubProvider(equbRepository);
  final walletProvider = WalletProvider(equbRepository);
  final localeProvider = LocaleProvider();
  final themeProvider = ThemeProvider();
  final connectivityProvider = ConnectivityProvider();
  final notificationProvider = NotificationProvider(notificationRepository);
  final legalProvider = LegalProvider(legalRepository);
  final ideasProvider = IdeasProvider(ideasRepository);

  // Initialize Notifications
  final notificationService = FirebaseNotificationService();
  notificationService.setProvider(notificationProvider);
  notificationService.setAuthService(authService);
  try {
    await notificationService.initialize();
  } catch (e) {
    AppLogger.error(
      'Notification initialization failed – app will continue',
      e,
    );
  }

  // Router initialized once
  final router = AppRouter.router(authProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: equbProvider),
        ChangeNotifierProvider.value(value: walletProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: connectivityProvider),
        ChangeNotifierProvider.value(value: notificationProvider),
        ChangeNotifierProvider.value(value: legalProvider),
        ChangeNotifierProvider.value(value: ideasProvider),
      ],
      child: AbayEqubApp(router: router),
    ),
  );
}

class AbayEqubApp extends StatelessWidget {
  final GoRouter router;
  const AbayEqubApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale,
      supportedLocales: AbayLocalizations.supportedLocales,
      localizationsDelegates: const [
        AbayLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        final themeProvider = context.watch<ThemeProvider>();
        Widget result = child!;

        if (themeProvider.isSimpleMode) {
          result = MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(1.25)),
            child: result,
          );
        }

        // Add offline indicator on top
        return Column(
          children: [
            const OfflineIndicator(),
            Expanded(child: result),
          ],
        );
      },
    );
  }
}
