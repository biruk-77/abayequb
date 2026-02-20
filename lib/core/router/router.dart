import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:feature_discovery/feature_discovery.dart';
import '../utils/route_observer.dart';
import '../../presentation/screens/main_screen.dart';
import '../../presentation/screens/package_selection_screen.dart';
import '../../presentation/screens/contribution_level_screen.dart';
import '../../presentation/screens/payment_screen.dart';
import '../../presentation/screens/about_equb_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/edit_profile_screen.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/enrollment_screen.dart';
import '../../data/models/equb_group_model.dart';
import '../../data/models/equb_package_model.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

class AppRouter {
  static GoRouter router(AuthProvider authProvider) => GoRouter(
    navigatorKey: _rootNavigatorKey,
    observers: [routeObserver],
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isAuthPath =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/splash';
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (isSplash) return null;

      // If user hasn't seen onboarding, redirect there (unless already there)
      if (!authProvider.hasSeenOnboarding) {
        return isOnboarding ? null : '/onboarding';
      }

      // If we are happily past onboarding, prevent going back to it easily
      // (though arguably user might want to see it again, but usually not via back)
      if (isOnboarding && authProvider.hasSeenOnboarding) {
        return '/login';
      }

      if (!authProvider.isAuthenticated) {
        return isAuthPath ? null : '/login';
      }

      if (isAuthPath) {
        return '/';
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return FeatureDiscovery(
            recordStepsInSharedPreferences: false,
            child: const MainScreen(),
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'about', // Route path: /about
            builder: (BuildContext context, GoRouterState state) {
              return const AboutEqubScreen();
            },
          ),
          GoRoute(
            path: 'profile', // Route path: /profile
            builder: (BuildContext context, GoRouterState state) {
              return const ProfileScreen();
            },
            routes: [
              GoRoute(
                path: 'edit', // Route path: /profile/edit
                builder: (context, state) => const EditProfileScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'payment',
            builder: (BuildContext context, GoRouterState state) {
              final extra =
                  state.extra as Map<String, dynamic>? ??
                  {}; // Handle null extra
              return PaymentScreen(
                amount: (extra['amount'] as num?)?.toDouble() ?? 0.0,
                packageName: extra['packageName'] as String? ?? 'Unknown',
                groupId: extra['groupId'] as String?,
              );
            },
          ),
          GoRoute(
            path: 'enrollment',
            builder: (BuildContext context, GoRouterState state) {
              final extra = state.extra as Map<String, dynamic>;
              return EnrollmentScreen(
                group: extra['group'] as EqubGroupModel,
                package: extra['package'] as EqubPackageModel,
              );
            },
          ),
          GoRoute(
            path: 'packages',
            routes: [
              GoRoute(
                path: 'contribution/:id',
                builder: (BuildContext context, GoRouterState state) {
                  if (state.extra is EqubPackageModel) {
                    final package = state.extra as EqubPackageModel;
                    return ContributionLevelScreen(package: package);
                  } else {
                    final extra = state.extra as Map<String, dynamic>;
                    return ContributionLevelScreen(
                      package: extra['package'] as EqubPackageModel,
                      initialGroupId: extra['groupId'] as String?,
                    );
                  }
                },
              ),
            ],
            builder: (BuildContext context, GoRouterState state) {
              return const PackageSelectionScreen();
            },
          ),
        ],
      ),
    ],
  );
}
