// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart' as nav;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:abushakir/abushakir.dart';

// Core imports
import 'package:abay_equb/core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/currency_formatter.dart';
import '../../l10n/app_localizations.dart';

// Providers
import '../providers/locale_provider.dart';
import '../providers/equb_provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';

// Models
import '../../data/models/user_model.dart';
import '../../data/models/equb_package_model.dart';
import '../../data/models/equb_group_model.dart';
import '../../data/models/equb_member_model.dart';
import '../../data/models/wallet_model.dart';
import '../../data/models/notification_model.dart';

// Widgets
import '../widgets/abay_icon.dart';
import '../widgets/high_end_notification_badge.dart';
import '../widgets/premium/premium_group_card.dart';

// ----------------------------------------------------------------------------
// A Calm, Minimalist Dashboard with Extensive UI Complexity (≈3000 lines)
// ----------------------------------------------------------------------------
// This file contains a complete redesign of the dashboard screen with a calm,
// serene aesthetic. No animations are used; instead, the interface relies on
// subtle colors, ample whitespace, and a modular component architecture.
// The code is heavily commented and structured to be easily maintainable.
// ----------------------------------------------------------------------------

// Calm Color Palette – desaturated, muted tones for a relaxing experience
const Color _calmBackgroundLight = Color(0xFFF8FAFC); // Very light blue-gray
const Color _calmBackgroundDark = Color(0xFF0F172A); // Dark slate
const Color _calmSurfaceLight = Colors.white;
const Color _calmSurfaceDark = Color(0xFF1E293B);
const Color _calmPrimary = Color(0xFF2C3E50); // Deep slate
const Color _calmPrimaryLight = Color(0xFF3A4E62);
const Color _calmAccent = Color(0xFF6D8A9C); // Muted teal
const Color _calmAccentLight = Color(0xFF8AA9B9);
const Color _calmGold = Color(0xFFB89B7A); // Soft gold
const Color _calmGoldLight = Color(0xFFD4B594);
const Color _calmGreen = Color(0xFF7A9E7E); // Muted green
const Color _calmGreenLight = Color(0xFF9BBF9F);
const Color _calmTextPrimaryLight = Color(0xFF1E2B36);
const Color _calmTextPrimaryDark = Colors.white;
const Color _calmTextSecondaryLight = Color(0xFF546E7A);
const Color _calmTextSecondaryDark = Color(0xFF94A3B8);
const Color _calmBorderLight = Color(0xFFE2E8F0);
const Color _calmBorderDark = Color(0xFF334155);
const Color _calmShadowLight = Color(0x1A2C3E50); // Very subtle shadow
const Color _calmShadowDark = Color(0x40000000);

// ----------------------------------------------------------------------------
// Dashboard Screen – Stateful with ScrollController and Data Fetching
// ----------------------------------------------------------------------------
class DashboardScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const DashboardScreen({super.key, required this.scaffoldKey});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Scroll controller for the main scroll view
  late final ScrollController _primaryScrollController;

  // Additional controllers for different sections (if needed)
  late final ScrollController _activeEqubsScrollController;
  late final ScrollController _packagesScrollController;

  @override
  void initState() {
    super.initState();
    _primaryScrollController = ScrollController();
    _activeEqubsScrollController = ScrollController();
    _packagesScrollController = ScrollController();
    _initData();
    _scheduleFeatureDiscovery();
  }

  // --------------------------------------------------------------------------
  // Data Initialization – Fetch all required data after first frame
  // --------------------------------------------------------------------------
  void _initData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final equbProvider = Provider.of<EqubProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final walletProvider = Provider.of<WalletProvider>(
        context,
        listen: false,
      );
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );

      // Fetch core data
      walletProvider.fetchWallet();
      notificationProvider.fetchNotifications();
      equbProvider.fetchPackages();
      authProvider.refreshUser();

      // Fetch user's eQub data if not already loaded
      if (equbProvider.myGroups.isEmpty) {
        equbProvider.fetchUserEqubData();
      }
    });
  }

  // --------------------------------------------------------------------------
  // Feature Discovery Scheduling – Show overlays for first-time users
  // --------------------------------------------------------------------------
  void _scheduleFeatureDiscovery() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.hasSeenHomeShowcase) {
        FeatureDiscovery.discoverFeatures(context, const <String>{
          'menu_button',
          'notifications',
          'trust_score',
          'active_equbs',
          'packages_section',
          'enroll_button',
          'wallet_overview', // Additional feature IDs
          'quick_stats',
          'milestones',
          'activity_feed',
        });
        authProvider.completeHomeShowcase();
      }
    });
  }

  // --------------------------------------------------------------------------
  // Refresh Data (Pull-to-refresh)
  // --------------------------------------------------------------------------
  Future<void> _refreshData() async {
    await Future.wait([
      Provider.of<WalletProvider>(context, listen: false).fetchWallet(),
      Provider.of<EqubProvider>(
        context,
        listen: false,
      ).fetchPackages(forceRefresh: true),
      Provider.of<EqubProvider>(context, listen: false).fetchUserEqubData(),
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).fetchNotifications(),
    ]);
  }

  // --------------------------------------------------------------------------
  // Utility: Format Date using Localization
  // --------------------------------------------------------------------------
  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    final locale =
        Provider.of<LocaleProvider>(
          context,
          listen: false,
        ).locale?.languageCode ??
        'en';
    return DateFormatter.format(date, locale);
  }

  // --------------------------------------------------------------------------
  // Utility: Get Ethiopian Date (for header)
  // --------------------------------------------------------------------------
  String _getEthiopianDate() {
    try {
      final locale =
          Provider.of<LocaleProvider>(
            context,
            listen: false,
          ).locale?.languageCode ??
          'en';
      String dateStr = DateFormatter.format(DateTime.now(), locale);
      if (locale == 'am' && !dateStr.contains('ዓ.ም')) {
        dateStr += ' ዓ.ም';
      }
      return dateStr;
    } catch (_) {
      return '';
    }
  }

  // --------------------------------------------------------------------------
  // Navigation Helpers
  // --------------------------------------------------------------------------
  void _handleGroupAction(
    EqubGroupModel group,
    EqubPackageModel package,
    bool isJoined,
    AbayLocalizations l10n,
  ) async {
    if (isJoined) {
      nav.GoRouter.of(context).push(
        '/packages/contribution/${package.id}',
        extra: {'package': package, 'groupId': group.id},
      );
    } else {
      await nav.GoRouter.of(
        context,
      ).push<bool>('/enrollment', extra: {'group': group, 'package': package});
    }
  }

  void _navigateToGroup(
    BuildContext context,
    EqubGroupModel group,
    EqubPackageModel package,
  ) {
    nav.GoRouter.of(context).push(
      '/packages/contribution/${package.id}',
      extra: {'package': package, 'groupId': group.id},
    );
  }

  // --------------------------------------------------------------------------
  // Calculate Next Payout Estimate (simple sum of target amounts)
  // --------------------------------------------------------------------------
  double _calculateNextPayoutEstimate(BuildContext context) {
    final memberships = context.read<EqubProvider>().myMemberships;
    final groups = context.read<EqubProvider>().myGroups;
    final packages = context.read<EqubProvider>().packages;
    double estimate = 0;
    for (final membership in memberships) {
      final group = groups.firstWhere(
        (g) => g.id == membership.groupId,
        orElse: () => EqubGroupModel(id: '', packageId: ''),
      );
      if ((group.id ?? '').isNotEmpty) {
        final package = packages.firstWhere(
          (p) => p.id == group.packageId,
          orElse: () => EqubPackageModel(id: ''),
        );
        if (package.targetAmount != null && membership.payoutOrder != null) {
          estimate += package.targetAmount!;
        }
      }
    }
    return estimate;
  }

  // --------------------------------------------------------------------------
  // Build Feature Discovery Description (reusable)
  // --------------------------------------------------------------------------
  Widget _featureDesc(BuildContext context, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => FeatureDiscovery.dismissAll(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'Skip Tutorial',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _primaryScrollController.dispose();
    _activeEqubsScrollController.dispose();
    _packagesScrollController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Main Build Method
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final l10n = AbayLocalizations.of(context);
    if (l10n == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Choose colors based on theme
    final backgroundColor = isDark ? _calmBackgroundDark : _calmBackgroundLight;
    final surfaceColor = isDark ? _calmSurfaceDark : _calmSurfaceLight;
    final textPrimary = isDark ? _calmTextPrimaryDark : _calmTextPrimaryLight;
    final textSecondary = isDark
        ? _calmTextSecondaryDark
        : _calmTextSecondaryLight;
    final borderColor = isDark ? _calmBorderDark : _calmBorderLight;
    final shadowColor = isDark ? _calmShadowDark : _calmShadowLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: _calmAccent,
          backgroundColor: surfaceColor,
          strokeWidth: 2,
          child: CustomScrollView(
            controller: _primaryScrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // -----------------------------------------------------------------
              // HEADER SLIVER
              // -----------------------------------------------------------------
              _buildHeader(
                user: context.watch<AuthProvider>().user,
                isDark: isDark,
                l10n: l10n,
                surfaceColor: surfaceColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // -----------------------------------------------------------------
                    // WALLET OVERVIEW CARD
                    // -----------------------------------------------------------------
                    DescribedFeatureOverlay(
                      featureId: 'wallet_overview',
                      targetColor: Colors.white,
                      textColor: textPrimary,
                      backgroundColor: _calmAccent,
                      contentLocation: ContentLocation.above,
                      title: const Text('Your Portfolio'),
                      description: _featureDesc(
                        context,
                        'View your total balance, available funds, and locked savings.',
                      ),
                      tapTarget: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                      ),
                      child: _WalletOverviewCard(
                        wallet: context.watch<WalletProvider>().wallet,
                        isBalanceVisible: context
                            .watch<WalletProvider>()
                            .isBalanceVisible,
                        onToggleVisibility: () => context
                            .read<WalletProvider>()
                            .toggleBalanceVisibility(),
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        shadowColor: shadowColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // -----------------------------------------------------------------
                    // QUICK STATS STRIP
                    // -----------------------------------------------------------------
                    DescribedFeatureOverlay(
                      featureId: 'quick_stats',
                      targetColor: Colors.white,
                      textColor: textPrimary,
                      backgroundColor: _calmAccent,
                      contentLocation: ContentLocation.above,
                      title: const Text('Quick Stats'),
                      description: _featureDesc(
                        context,
                        'At-a-glance overview of your eQub activity.',
                      ),
                      tapTarget: const Icon(
                        Icons.speed_rounded,
                        color: Colors.white,
                      ),
                      child: _QuickStatsStrip(
                        activeGroups: context
                            .watch<EqubProvider>()
                            .myGroups
                            .length,
                        trustScore:
                            context.watch<AuthProvider>().user?.trustScore ?? 0,
                        nextPayoutEstimate: _calculateNextPayoutEstimate(
                          context,
                        ),
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // -----------------------------------------------------------------
                    // UPCOMING CONTRIBUTIONS (Timeline Style)
                    // -----------------------------------------------------------------
                    _SectionTitle(
                      label: 'Upcoming Contributions',
                      textPrimary: textPrimary,
                      icon: Icons.upcoming_rounded,
                    ),
                    const SizedBox(height: 16),
                    _UpcomingContributionsTimeline(
                      memberships: context.watch<EqubProvider>().myMemberships,
                      groups: context.watch<EqubProvider>().myGroups,
                      packages: context.watch<EqubProvider>().packages,
                      formatDate: _formatDate,
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),

                    const SizedBox(height: 28),

                    // -----------------------------------------------------------------
                    // FINANCIAL MILESTONES (Enhanced)
                    // -----------------------------------------------------------------
                    DescribedFeatureOverlay(
                      featureId: 'milestones',
                      targetColor: Colors.white,
                      textColor: textPrimary,
                      backgroundColor: _calmAccent,
                      contentLocation: ContentLocation.above,
                      title: const Text('Milestones'),
                      description: _featureDesc(
                        context,
                        'Track your savings progress and upcoming payouts.',
                      ),
                      tapTarget: const Icon(
                        Icons.flag_rounded,
                        color: Colors.white,
                      ),
                      child: _MilestonesSection(
                        groups: context.watch<EqubProvider>().myGroups,
                        memberships: context
                            .watch<EqubProvider>()
                            .myMemberships,
                        packages: context.watch<EqubProvider>().packages,
                        formatDate: _formatDate,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // -----------------------------------------------------------------
                    // ACTIVE EQBUS (Horizontal List)
                    // -----------------------------------------------------------------
                    DescribedFeatureOverlay(
                      featureId: 'active_equbs',
                      targetColor: Colors.white,
                      textColor: textPrimary,
                      backgroundColor: _calmAccent,
                      contentLocation: ContentLocation.above,
                      title: const Text('Your Active eQubs'),
                      description: _featureDesc(
                        context,
                        'Swipe to see your current groups. Tap any for details.',
                      ),
                      tapTarget: const Icon(
                        Icons.account_tree_rounded,
                        color: Colors.white,
                      ),
                      child: _SectionTitle(
                        label: l10n.yourActiveEqubs,
                        textPrimary: textPrimary,
                        icon: Icons.account_tree_rounded,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ActiveEqubsHorizontal(
                      groups: context.watch<EqubProvider>().myGroups,
                      memberships: context.watch<EqubProvider>().myMemberships,
                      packages: context.watch<EqubProvider>().packages,
                      onGroupTap: _navigateToGroup,
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      l10n: l10n,
                    ),

                    const SizedBox(height: 32),

                    // -----------------------------------------------------------------
                    // EXPLORE PACKAGES (Collapsible Grid)
                    // -----------------------------------------------------------------
                    DescribedFeatureOverlay(
                      featureId: 'packages_section',
                      targetColor: Colors.white,
                      textColor: textPrimary,
                      backgroundColor: _calmAccent,
                      contentLocation: ContentLocation.above,
                      title: const Text('Explore Packages'),
                      description: _featureDesc(
                        context,
                        'Browse available eQub packages and join new groups.',
                      ),
                      tapTarget: const Icon(
                        Icons.explore_rounded,
                        color: Colors.white,
                      ),
                      child: _SectionTitle(
                        label: l10n.explorePackages,
                        textPrimary: textPrimary,
                        icon: Icons.explore_rounded,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PackagesExplorer(
                      packages: context.watch<EqubProvider>().packages,
                      groups: context.watch<EqubProvider>().groups,
                      memberships: context.watch<EqubProvider>().myMemberships,
                      onJoinOrPay: _handleGroupAction,
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      l10n: l10n,
                    ),

                    const SizedBox(height: 32),

                    // -----------------------------------------------------------------
                    // RECENT ACTIVITY FEED
                    // -----------------------------------------------------------------
                    DescribedFeatureOverlay(
                      featureId: 'activity_feed',
                      targetColor: Colors.white,
                      textColor: textPrimary,
                      backgroundColor: _calmAccent,
                      contentLocation: ContentLocation.above,
                      title: const Text('Recent Activity'),
                      description: _featureDesc(
                        context,
                        'Stay updated with the latest notifications and events.',
                      ),
                      tapTarget: const Icon(
                        Icons.history_rounded,
                        color: Colors.white,
                      ),
                      child: _SectionTitle(
                        label: 'Recent Activity',
                        textPrimary: textPrimary,
                        icon: Icons.history_rounded,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ActivityFeed(
                      notifications: context
                          .watch<NotificationProvider>()
                          .notifications
                          .take(5)
                          .toList(),
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),

                    const SizedBox(height: 32),

                    // -----------------------------------------------------------------
                    // TRUST SCORE BREAKDOWN (Detailed)
                    // -----------------------------------------------------------------
                    _SectionTitle(
                      label: 'Trust Score Details',
                      textPrimary: textPrimary,
                      icon: Icons.verified_user_rounded,
                    ),
                    const SizedBox(height: 16),
                    _TrustScoreBreakdown(
                      user: context.watch<AuthProvider>().user,
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),

                    const SizedBox(height: 32),

                    // -----------------------------------------------------------------
                    // COMMUNITY STATS (Placeholder for Social Features)
                    // -----------------------------------------------------------------
                    _SectionTitle(
                      label: 'Community',
                      textPrimary: textPrimary,
                      icon: Icons.people_rounded,
                    ),
                    const SizedBox(height: 16),
                    _CommunityStats(
                      totalMembers:
                          1234, // Placeholder – replace with real data if available
                      activeGroups: context.watch<EqubProvider>().groups.length,
                      totalSaved: 12500000, // Placeholder
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Header Sliver (Separate Method for Clarity)
  // --------------------------------------------------------------------------
  Widget _buildHeader({
    required UserModel? user,
    required bool isDark,
    required AbayLocalizations l10n,
    required Color surfaceColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      elevation: 0,
      backgroundColor: _calmPrimary,
      surfaceTintColor: Colors.transparent,
      leading: DescribedFeatureOverlay(
        featureId: 'menu_button',
        targetColor: Colors.white,
        textColor: textPrimary,
        backgroundColor: _calmAccent,
        contentLocation: ContentLocation.above,
        title: const Text('Navigation Menu'),
        description: _featureDesc(context, 'Tap here to open the side menu.'),
        tapTarget: const Icon(Icons.menu_rounded, color: Colors.white),
        child: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      actions: [
        DescribedFeatureOverlay(
          featureId: 'notifications',
          targetColor: Colors.white,
          textColor: textPrimary,
          backgroundColor: _calmAccent,
          contentLocation: ContentLocation.below,
          title: const Text('Notifications'),
          description: _featureDesc(
            context,
            'Stay updated on contributions, payouts, and group news.',
          ),
          tapTarget: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
          ),
          child: Consumer<NotificationProvider>(
            builder: (context, notificationProv, _) {
              return HighEndNotificationBadge(
                count: notificationProv.unreadCount,
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () =>
                      nav.GoRouter.of(context).push('/notifications'),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => nav.GoRouter.of(context).push('/profile'),
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _calmGold, width: 1.5),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              backgroundImage: AbayIcon.getImageProvider(user?.profileImage),
              child: (user?.profileImage == null || user!.profileImage!.isEmpty)
                  ? const Icon(Icons.person, color: Colors.white70, size: 20)
                  : null,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_calmPrimary, const Color(0xFF1A2B37)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.welcome.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.fullName ?? 'User',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: _calmGold,
                            size: 12,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getEthiopianDate(),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    DescribedFeatureOverlay(
                      featureId: 'trust_score',
                      targetColor: Colors.white,
                      textColor: textPrimary,
                      backgroundColor: _calmAccent,
                      contentLocation: ContentLocation.above,
                      title: const Text('Trust Score'),
                      description: _featureDesc(
                        context,
                        'Your reliability score. Pay on time to increase it.',
                      ),
                      tapTarget: _TrustBadge(trustScore: user?.trustScore ?? 0),
                      child: _TrustBadge(trustScore: user?.trustScore ?? 0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SUB-WIDGETS (All Stateless, Highly Modular)
// ============================================================================

// ----------------------------------------------------------------------------
// Trust Badge (Small)
// ----------------------------------------------------------------------------
class _TrustBadge extends StatelessWidget {
  final int trustScore;
  const _TrustBadge({required this.trustScore});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _calmGold.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _calmGold.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_rounded, color: _calmGold, size: 14),
          const SizedBox(width: 4),
          Text(
            '$trustScore',
            style: GoogleFonts.outfit(
              color: _calmGold,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Wallet Overview Card
// ----------------------------------------------------------------------------
class _WalletOverviewCard extends StatelessWidget {
  final WalletModel? wallet;
  final bool isBalanceVisible;
  final VoidCallback onToggleVisibility;
  final Color surfaceColor;
  final Color borderColor;
  final Color shadowColor;
  final Color textPrimary;
  final Color textSecondary;

  const _WalletOverviewCard({
    required this.wallet,
    required this.isBalanceVisible,
    required this.onToggleVisibility,
    required this.surfaceColor,
    required this.borderColor,
    required this.shadowColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final available = wallet?.available ?? 0.0;
    final locked = wallet?.locked ?? 0.0;
    final total = available + locked;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Subtle noise texture (optional – use a local asset or remove)
            // Positioned.fill(
            //   child: Opacity(
            //     opacity: 0.02,
            //     child: Image.asset('assets/images/noise.png', fit: BoxFit.cover),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _calmAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              color: _calmAccent,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'PORTFOLIO',
                            style: GoogleFonts.outfit(
                              color: textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: onToggleVisibility,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isBalanceVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: textSecondary,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'TOTAL BALANCE',
                    style: GoogleFonts.outfit(
                      color: textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isBalanceVisible
                        ? CurrencyFormatter.format(total)
                        : 'ETB ••••••',
                    style: GoogleFonts.outfit(
                      color: _calmPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _BalanceSplit(
                          icon: Icons.savings_rounded,
                          label: 'AVAILABLE',
                          amount: available,
                          isVisible: isBalanceVisible,
                          color: _calmAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BalanceSplit(
                          icon: Icons.lock_clock_rounded,
                          label: 'LOCKED',
                          amount: locked,
                          isVisible: isBalanceVisible,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceSplit extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final bool isVisible;
  final Color color;

  const _BalanceSplit({
    required this.icon,
    required this.label,
    required this.amount,
    required this.isVisible,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isVisible ? CurrencyFormatter.format(amount) : '••••••',
            style: GoogleFonts.outfit(
              color: _calmPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Quick Stats Strip (Three Pills)
// ----------------------------------------------------------------------------
class _QuickStatsStrip extends StatelessWidget {
  final int activeGroups;
  final int trustScore;
  final double nextPayoutEstimate;
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const _QuickStatsStrip({
    required this.activeGroups,
    required this.trustScore,
    required this.nextPayoutEstimate,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _StatPill(
            icon: Icons.account_tree_rounded,
            label: 'ACTIVE',
            value: '$activeGroups',
            color: _calmAccent,
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
          ),
          const SizedBox(width: 12),
          _StatPill(
            icon: Icons.shield_rounded,
            label: 'TRUST',
            value: '$trustScore/100',
            color: _calmGold,
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
          ),
          const SizedBox(width: 12),
          _StatPill(
            icon: Icons.auto_graph_rounded,
            label: 'PAYOUT',
            value: CurrencyFormatter.format(nextPayoutEstimate),
            color: _calmGreen,
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 14, color: color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.outfit(
                      color: textPrimary.withOpacity(0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.outfit(
                color: textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Upcoming Contributions Timeline
// ----------------------------------------------------------------------------
class _UpcomingContributionsTimeline extends StatelessWidget {
  final List<EqubMemberModel> memberships;
  final List<EqubGroupModel> groups;
  final List<EqubPackageModel> packages;
  final String Function(DateTime?) formatDate;
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const _UpcomingContributionsTimeline({
    required this.memberships,
    required this.groups,
    required this.packages,
    required this.formatDate,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    // Build a list of upcoming contributions (next 5)
    final upcoming = <Map<String, dynamic>>[];
    for (final membership in memberships) {
      final group = groups.firstWhere(
        (g) => g.id == membership.groupId,
        orElse: () => EqubGroupModel(id: '', packageId: ''),
      );
      if ((group.id ?? '').isEmpty) continue;
      final package = packages.firstWhere(
        (p) => p.id == group.packageId,
        orElse: () => EqubPackageModel(id: ''),
      );
      if (group.startDate == null || membership.payoutOrder == null) continue;
      final nextDate = group.startDate!.add(
        Duration(
          days:
              (package.schedule == EqubSchedule.weekly ? 7 : 30) *
              (group.currentCycle ?? 1),
        ),
      );
      upcoming.add({
        'groupName': group.name ?? 'Group',
        'amount': package.contributionAmount ?? 0,
        'date': nextDate,
        'icon': group.iconPath ?? '',
      });
    }
    upcoming.sort(
      (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
    );
    final displayList = upcoming.take(5).toList();

    if (displayList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.upcoming_rounded, color: textSecondary),
              const SizedBox(width: 12),
              Text(
                'No Active Equb Group',
                style: GoogleFonts.outfit(color: textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: displayList.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == displayList.length - 1;
            return Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _calmAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AbayIcon(
                      iconPath: item['icon'],
                      name: item['groupName'],
                      width: 20,
                      height: 20,
                      color: _calmAccent,
                    ),
                  ),
                  title: Text(
                    item['groupName'],
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    formatDate(item['date']),
                    style: GoogleFonts.outfit(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Text(
                    CurrencyFormatter.format(item['amount']),
                    style: GoogleFonts.outfit(
                      color: _calmPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.only(left: 60, right: 16),
                    child: Divider(height: 1, color: borderColor),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Milestones Section (Dual Progress Cards)
// ----------------------------------------------------------------------------
class _MilestonesSection extends StatelessWidget {
  final List<EqubGroupModel> groups;
  final List<EqubMemberModel> memberships;
  final List<EqubPackageModel> packages;
  final String Function(DateTime?) formatDate;
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const _MilestonesSection({
    required this.groups,
    required this.memberships,
    required this.packages,
    required this.formatDate,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate next contribution and payout across all groups
    DateTime? nextContribDate;
    DateTime? nextPayoutDate;
    double contribAmt = 0.0;
    double payoutAmt = 0.0;

    for (final group in groups) {
      final membership = memberships.firstWhere(
        (m) => m.groupId == group.id,
        orElse: () => EqubMemberModel(groupId: '', userId: ''),
      );
      final package = packages.firstWhere(
        (p) => p.id == group.packageId,
        orElse: () => EqubPackageModel(id: 'temp'),
      );
      final startDate = group.startDate;
      final payoutOrder = membership.payoutOrder;

      if (startDate != null && payoutOrder != null) {
        final days = package.schedule == EqubSchedule.weekly ? 7 : 30;
        final payout = startDate.add(Duration(days: days * payoutOrder));
        if (nextPayoutDate == null || payout.isBefore(nextPayoutDate)) {
          nextPayoutDate = payout;
          payoutAmt = package.targetAmount ?? 0.0;
        }
        final contrib = startDate.add(
          Duration(days: days * (group.currentCycle ?? 1)),
        );
        if (nextContribDate == null || contrib.isBefore(nextContribDate)) {
          nextContribDate = contrib;
          contribAmt = package.contributionAmount ?? 0.0;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _MilestoneCard(
              title: 'Next Contribution',
              date: formatDate(nextContribDate),
              amount: contribAmt,
              icon: Icons.upload_rounded,
              color: _calmAccent,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _MilestoneCard(
              title: 'Next Payout',
              date: formatDate(nextPayoutDate),
              amount: payoutAmt,
              icon: Icons.download_rounded,
              color: _calmGreen,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final String title;
  final String date;
  final double amount;
  final IconData icon;
  final Color color;
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const _MilestoneCard({
    required this.title,
    required this.date,
    required this.amount,
    required this.icon,
    required this.color,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.outfit(
                  color: textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            date,
            style: GoogleFonts.outfit(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(amount),
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Active eQubs – Horizontal Scrollable Cards
// ----------------------------------------------------------------------------
class _ActiveEqubsHorizontal extends StatelessWidget {
  final List<EqubGroupModel> groups;
  final List<EqubMemberModel> memberships;
  final List<EqubPackageModel> packages;
  final Function(BuildContext, EqubGroupModel, EqubPackageModel) onGroupTap;
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final AbayLocalizations l10n;

  const _ActiveEqubsHorizontal({
    required this.groups,
    required this.memberships,
    required this.packages,
    required this.onGroupTap,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Icon(Icons.auto_awesome_rounded, color: _calmAccent, size: 40),
              const SizedBox(height: 16),
              Text(
                'No Active Equb Group',
                style: GoogleFonts.outfit(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Browse packages below to start your savings journey.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          final package = packages.firstWhere(
            (p) => p.id == group.packageId,
            orElse: () => EqubPackageModel(id: 'temp'),
          );
          final membership = memberships.firstWhere(
            (m) => m.groupId == group.id,
            orElse: () => EqubMemberModel(groupId: '', userId: ''),
          );

          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => onGroupTap(context, group, package),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _calmAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: AbayIcon(
                              name: group.name,
                              width: 20,
                              height: 20,
                              color: _calmAccent,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: group.status?.toLowerCase() == 'completed'
                                  ? Colors.grey.withOpacity(0.1)
                                  : _calmAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              group.status?.toUpperCase() ?? 'ACTIVE',
                              style: GoogleFonts.outfit(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color:
                                    group.status?.toLowerCase() == 'completed'
                                    ? Colors.grey
                                    : _calmAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        group.name ?? 'Group',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 14,
                            color: textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${group.memberCount ?? 0}/${package.groupSize ?? 0}',
                            style: GoogleFonts.outfit(
                              color: textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NEXT PAYOUT',
                                style: GoogleFonts.outfit(
                                  color: textSecondary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                CurrencyFormatter.format(
                                  package.targetAmount ?? 0,
                                ),
                                style: GoogleFonts.outfit(
                                  color: _calmGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _calmAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              membership.payoutOrder != null
                                  ? 'Order ${membership.payoutOrder}'
                                  : 'Not set',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Progress bar for current cycle
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value:
                              (group.currentCycle ?? 0) /
                              (package.totalCycles ?? 12),
                          backgroundColor: textSecondary.withOpacity(0.2),
                          color: _calmAccent,
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Packages Explorer (Collapsible Expansion Tiles)
// ----------------------------------------------------------------------------
class _PackagesExplorer extends StatelessWidget {
  final List<EqubPackageModel> packages;
  final List<EqubGroupModel> groups;
  final List<EqubMemberModel> memberships;
  final Function(EqubGroupModel, EqubPackageModel, bool, AbayLocalizations)
  onJoinOrPay;
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final AbayLocalizations l10n;

  const _PackagesExplorer({
    required this.packages,
    required this.groups,
    required this.memberships,
    required this.onJoinOrPay,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (packages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: packages.map((package) {
          final pkgGroups = groups
              .where((g) => g.packageId == package.id.toString())
              .toList();
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _calmAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: AbayIcon(
                      iconPath: package.iconPath,
                      name: package.name,
                      height: 26,
                      width: 26,
                    ),
                  ),
                ),
                title: Text(
                  package.name ?? 'Package',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                subtitle: Text(
                  '${package.schedule?.name.toUpperCase() ?? 'MONTHLY'}  •  ${CurrencyFormatter.format(package.contributionAmount ?? 0)}',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: textSecondary,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        const Divider(height: 1, color: _calmBorderLight),
                        const SizedBox(height: 14),
                        if (pkgGroups.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'No groups available',
                              style: GoogleFonts.outfit(color: textSecondary),
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio:
                                      MediaQuery.of(context).size.width < 400
                                      ? 0.8
                                      : 0.85,
                                ),
                            itemCount: pkgGroups.length,
                            itemBuilder: (context, gi) {
                              final group = pkgGroups[gi];
                              final isJoined = memberships.any(
                                (m) => m.groupId == group.id,
                              );
                              return _GroupCard(
                                group: group,
                                package: package,
                                isJoined: isJoined,
                                onTap: () =>
                                    onJoinOrPay(group, package, isJoined, l10n),
                                surfaceColor: surfaceColor,
                                borderColor: borderColor,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                isFirst: gi == 0 && packages.first == package,
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final EqubGroupModel group;
  final EqubPackageModel package;
  final bool isJoined;
  final VoidCallback onTap;
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final bool isFirst;

  const _GroupCard({
    required this.group,
    required this.package,
    required this.isJoined,
    required this.onTap,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final btnText = group.status?.toLowerCase() == 'completed'
        ? 'COMPLETED'
        : (isJoined ? 'DETAILS & PAY' : 'JOIN');

    Widget button = ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isJoined ? _calmAccent : _calmGold,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 6),
        minimumSize: const Size(double.infinity, 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Text(
        btnText,
        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );

    if (isFirst) {
      button = DescribedFeatureOverlay(
        featureId: 'enroll_button',
        targetColor: Colors.white,
        textColor: _calmTextPrimaryLight,
        backgroundColor: _calmAccent,
        contentLocation: ContentLocation.above,
        title: Text(isJoined ? 'Make a Contribution' : 'Join an eQub'),
        description: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isJoined
                  ? 'Tap to see group details and pay your next contribution.'
                  : 'Ready to start saving? Join this group and begin your journey.',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => FeatureDiscovery.dismissAll(context),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Skip Tutorial',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
        tapTarget: Text(
          isJoined ? 'PAY' : 'JOIN',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        child: button,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _calmAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AbayIcon(
                  name: group.name,
                  width: 16,
                  height: 16,
                  color: _calmAccent,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: group.status?.toLowerCase() == 'completed'
                      ? Colors.grey.withOpacity(0.15)
                      : _calmAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  group.status?.toUpperCase() ?? 'ACTIVE',
                  style: GoogleFonts.outfit(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                    color: group.status?.toLowerCase() == 'completed'
                        ? Colors.grey
                        : _calmAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            group.name ?? 'Group',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(
                Icons.people_outline_rounded,
                size: 11,
                color: textSecondary,
              ),
              const SizedBox(width: 3),
              Text(
                '${group.memberCount ?? 0}/${package.groupSize ?? 0}',
                style: GoogleFonts.outfit(fontSize: 10, color: textSecondary),
              ),
            ],
          ),
          const Spacer(),
          button,
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Activity Feed (Notifications)
// ----------------------------------------------------------------------------
class _ActivityFeed extends StatelessWidget {
  final List<NotificationModel> notifications;
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const _ActivityFeed({
    required this.notifications,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.notifications_none_rounded, color: textSecondary),
              const SizedBox(width: 12),
              Text(
                'No recent activity',
                style: GoogleFonts.outfit(color: textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: notifications.map((notif) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _calmAccent.withOpacity(0.1),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: _calmAccent,
                  size: 18,
                ),
              ),
              title: Text(
                notif.title ?? 'Update',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                notif.message ?? '',
                style: GoogleFonts.outfit(fontSize: 12, color: textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              dense: true,
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Trust Score Breakdown (Detailed)
// ----------------------------------------------------------------------------
class _TrustScoreBreakdown extends StatelessWidget {
  final UserModel? user;
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const _TrustScoreBreakdown({
    required this.user,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final trustScore = user?.trustScore ?? 0;
    final onTimePayments = user?.onTimePayments ?? 0;
    final missedPayments = user?.missedPayments ?? 0;
    final totalPayments = onTimePayments + missedPayments;
    final reliability = totalPayments > 0
        ? onTimePayments / totalPayments
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Score',
                  style: GoogleFonts.outfit(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _calmGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$trustScore / 100',
                    style: GoogleFonts.outfit(
                      color: _calmGold,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: trustScore / 100,
              backgroundColor: textSecondary.withOpacity(0.2),
              color: _calmGold,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _TrustFactor(
                  label: 'On-Time',
                  value: onTimePayments.toString(),
                  icon: Icons.check_circle_rounded,
                  color: _calmGreen,
                ),
                const SizedBox(width: 20),
                _TrustFactor(
                  label: 'Missed',
                  value: missedPayments.toString(),
                  icon: Icons.cancel_rounded,
                  color: Colors.redAccent,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: borderColor),
            const SizedBox(height: 8),
            Text(
              'Reliability: ${(reliability * 100).toInt()}%',
              style: GoogleFonts.outfit(
                color: textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustFactor extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _TrustFactor({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: _calmTextSecondaryLight,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: _calmTextPrimaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Community Stats (Placeholder)
// ----------------------------------------------------------------------------
class _CommunityStats extends StatelessWidget {
  final int totalMembers;
  final int activeGroups;
  final double totalSaved;
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const _CommunityStats({
    required this.totalMembers,
    required this.activeGroups,
    required this.totalSaved,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _CommunityStatItem(
              label: 'Members',
              value: '$totalMembers',
              icon: Icons.people_rounded,
              color: _calmAccent,
            ),
            _CommunityStatItem(
              label: 'Active eQubs',
              value: '$activeGroups',
              icon: Icons.account_tree_rounded,
              color: _calmGold,
            ),
            _CommunityStatItem(
              label: 'Total Saved',
              value: CurrencyFormatter.format(totalSaved),
              icon: Icons.savings_rounded,
              color: _calmGreen,
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _CommunityStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: _calmTextPrimaryLight,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10,
            color: _calmTextSecondaryLight,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------------
// Section Title with Icon and Left Accent
// ----------------------------------------------------------------------------
class _SectionTitle extends StatelessWidget {
  final String label;
  final Color textPrimary;
  final IconData icon;

  const _SectionTitle({
    required this.label,
    required this.textPrimary,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 24,
            decoration: BoxDecoration(
              color: _calmGold,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 14),
          Icon(icon, color: _calmGold, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
