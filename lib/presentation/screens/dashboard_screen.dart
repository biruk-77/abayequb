import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart' as nav;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:animate_do/animate_do.dart';
import 'package:abushakir/abushakir.dart';

// Core imports
import 'package:abay_equb/core/theme/app_theme.dart';
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

// Widgets
import '../widgets/abay_icon.dart';
import '../widgets/high_end_notification_badge.dart';
import '../widgets/home/section_header.dart';
import '../widgets/home/glass_vault_card.dart';
import '../widgets/home/active_group_card.dart';
import '../widgets/home/package_mosaic_card.dart';
import '../widgets/home/home_empty_state.dart';
import '../widgets/home/home_curve_clipper.dart';
import '../widgets/home/next_contribution_card.dart';
import '../widgets/home/quick_actions_row.dart';

class DashboardScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const DashboardScreen({super.key, required this.scaffoldKey});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initData();
    _scheduleFeatureDiscovery();
  }

  void _initData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final equbProvider = Provider.of<EqubProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      Provider.of<WalletProvider>(context, listen: false).fetchWallet();
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).fetchNotifications();

      equbProvider.fetchPackages();
      authProvider.refreshUser();
      equbProvider.fetchUserEqubData();
      equbProvider.fetchNextContribution();
      Provider.of<WalletProvider>(context, listen: false).fetchTransactions();
    });
  }

  void _scheduleFeatureDiscovery() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.hasSeenHomeShowcase) {
        FeatureDiscovery.discoverFeatures(context, const <String>{
          'menu_button',
          'notifications',
          'vault_card',
          'active_carousel',
        });
        authProvider.completeHomeShowcase();
      }
    });
  }

  Future<void> _refreshData() async {
    await Future.wait([
      Provider.of<WalletProvider>(context, listen: false).fetchWallet(),
      Provider.of<EqubProvider>(
        context,
        listen: false,
      ).fetchPackages(forceRefresh: true),
      Provider.of<EqubProvider>(context, listen: false).fetchUserEqubData(),
      Provider.of<EqubProvider>(context, listen: false).fetchNextContribution(),
      Provider.of<WalletProvider>(context, listen: false).fetchTransactions(),
    ]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AbayLocalizations.of(context);
    if (l10n == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = context.watch<AuthProvider>().user;
    final wallet = context.watch<WalletProvider>().wallet;
    final equbProvider = context.watch<EqubProvider>();

    // Data Slices
    final myGroups = equbProvider.myGroups;
    final packages = equbProvider.packages;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppTheme.accentColor,
        backgroundColor: AppTheme.primaryColor,
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. THE IMMERSIVE HEADER (CURVE ONLY), VAULT CARD & QUICK ACTIONS
                SliverToBoxAdapter(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      // The Curved Blue Background (Now without the sticky top bar)
                      _buildHeaderBackground(context, user, l10n),

                      // The robust layout flow wrapper for BOTH foreground elements
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 185,
                          ), // Offset perfectly into the curve
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: FadeInUp(
                              duration: const Duration(milliseconds: 800),
                              child: DescribedFeatureOverlay(
                                featureId: 'vault_card',
                                targetColor: AppTheme.accentColor,
                                textColor: Colors.black,
                                backgroundColor: Colors.white,
                                contentLocation: ContentLocation.below,
                                title: const Text('Abay Vault'),
                                description: const Text(
                                  'Your secure balance and locked assets.',
                                ),
                                tapTarget: const Icon(
                                  Icons.account_balance_wallet,
                                  color: AppTheme.primaryColor,
                                ),
                                child: GlassVaultCard(
                                  available: wallet?.available ?? 0.0,
                                  locked: wallet?.locked ?? 0.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // The Quick Actions Row natively flows underneath without ANY overlap possibility
                          QuickActionsRow(
                            onDeposit: () =>
                                nav.GoRouter.of(context).push('/top-up'),
                            onWithdraw: () => nav.GoRouter.of(
                              context,
                            ).push('/withdraw'), // Fallback optionally
                            onHistory: () =>
                                nav.GoRouter.of(context).push('/history'),
                            onCalendar: () =>
                                nav.GoRouter.of(context).push('/calendar'),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ],
                  ),
                ),

                // STATISTICS / SUMMARY
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // NEXT CONTRIBUTION MINI-DASHBOARD (Only if joined groups exist)
                if (equbProvider.nextContribution != null)
                  SliverToBoxAdapter(
                    child: NextContributionCard(
                      contribution: equbProvider.nextContribution!,
                      onPay: () {
                        final contribution = equbProvider.nextContribution!;
                        // 1. Find the group for this contribution to get its packageId
                        final group = myGroups.firstWhere(
                          (g) =>
                              g.id.toString() ==
                              contribution.groupId.toString(),
                          orElse: () => myGroups.isNotEmpty
                              ? myGroups.first
                              : EqubGroupModel(
                                  id: '0',
                                  name: '',
                                  packageId: '0',
                                ),
                        );

                        // 2. Find the package using the group's packageId
                        final package = packages.firstWhere(
                          (p) => p.id.toString() == group.packageId.toString(),
                          orElse: () => packages.isNotEmpty
                              ? packages.first
                              : EqubPackageModel(id: '0', name: 'Unknown'),
                        );

                        nav.GoRouter.of(context).push(
                          '/packages/contribution/${package.id}',
                          extra: {
                            'package': package,
                            'groupId': contribution.groupId.toString(),
                          },
                        );
                      },
                    ),
                  )
                else if (myGroups.isNotEmpty)
                  SliverToBoxAdapter(
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle_outline_rounded,
                                color: AppTheme.successColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "All Caught Up!",
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "No pending contributions for your ${myGroups.length} active groups.",
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 2. ACTIVE EQUBS CAROUSEL
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SectionHeader(
                          title: l10n.yourActiveEqubs,
                          action: l10n.seeAll,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (myGroups.isEmpty)
                        HomeEmptyStateCard(
                          message: "Start your savings journey today.",
                          buttonText: "Join Now",
                          onTap: () => _scrollToPackages(),
                        )
                      else
                        SizedBox(
                          height: 220,
                          child: PageView.builder(
                            controller: PageController(viewportFraction: 0.85),
                            physics: const BouncingScrollPhysics(),
                            itemCount: myGroups.length,
                            itemBuilder: (context, index) {
                              final group = myGroups[index];
                              // Find matching package for details
                              final package = packages.firstWhere(
                                (p) => p.id == group.packageId,
                                orElse: () =>
                                    EqubPackageModel(id: '0', name: 'Unknown'),
                              );

                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: ActiveGroupCard3D(
                                  group: group,
                                  package: package,
                                  onTap: () => nav.GoRouter.of(context).push(
                                    '/packages/contribution/${package.id}',
                                    extra: {
                                      'package': package,
                                      'groupId': group.id,
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // 3. EXPLORE PACKAGES (Mosaic Grid)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SectionHeader(title: l10n.explorePackages),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final package = packages[index];
                      return FadeInUp(
                        delay: Duration(milliseconds: 200 + (index * 50)),
                        child: PackageMosaicCard(
                          package: package,
                          onTap: () => nav.GoRouter.of(context).push(
                            '/packages/contribution/${package.id}',
                            extra: package,
                          ),
                        ),
                      );
                    }, childCount: packages.length),
                  ),
                ),

                // SPACING FOR BOTTOM NAV
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),

            // ── STICKY TOP BAR ──────────────────────────────────────
            // This stays pinned while the content scrolls underneath
            _buildStickyTopBar(context, user, l10n),
          ],
        ),
      ),
    );
  }

  void _scrollToPackages() {
    _scrollController.animateTo(
      500, // Approximate position
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  // ── STICKY TOP BAR BUILDER (FIXED) ──────────────────────────────────────────
  Widget _buildStickyTopBar(
    BuildContext context,
    UserModel? user,
    AbayLocalizations l10n,
  ) {
    return ListenableBuilder(
      listenable: _scrollController,
      builder: (context, child) {
        // Calculate dynamic background color based on scroll offset
        double offset = 0.0;
        if (_scrollController.hasClients) {
          offset = _scrollController.offset;
        }

        // Fades from transparent to primary as user scrolls
        final double opacity = (offset / 100).clamp(0.0, 1.0);

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: opacity),
            boxShadow: [
              if (opacity > 0.8)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Menu Button
                  DescribedFeatureOverlay(
                    featureId: 'menu_button',
                    targetColor: Colors.white,
                    textColor: Colors.black,
                    backgroundColor: AppTheme.accentColor,
                    contentLocation: ContentLocation.below,
                    title: const Text('Menu'),
                    description: const Text('Access settings and history.'),
                    tapTarget: const Icon(Icons.menu_rounded),
                    child: IconButton(
                      icon: const Icon(
                        Icons.sort_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () =>
                          widget.scaffoldKey.currentState?.openDrawer(),
                    ),
                  ),

                  // Logo Text (Fades out or stays pinned)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "ABAY eQUB",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        _getEthiopianDate(context),
                        style: GoogleFonts.outfit(
                          color: AppTheme.accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Notification & Profile
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Consumer<NotificationProvider>(
                        builder: (context, prov, _) => HighEndNotificationBadge(
                          count: prov.unreadCount,
                          child: IconButton(
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () =>
                                nav.GoRouter.of(context).push('/notifications'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => nav.GoRouter.of(context).push('/profile'),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.accentColor,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white24,
                            backgroundImage: AbayIcon.getImageProvider(
                              user?.profileImage,
                            ),
                            child: (user?.profileImage == null)
                                ? const Icon(
                                    Icons.person,
                                    size: 20,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── HEADER BACKGROUND (THE CURVE) ──────────────────────────────────────────
  Widget _buildHeaderBackground(
    BuildContext context,
    UserModel? user,
    AbayLocalizations l10n,
  ) {
    return ClipPath(
      clipper: AbayCurveClipper(),
      child: Container(
        height: 280,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned(
              top: -50,
              right: -50,
              child: Icon(
                Icons.stars_rounded,
                size: 300,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Invisible spacer for where the sticky bar sits
                    const SizedBox(height: 70),

                    // Welcome Message (STILL SCROLLS)
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.welcome,
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              user?.fullName ?? "Guest",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEthiopianDate(BuildContext context) {
    try {
      final etc = ETC.today();
      final locale =
          Provider.of<LocaleProvider>(context).locale?.languageCode ?? 'en';
      if (locale == 'am') {
        final amharicMonths = [
          'መስከረም',
          'ጥቅምት',
          'ህዳር',
          'ታህሳስ',
          'ጥር',
          'የካቲት',
          'መጋቢት',
          'ሚያዝያ',
          'ግንቦት',
          'ሰኔ',
          'ሐምሌ',
          'ነሐሴ',
          'ጳጉሜ',
        ];
        return '${amharicMonths[etc.month - 1]} ${etc.day}, ${etc.year}';
      } else {
        final englishMonths = [
          "Meskerem",
          "Tikimt",
          "Hidar",
          "Tahsas",
          "Tir",
          "Yekatit",
          "Megabit",
          "Miyaziya",
          "Ginbot",
          "Sene",
          "Hamle",
          "Nehase",
          "Pagume",
        ];
        return '${englishMonths[etc.month - 1]} ${etc.day}, ${etc.year}';
      }
    } catch (_) {
      return '';
    }
  }
}
