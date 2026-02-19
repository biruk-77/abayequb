import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/equb_provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/fluid_bottom_nav.dart';
import 'dashboard_screen.dart';
import 'package_selection_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import '../../core/utils/route_observer.dart';
import '../../core/utils/logger.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // This is called when the top route has been popped off, and the current route (MainScreen) shows up.
    AppLogger.info('Returned to MainScreen, refreshing data silently...');
    _refreshDashboardData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Refresh data corresponding to the selected tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (index == 0) {
        _refreshDashboardData();
      } else if (index == 2) {
        context.read<WalletProvider>().fetchTransactions();
      } else if (index == 3) {
        context.read<AuthProvider>().refreshUser();
      }
    });
  }

  Future<void> _refreshDashboardData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final equbProvider = Provider.of<EqubProvider>(context, listen: false);

    try {
      await Future.wait([
        authProvider.refreshUser(),
        walletProvider.fetchWallet(),
        equbProvider.fetchPackages(forceRefresh: true),
        equbProvider.fetchUserEqubData(),
      ]);
    } catch (e) {
      // Error logging usually handled in providers
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AbayLocalizations.of(context);
    if (l10n == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> widgetOptions = <Widget>[
      DashboardScreen(scaffoldKey: _scaffoldKey),
      const PackageSelectionScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: widgetOptions),
          Positioned(
            left: 2,
            right: 2,
            bottom: 8,
            child: FuturisticNavBar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                // Haptic feedback is already handled inside FluidNavBar,
                // but we can keep the state update here.
                _onItemTapped(index);
              },
              items: [
                NavBarItem(icon: Icons.home_rounded, label: l10n.home),
                NavBarItem(
                  icon: Icons.pie_chart_outline,
                  label: l10n.contribute,
                ),
                NavBarItem(icon: Icons.explore_outlined, label: l10n.history),
                NavBarItem(icon: Icons.person_outline, label: l10n.profile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final l10n = AbayLocalizations.of(context);
    if (l10n == null) return const Drawer();
    final user = context.watch<AuthProvider>().user;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryColor, AppTheme.primaryLight],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.fullName ?? 'Abay eQub',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Flowing Wealth, Shared Future',
                  style: GoogleFonts.outfit(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.profile),
            onTap: () {
              Navigator.pop(context); // Close drawer
              context.push('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.aboutAbay),
            onTap: () {
              Navigator.pop(context); // Close drawer
              context.push('/about');
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.settings),
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                trailing: DropdownButton<Locale>(
                  value:
                      context.watch<LocaleProvider>().locale ??
                      const Locale('en'),
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      context.read<LocaleProvider>().setLocale(newLocale);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: Locale('en'),
                      child: Text('English'),
                    ),
                    DropdownMenuItem(value: Locale('am'), child: Text('አማርኛ')),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  context.watch<ThemeProvider>().themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                title: Text(l10n.theme),
                trailing: Switch(
                  value:
                      context.watch<ThemeProvider>().themeMode ==
                      ThemeMode.dark,
                  onChanged: (bool value) {
                    context.read<ThemeProvider>().setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.accessibility_new),
                title: const Text('Simple Mode'),
                trailing: Switch(
                  value: context.watch<ThemeProvider>().isSimpleMode,
                  onChanged: (bool value) {
                    context.read<ThemeProvider>().toggleSimpleMode(value);
                  },
                ),
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context); // Close drawer
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
