import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
import 'package:dio/dio.dart';
import 'core/api/api_client.dart';
import 'data/services/auth_service.dart';
import 'data/services/equb_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/equb_repository.dart';
import 'core/router/router.dart';
import 'core/utils/size_config.dart';
import 'core/utils/logger.dart';
import 'presentation/widgets/offline_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Storage
  const storage = FlutterSecureStorage();

  // API Layer
  final dio = Dio();
  final apiClient = ApiClient(dio, storage);
  final client = apiClient.client;

  // Services
  final authService = AuthService(client);
  final equbService = EqubService(client);

  // Repositories
  final authRepository = AuthRepository(authService, storage);
  final equbRepository = EqubRepository(equbService);

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
