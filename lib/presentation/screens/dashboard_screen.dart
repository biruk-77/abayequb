import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart' as nav;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:animate_do/animate_do.dart';
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

// Models
import '../../data/models/user_model.dart';
import '../../data/models/equb_package_model.dart';
import '../../data/models/equb_group_model.dart';
import '../../data/models/equb_member_model.dart';

// Premium widgets
import '../widgets/abay_icon.dart';
import '../widgets/premium/glass_balance_card.dart';
import '../widgets/premium/premium_group_card.dart';
import '../widgets/premium/mesh_gradient_background.dart';

/// A DashboardScreen that feels like a million bucks – smooth, timeless,
/// yet delightfully futuristic. Optimized for users of all ages.
class DashboardScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const DashboardScreen({super.key, required this.scaffoldKey});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  // Animation controllers for extra polish
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initData();
    _setupAnimations();
    _scheduleFeatureDiscovery();
  }

  void _initData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final equbProvider = Provider.of<EqubProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Refresh data
      Provider.of<WalletProvider>(context, listen: false).fetchWallet();
      equbProvider.fetchPackages();
      authProvider
          .refreshUser(); // Refresh user profile to ensure sync and test 401 fix

      // Only fetch user data if memory is empty
      if (equbProvider.myGroups.isEmpty) {
        equbProvider.fetchUserEqubData();
      }
    });
  }

  /// Subtle pulsing animation for the trust score badge (attracts attention without being jarring)
  void _setupAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  /// Feature discovery – only for first-time users
  void _scheduleFeatureDiscovery() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.hasSeenHomeShowcase) {
        FeatureDiscovery.discoverFeatures(context, const <String>{
          'menu_button',
          'notifications',
          'balance_toggle',
          'trust_score',
          'active_equbs',
          'packages_section',
          'enroll_button',
        });
        authProvider.completeHomeShowcase();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Pull‑to‑refresh: refresh everything
  Future<void> _refreshData() async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final equbProvider = Provider.of<EqubProvider>(context, listen: false);

    // For manual refresh, we force a server hit
    await Future.wait([
      walletProvider.fetchWallet(),
      equbProvider.fetchPackages(forceRefresh: true),
      equbProvider.fetchUserEqubData(),
    ]);
  }

  /// Localized date formatting helper
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

  /// Ethiopian date formatting helper
  String _getEthiopianDate() {
    try {
      final etc = ETC.today();
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
      final locale =
          Provider.of<LocaleProvider>(
            context,
            listen: false,
          ).locale?.languageCode ??
          'en';

      if (locale == 'am') {
        return '${amharicMonths[etc.month - 1]} ${etc.day}, ${etc.year} ዓ.ም';
      }
      return '${etc.monthName} ${etc.day}, ${etc.year}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AbayLocalizations.of(context);
    if (l10n == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Watch providers for reactive updates
    final wallet = context.watch<WalletProvider>().wallet;
    final equbProvider = context.watch<EqubProvider>();
    final packages = equbProvider.packages;
    final groups = equbProvider.groups;
    final myGroups = equbProvider.myGroups;
    final memberships = equbProvider.myMemberships;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      body: MeshGradientBackground(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppTheme.primaryColor,
          backgroundColor: Colors.white.withOpacity(0.9),
          strokeWidth: 2.5,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildPremiumHeader(user, l10n),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // ---- Balance Card (glassmorphic) ----
                      FadeInDown(
                        duration: const Duration(milliseconds: 800),
                        from: 30,
                        child: GlassBalanceCard(
                          available: wallet?.available ?? 0.0,
                          locked: wallet?.locked ?? 0.0,
                          isVisible: context
                              .watch<WalletProvider>()
                              .isBalanceVisible,
                          onToggleVisibility: () {
                            context
                                .read<WalletProvider>()
                                .toggleBalanceVisibility();
                          },
                        ),
                      ),

                      const SizedBox(height: 32),

                      ...[
                        FadeInLeft(
                          duration: const Duration(milliseconds: 600),
                          child: Text(
                            l10n.yourActiveEqubs,
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (myGroups.isEmpty)
                          _buildEmptyActiveEqubsCard(context, l10n)
                        else
                          SizedBox(
                            height: 260,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              clipBehavior: Clip.none,
                              itemCount: myGroups.length,
                              itemBuilder: (context, index) {
                                final group = myGroups[index];
                                final package = packages.firstWhere(
                                  (p) => p.id == group.packageId,
                                  orElse: () => EqubPackageModel(id: 'temp'),
                                );
                                final membership = memberships.firstWhere(
                                  (m) => m.groupId == group.id,
                                  orElse: () =>
                                      EqubMemberModel(groupId: '', userId: ''),
                                );

                                return FadeInRight(
                                  delay: Duration(
                                    milliseconds: index * 100 + 200,
                                  ),
                                  duration: const Duration(milliseconds: 600),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: PremiumGroupCard(
                                      group: group,
                                      contributionAmount:
                                          package.contributionAmount ?? 0,
                                      currentCycle: group.currentCycle ?? 1,
                                      payoutOrder: membership.payoutOrder,
                                      onTap: () => _navigateToGroup(
                                        context,
                                        group,
                                        package,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 24),

                        if (myGroups.isNotEmpty)
                          _buildMilestoneCard(
                            myGroups,
                            memberships,
                            packages,
                            l10n,
                          ),
                        const SizedBox(height: 32),
                      ],

                      // ---- Packages & Groups (exploration section) ----
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        duration: const Duration(milliseconds: 600),
                        child: DescribedFeatureOverlay(
                          featureId: 'packages_section',
                          targetColor: Colors.white,
                          textColor: Colors.black,
                          backgroundColor: AppTheme.accentColor,
                          contentLocation: ContentLocation.below,
                          title: Text(l10n.explorePackages),
                          description: _buildFeatureDescription(
                            context,
                            'Browse eQub packages by category. Tap any package to see available groups and join.',
                          ),
                          tapTarget: const Icon(
                            Icons.explore_rounded,
                            color: Colors.black,
                          ),
                          child: Text(
                            l10n.explorePackages,
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPackagesWithGroups(
                        context,
                        packages,
                        groups,
                        memberships,
                        l10n,
                      ),
                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ========== PREMIUM HEADER (SliverAppBar) ==========
  Widget _buildPremiumHeader(UserModel? user, AbayLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      stretch: true,
      leading: DescribedFeatureOverlay(
        featureId: 'menu_button',
        targetColor: Colors.white,
        textColor: Colors.black,
        backgroundColor: AppTheme.accentColor,
        contentLocation: ContentLocation.above,
        title: const Text('Navigation Menu'),
        description: _buildFeatureDescription(
          context,
          'Tap here to open the side menu and access all parts of the app.',
        ),
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
          textColor: Colors.black,
          backgroundColor: AppTheme.accentColor,
          contentLocation: ContentLocation.below,
          title: const Text('Notifications'),
          description: _buildFeatureDescription(
            context,
            'Stay updated on contributions, payouts, and group news.',
          ),
          tapTarget: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
          ),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  // TODO: navigate to notifications
                },
              ),
              // Small unread indicator (simulated)
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [AppTheme.primaryColor, AppTheme.primaryLight],
              stops: const [0.0, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circle for depth
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInLeft(
                      duration: const Duration(milliseconds: 600),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.welcome,
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                user?.fullName ?? 'User',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getEthiopianDate(),
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Trust score badge with subtle pulse
                          DescribedFeatureOverlay(
                            featureId: 'trust_score',
                            targetColor: Colors.white,
                            textColor: Colors.black,
                            backgroundColor: AppTheme.accentColor,
                            contentLocation: ContentLocation.above,
                            title: const Text('Trust Score'),
                            description: _buildFeatureDescription(
                              context,
                              'Your reliability score. Pay on time to increase it and unlock better eQub opportunities.',
                            ),
                            tapTarget: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.verified_user_rounded,
                                    color: Color(0xFFFCD34D),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${user?.trustScore ?? 0}',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            child: ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.verified_user_rounded,
                                      color: Color(0xFFFCD34D),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${user?.trustScore ?? 0}',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ========== FEATURE DESCRIPTION HELPER ==========
  Widget _buildFeatureDescription(BuildContext context, String text) {
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

  /// ========== MILESTONE CARD (next contribution / payout) ==========
  Widget _buildMilestoneCard(
    List<EqubGroupModel> myGroups,
    List<EqubMemberModel> memberships,
    List<EqubPackageModel> packages,
    AbayLocalizations l10n,
  ) {
    // Calculate upcoming dates (simplified – in production you'd compute from actual payment records)
    DateTime? nextContributionDate;
    DateTime? nextPayoutDate;
    double contributionAmount = 0.0;
    double payoutAmount = 0.0;

    for (var group in myGroups) {
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
        final intervalDays = package.schedule == EqubSchedule.weekly ? 7 : 30;
        // Payout date = startDate + (payoutOrder * interval)
        final payout = startDate.add(
          Duration(days: intervalDays * payoutOrder),
        );
        if (nextPayoutDate == null || payout.isBefore(nextPayoutDate)) {
          nextPayoutDate = payout;
          payoutAmount = package.targetAmount ?? 0.0;
        }

        // Next contribution date = startDate + (currentCycle * interval)
        // (Assuming contribution is due at the beginning of each cycle)
        final contribution = startDate.add(
          Duration(days: intervalDays * (group.currentCycle ?? 1)),
        );
        if (nextContributionDate == null ||
            contribution.isBefore(nextContributionDate)) {
          nextContributionDate = contribution;
          contributionAmount = package.contributionAmount ?? 0.0;
        }
      }
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : const Color(0xFF1E293B).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.event_note_rounded,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'FINANCIAL MILESTONES',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMilestoneItem(
                context,
                label: l10n.nextContribution,
                date: _formatDate(nextContributionDate),
                amount: contributionAmount,
                color: AppTheme.primaryColor,
                icon: Icons.upload_rounded,
              ),
              Container(width: 1, height: 50, color: const Color(0xFFE2E8F0)),
              _buildMilestoneItem(
                context,
                label: l10n.nextPayout,
                date: _formatDate(nextPayoutDate),
                amount: payoutAmount,
                color: const Color(0xFF10B981),
                icon: Icons.download_rounded,
                isPayout: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneItem(
    BuildContext context, {
    required String label,
    required String date,
    required double amount,
    required Color color,
    required IconData icon,
    bool isPayout = false,
  }) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
          left: isPayout ? 20 : 0,
          right: isPayout ? 0 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              date,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
                Text(
                  CurrencyFormatter.format(amount),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ========== PACKAGES WITH EXPANDABLE GROUPS ==========
  Widget _buildPackagesWithGroups(
    BuildContext context,
    List<EqubPackageModel> packages,
    List<EqubGroupModel> groups,
    List<EqubMemberModel> memberships,
    AbayLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (packages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];
        final packageGroups = groups
            .where((g) => g.packageId == package.id.toString())
            .toList();

        return FadeInUp(
          delay: Duration(milliseconds: index * 100 + 400),
          duration: const Duration(milliseconds: 600),
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.2)
                      : const Color(0xFF64748B).withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                onExpansionChanged: (expanded) {
                  if (expanded) {
                    // Scalability: Fetch groups for this package only when expanded
                    context.read<EqubProvider>().fetchGroupsByPackage(
                      package.id.toString(),
                    );
                  }
                },
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : const Color(0xFFF0FDFA), // teal 50
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AbayIcon(
                    iconPath: package.iconPath,
                    height: 28,
                    width: 28,
                  ),
                ),
                title: Text(
                  package.name ?? 'Package',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                subtitle: Text(
                  '${package.schedule?.name.toUpperCase() ?? 'MONTHLY'} • ${CurrencyFormatter.format(package.contributionAmount ?? 0)}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        Divider(
                          height: 1,
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : const Color(0xFFE2E8F0),
                        ),
                        const SizedBox(height: 16),
                        if (packageGroups.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: context.watch<EqubProvider>().isLoading
                                  ? const CircularProgressIndicator()
                                  : Text(
                                      'No groups available',
                                      style: GoogleFonts.outfit(
                                        color: isDark
                                            ? Colors.white54
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
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
                            itemCount: packageGroups.length,
                            itemBuilder: (context, groupIdx) {
                              final group = packageGroups[groupIdx];
                              final isJoined = memberships.any(
                                (m) => m.groupId == group.id,
                              );
                              return _buildGroupGridItem(
                                context,
                                group,
                                package,
                                isJoined,
                                l10n,
                                isFirst: index == 0 && groupIdx == 0,
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ========== GROUP CARD (GRID) WITH FEATURE DISCOVERY ==========
  Widget _buildGroupGridItem(
    BuildContext context,
    EqubGroupModel group,
    EqubPackageModel package,
    bool isJoined,
    AbayLocalizations l10n, {
    bool isFirst = false,
  }) {
    final buttonText = group.status?.toLowerCase() == 'completed'
        ? 'COMPLETED'
        : (isJoined ? 'DETAILS & PAY' : 'JOIN');

    Widget button = ElevatedButton(
      onPressed: () => _handleGroupAction(group, package, isJoined, l10n),
      style: ElevatedButton.styleFrom(
        backgroundColor: isJoined
            ? AppTheme.primaryColor
            : AppTheme.accentColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 6),
        minimumSize: const Size(double.infinity, 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: Text(
        buttonText,
        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );

    // Wrap the first group's button with feature discovery
    if (isFirst) {
      button = DescribedFeatureOverlay(
        featureId: 'enroll_button',
        targetColor: Colors.white,
        textColor: Colors.black,
        backgroundColor: AppTheme.accentColor,
        contentLocation: ContentLocation.above,
        title: Text(isJoined ? 'Make a Contribution' : 'Join an eQub'),
        description: _buildFeatureDescription(
          context,
          isJoined
              ? 'Tap to see group details and pay your next contribution.'
              : 'Ready to start saving? Join this group and begin your journey.',
        ),
        tapTarget: Text(
          isJoined ? 'PAY' : 'JOIN',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        child: button,
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : const Color(0xFF1E293B).withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (group.name?.contains('Gold') ?? false)
                      ? Colors.amber.withOpacity(0.1)
                      : (isDark
                            ? Colors.white.withOpacity(0.05)
                            : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  (group.name?.contains('Gold') ?? false)
                      ? Icons.workspace_premium_rounded
                      : Icons.groups_2_rounded,
                  size: 16,
                  color: (group.name?.contains('Gold') ?? false)
                      ? Colors.amber.shade700
                      : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: group.status?.toLowerCase() == 'completed'
                      ? Colors.grey.withOpacity(0.15)
                      : const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  group.status?.toUpperCase() ?? 'ACTIVE',
                  style: GoogleFonts.outfit(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: group.status?.toLowerCase() == 'completed'
                        ? Colors.grey
                        : const Color(0xFF0D9488),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            group.name ?? 'Group',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.people_outline_rounded,
                size: 12,
                color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 4),
              Text(
                '${group.memberCount ?? 0}/${package.groupSize ?? 0} members',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const Spacer(),
          button,
        ],
      ),
    );
  }

  /// ========== GROUP ACTION HANDLER ==========
  void _handleGroupAction(
    EqubGroupModel group,
    EqubPackageModel package,
    bool isJoined,
    AbayLocalizations l10n,
  ) async {
    if (isJoined) {
      // Navigate to contribution / details screen
      nav.GoRouter.of(context).push(
        '/packages/contribution/${package.id}',
        extra: {'package': package, 'groupId': group.id},
      );
    } else {
      // Navigate to the new detailed enrollment screen
      final success = await nav.GoRouter.of(
        context,
      ).push<bool>('/enrollment', extra: {'group': group, 'package': package});

      if (success == true && context.mounted) {
        // Enrollment success! The backend auto-deducts the first round,
        // so we just refresh the data and stay on dashboard or
        // show success feedback already given by EnrollmentScreen.
      }
    }
  }

  Widget _buildEmptyActiveEqubsCard(
    BuildContext context,
    AbayLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.explore_outlined,
              color: AppTheme.primaryColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Join your first eQub!',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your savings journey today. Browse the packages below to find a group that fits your needs.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// ========== NAVIGATION TO GROUP DETAILS ==========
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
}
