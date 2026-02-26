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
import '../providers/notification_provider.dart';

// Models
import '../../data/models/user_model.dart';
import '../../data/models/equb_package_model.dart';
import '../../data/models/equb_group_model.dart';
import '../../data/models/equb_member_model.dart';

// Widgets
import '../widgets/abay_icon.dart';
import '../widgets/high_end_notification_badge.dart';
import '../widgets/premium/premium_group_card.dart';

// ─────────────────────────────────────────────────────────
// Screen-local color shortcuts — all wired to AppTheme.
// Only _goldLight, _emerald, _textMuted and _border have no
// AppTheme token yet, so they keep a literal value.
// ─────────────────────────────────────────────────────────
const Color _gold = AppTheme.accentColor; // #D4AF37 Royal Gold
const Color _goldLight = Color(0xFFF4CF6E); // lighter gold highlight
const Color _emerald = Color(0xFF059669); // success / payout green
const Color _bgLight = AppTheme.bgLight;
const Color _surface = AppTheme.surfaceLight;
const Color _textPri = AppTheme.textPrimaryLight;
const Color _textSec = AppTheme.textSecondaryLight;
const Color _textMuted = Color(0xFF94A3B8);
const Color _border = Color(0xFFE2E8F0);

class DashboardScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const DashboardScreen({super.key, required this.scaffoldKey});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final ScrollController _equbScrollController;

  @override
  void initState() {
    super.initState();
    _equbScrollController = ScrollController();
    _initData();
    _setupAnimations();
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
      if (equbProvider.myGroups.isEmpty) equbProvider.fetchUserEqubData();
    });
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

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
        });
        authProvider.completeHomeShowcase();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _equbScrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await Future.wait([
      Provider.of<WalletProvider>(context, listen: false).fetchWallet(),
      Provider.of<EqubProvider>(
        context,
        listen: false,
      ).fetchPackages(forceRefresh: true),
      Provider.of<EqubProvider>(context, listen: false).fetchUserEqubData(),
    ]);
  }

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
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AbayLocalizations.of(context);
    if (l10n == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final wallet = context.watch<WalletProvider>().wallet;
    final walletProv = context.watch<WalletProvider>();
    final equbProvider = context.watch<EqubProvider>();
    final packages = equbProvider.packages;
    final groups = equbProvider.groups;
    final myGroups = equbProvider.myGroups;
    final memberships = equbProvider.myMemberships;
    final user = context.watch<AuthProvider>().user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF050B14) : _bgLight,
      body: Stack(
        children: [
          // Subtle animated dot-grid background
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _MeshGradientPainter(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : AppTheme.primaryColor.withValues(alpha: 0.035),
                ),
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: _refreshData,
            color: AppTheme.primaryColor,
            backgroundColor: Colors.white,
            strokeWidth: 2.5,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // ── Command-centre header ────────────────────────
                _buildHeader(user, isDark, l10n),

                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Vault / Portfolio balance card ────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                        child: FadeInDown(
                          duration: const Duration(milliseconds: 700),
                          from: 24,
                          child: _PortfolioCard(
                            available: wallet?.available ?? 0.0,
                            locked: wallet?.locked ?? 0.0,
                            isVisible: walletProv.isBalanceVisible,
                            onToggle: () => context
                                .read<WalletProvider>()
                                .toggleBalanceVisibility(),
                          ),
                        ),
                      ),

                      // ── Quick Stats Strip ─────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: FadeInUp(
                          delay: const Duration(milliseconds: 150),
                          duration: const Duration(milliseconds: 600),
                          child: _QuickStatsStrip(
                            activeGroups: myGroups.length,
                            trustScore: user?.trustScore ?? 0,
                            nextPayoutAmt: memberships.isNotEmpty
                                ? (packages.isNotEmpty
                                      ? packages.first.targetAmount ?? 0
                                      : 0)
                                : 0,
                            isDark: isDark,
                          ),
                        ),
                      ),

                      // ── Progress Summary ───────────────────
                      if (myGroups.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                          child: FadeInUp(
                            delay: const Duration(milliseconds: 170),
                            duration: const Duration(milliseconds: 600),
                            child: _ProgressSummary(
                              groups: myGroups,
                              isDark: isDark,
                              l10n: l10n,
                            ),
                          ),
                        ),

                      // ── Financial milestones ──────────────────
                      if (myGroups.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                          child: FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            duration: const Duration(milliseconds: 600),
                            child: _buildMilestones(
                              myGroups,
                              memberships,
                              packages,
                              l10n,
                              isDark,
                            ),
                          ),
                        ),

                      // ── Active eQubs ──────────────────────────
                      const SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _SectionLabel(label: l10n.yourActiveEqubs),
                      ),
                      const SizedBox(height: 14),

                      if (myGroups.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildEmptyEqubs(context, l10n, isDark),
                        )
                      else
                        AnimatedBuilder(
                          animation: _equbScrollController,
                          builder: (context, child) {
                            return SizedBox(
                              height: 280,
                              child: ListView.builder(
                                controller: _equbScrollController,
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                clipBehavior: Clip.none,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                itemCount: myGroups.length,
                                itemBuilder: (context, index) {
                                  final group = myGroups[index];
                                  final package = packages.firstWhere(
                                    (p) => p.id == group.packageId,
                                    orElse: () => EqubPackageModel(id: 'temp'),
                                  );
                                  final membership = memberships.firstWhere(
                                    (m) => m.groupId == group.id,
                                    orElse: () => EqubMemberModel(
                                      groupId: '',
                                      userId: '',
                                    ),
                                  );

                                  // Calculate scale based on position
                                  double scale = 1.0;
                                  if (_equbScrollController.hasClients) {
                                    final screenWidth = MediaQuery.of(
                                      context,
                                    ).size.width;
                                    final itemCenter =
                                        (index * 294.0) + // width + padding
                                        147.0 + // half width
                                        24.0 - // initial padding
                                        _equbScrollController.offset;
                                    final diff = (screenWidth / 2 - itemCenter)
                                        .abs();
                                    scale = (1.0 - (diff / screenWidth) * 0.15)
                                        .clamp(0.85, 1.0);
                                  }

                                  return Transform.scale(
                                    scale: scale,
                                    child: FadeInRight(
                                      delay: Duration(
                                        milliseconds: index * 100 + 100,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 600,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 16,
                                          bottom: 20,
                                        ),
                                        child: SizedBox(
                                          width: 280,
                                          child: PremiumGroupCard(
                                            group: group,
                                            contributionAmount:
                                                package.contributionAmount ?? 0,
                                            currentCycle:
                                                group.currentCycle ?? 1,
                                            payoutOrder: membership.payoutOrder,
                                            onTap: () => _navigateToGroup(
                                              context,
                                              group,
                                              package,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                      // ── Explore packages ──────────────────────
                      const SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FadeInUp(
                          delay: const Duration(milliseconds: 300),
                          duration: const Duration(milliseconds: 600),
                          child: DescribedFeatureOverlay(
                            featureId: 'packages_section',
                            targetColor: Colors.white,
                            textColor: Colors.black,
                            backgroundColor: AppTheme.accentColor,
                            contentLocation: ContentLocation.below,
                            title: Text(l10n.explorePackages),
                            description: _featureDesc(
                              context,
                              'Browse packages. Tap any to see groups and join.',
                            ),
                            tapTarget: const Icon(
                              Icons.explore_rounded,
                              color: Colors.black,
                            ),
                            child: _SectionLabel(label: l10n.explorePackages),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildPackages(
                          context,
                          packages,
                          groups,
                          memberships,
                          l10n,
                          isDark,
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ), // closes RefreshIndicator
        ], // closes Stack children
      ), // closes Stack
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HEADER
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(UserModel? user, bool isDark, AbayLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 148,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryColor,
      surfaceTintColor: AppTheme.primaryColor,
      leading: DescribedFeatureOverlay(
        featureId: 'menu_button',
        targetColor: Colors.white,
        textColor: Colors.black,
        backgroundColor: AppTheme.accentColor,
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
        // Notification bell
        DescribedFeatureOverlay(
          featureId: 'notifications',
          targetColor: Colors.white,
          textColor: Colors.black,
          backgroundColor: AppTheme.accentColor,
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
        // Avatar
        GestureDetector(
          onTap: () => nav.GoRouter.of(context).push('/profile'),
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _gold, width: 2),
              boxShadow: [
                BoxShadow(
                  color: _gold.withValues(alpha: 0.3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
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
        background: _HeaderBg(
          user: user,
          ethiopianDate: _getEthiopianDate(),
          trustScore: user?.trustScore ?? 0,
          pulseAnimation: _pulseAnimation,
          l10n: l10n,
          onSkip: () => FeatureDiscovery.dismissAll(context),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // MILESTONES
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildMilestones(
    List<EqubGroupModel> myGroups,
    List<EqubMemberModel> memberships,
    List<EqubPackageModel> packages,
    AbayLocalizations l10n,
    bool isDark,
  ) {
    DateTime? nextContribDate;
    DateTime? nextPayoutDate;
    double contribAmt = 0.0;
    double payoutAmt = 0.0;

    for (final group in myGroups) {
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

    return _MilestonesCard(
      isDark: isDark,
      nextContribDate: _formatDate(nextContribDate),
      nextPayoutDate: _formatDate(nextPayoutDate),
      contribAmt: contribAmt,
      payoutAmt: payoutAmt,
      l10n: l10n,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PACKAGES (expandable)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildPackages(
    BuildContext context,
    List<EqubPackageModel> packages,
    List<EqubGroupModel> groups,
    List<EqubMemberModel> memberships,
    AbayLocalizations l10n,
    bool isDark,
  ) {
    if (packages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
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
        final pkgGroups = groups
            .where((g) => g.packageId == package.id.toString())
            .toList();

        return FadeInUp(
          delay: Duration(milliseconds: index * 100 + 400),
          duration: const Duration(milliseconds: 600),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : _surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white10 : _border),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : _textPri.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
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
                    context.read<EqubProvider>().fetchGroupsByPackage(
                      package.id.toString(),
                    );
                  }
                },
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white10
                        : AppTheme.primaryColor.withValues(alpha: 0.08),
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
                    color: isDark ? Colors.white : _textPri,
                  ),
                ),
                subtitle: Text(
                  '${package.schedule?.name.toUpperCase() ?? 'MONTHLY'}  •  ${CurrencyFormatter.format(package.contributionAmount ?? 0)}',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : _textSec,
                    letterSpacing: 0.2,
                  ),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isDark ? Colors.white38 : _textMuted,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        Divider(
                          height: 1,
                          color: isDark ? Colors.white10 : _border,
                        ),
                        const SizedBox(height: 14),
                        if (pkgGroups.isEmpty)
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
                                            : _textSec,
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
                            itemCount: pkgGroups.length,
                            itemBuilder: (context, gi) {
                              final group = pkgGroups[gi];
                              final isJoined = memberships.any(
                                (m) => m.groupId == group.id,
                              );
                              return _buildGroupCard(
                                context,
                                group,
                                package,
                                isJoined,
                                l10n,
                                isDark: isDark,
                                isFirst: index == 0 && gi == 0,
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

  Widget _buildGroupCard(
    BuildContext context,
    EqubGroupModel group,
    EqubPackageModel package,
    bool isJoined,
    AbayLocalizations l10n, {
    required bool isDark,
    bool isFirst = false,
  }) {
    final btnText = group.status?.toLowerCase() == 'completed'
        ? 'COMPLETED'
        : (isJoined ? 'DETAILS & PAY' : 'JOIN');

    Widget btn = ElevatedButton(
      onPressed: () => _handleGroupAction(group, package, isJoined, l10n),
      style: ElevatedButton.styleFrom(
        backgroundColor: isJoined
            ? AppTheme.primaryColor
            : AppTheme.accentColor,
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
      btn = DescribedFeatureOverlay(
        featureId: 'enroll_button',
        targetColor: Colors.white,
        textColor: Colors.black,
        backgroundColor: AppTheme.accentColor,
        contentLocation: ContentLocation.above,
        title: Text(isJoined ? 'Make a Contribution' : 'Join an eQub'),
        description: _featureDesc(
          context,
          isJoined
              ? 'Tap to see group details and pay your next contribution.'
              : 'Ready to start saving? Join this group and begin your journey.',
        ),
        tapTarget: Text(
          isJoined ? 'PAY' : 'JOIN',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        child: btn,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white10 : _border),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : _textPri.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
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
                  color: isDark
                      ? Colors.white10
                      : AppTheme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AbayIcon(
                  name: group.name,
                  width: 16,
                  height: 16,
                  color: isDark ? Colors.white70 : AppTheme.primaryColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: group.status?.toLowerCase() == 'completed'
                      ? Colors.grey.withValues(alpha: 0.15)
                      : AppTheme.primaryColor.withValues(alpha: 0.08),
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
                        : AppTheme.primaryColor,
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
              color: isDark ? Colors.white : _textPri,
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
                color: isDark ? Colors.white38 : _textMuted,
              ),
              const SizedBox(width: 3),
              Text(
                '${group.memberCount ?? 0}/${package.groupSize ?? 0}',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: isDark ? Colors.white38 : _textMuted,
                ),
              ),
            ],
          ),
          const Spacer(),
          btn,
        ],
      ),
    );
  }

  Widget _buildEmptyEqubs(
    BuildContext context,
    AbayLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.primaryColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Join your first eQub!',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : _textPri,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Start your savings journey today. Browse the packages below to find a group that fits your goals.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark ? Colors.white.withValues(alpha: 0.5) : _textSec,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

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
}

// ═══════════════════════════════════════════════════════════════════════════
// HEADER BACKGROUND
// ═══════════════════════════════════════════════════════════════════════════
class _HeaderBg extends StatelessWidget {
  final UserModel? user;
  final String ethiopianDate;
  final int trustScore;
  final Animation<double> pulseAnimation;
  final AbayLocalizations l10n;
  final VoidCallback onSkip;

  const _HeaderBg({
    required this.user,
    required this.ethiopianDate,
    required this.trustScore,
    required this.pulseAnimation,
    required this.l10n,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            const Color(0xFF0A363A),
            const Color(0xFF051D1F),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Dynamic mesh glow top-right
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Subtle Bottom Border
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _gold.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInLeft(
                  duration: const Duration(milliseconds: 700),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.welcome.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.fullName ?? 'User',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Glassy Date Container
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  color: _gold.withValues(alpha: 0.8),
                                  size: 12,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  ethiopianDate,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Enhanced Trust Badge
                      DescribedFeatureOverlay(
                        featureId: 'trust_score',
                        targetColor: Colors.white,
                        textColor: Colors.black,
                        backgroundColor: AppTheme.accentColor,
                        contentLocation: ContentLocation.above,
                        title: const Text('Trust Score'),
                        description: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your reliability score. Pay on time to increase it.',
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: onSkip,
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
                        tapTarget: _TrustBadge(trustScore: trustScore),
                        child: ScaleTransition(
                          scale: pulseAnimation,
                          child: _TrustBadge(trustScore: trustScore),
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
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final int trustScore;
  const _TrustBadge({required this.trustScore});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _gold.withValues(alpha: 0.5), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user_rounded, color: _gold, size: 14),
          const SizedBox(width: 5),
          Text(
            '$trustScore',
            style: GoogleFonts.outfit(
              color: _gold,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PORTFOLIO / BALANCE CARD
// Shows: TOTAL PORTFOLIO (available + locked), AVAILABLE chip, LOCKED chip
// ═══════════════════════════════════════════════════════════════════════════
class _PortfolioCard extends StatelessWidget {
  final double available;
  final double locked;
  final bool isVisible;
  final VoidCallback onToggle;

  const _PortfolioCard({
    required this.available,
    required this.locked,
    required this.isVisible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final total = available + locked;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.3 : 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Base Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryLight,
                      AppTheme.primaryColor,
                      const Color(0xFF041F21),
                    ],
                  ),
                ),
              ),
            ),

            // Specular Highlight / Mesh Glow
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_gold.withValues(alpha: 0.15), Colors.transparent],
                  ),
                ),
              ),
            ),

            // Subtle Glass Layer
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  backgroundBlendMode: BlendMode.overlay,
                ),
              ),
            ),

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
                              color: _gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _gold.withValues(alpha: 0.2),
                              ),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: _gold,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'ABAY VAULT',
                            style: GoogleFonts.outfit(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: onToggle,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Icon(
                            isVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'TOTAL BALANCE',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isVisible ? CurrencyFormatter.format(total) : 'ETB ******',
                    style: GoogleFonts.outfit(
                      color: _goldLight,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _gold.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _BalanceChip(
                          icon: Icons.savings_rounded,
                          label: 'AVAILABLE',
                          amount: available,
                          isVisible: isVisible,
                          accentColor: _gold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BalanceChip(
                          icon: Icons.lock_clock_rounded,
                          label: 'LOCKED',
                          amount: locked,
                          isVisible: isVisible,
                          accentColor: Colors.white60,
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

// Individual chip inside the portfolio card
class _BalanceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final bool isVisible;
  final Color accentColor;

  const _BalanceChip({
    required this.icon,
    required this.label,
    required this.amount,
    required this.isVisible,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 14),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: accentColor.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isVisible ? CurrencyFormatter.format(amount) : '******',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MILESTONES CARD
// ═══════════════════════════════════════════════════════════════════════════
class _MilestonesCard extends StatelessWidget {
  final bool isDark;
  final String nextContribDate;
  final String nextPayoutDate;
  final double contribAmt;
  final double payoutAmt;
  final AbayLocalizations l10n;

  const _MilestonesCard({
    required this.isDark,
    required this.nextContribDate,
    required this.nextPayoutDate,
    required this.contribAmt,
    required this.payoutAmt,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : _border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_awesome_motion_rounded,
                    color: AppTheme.primaryColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'FINANCIAL MILESTONES',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : _textSec,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.05) : _border,
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _MilestoneItem(
                    label: l10n.nextContribution,
                    date: nextContribDate,
                    amount: contribAmt,
                    color: AppTheme.primaryColor,
                    icon: Icons.upload_rounded,
                    isDark: isDark,
                  ),
                ),
                Container(
                  width: 1,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : _border,
                ),
                Expanded(
                  child: _MilestoneItem(
                    label: l10n.nextPayout,
                    date: nextPayoutDate,
                    amount: payoutAmt,
                    color: _emerald,
                    icon: Icons.download_rounded,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneItem extends StatelessWidget {
  final String label;
  final String date;
  final double amount;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _MilestoneItem({
    required this.label,
    required this.date,
    required this.amount,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white38 : _textMuted,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : _textPri,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  CurrencyFormatter.format(amount),
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION LABEL  (with left gold accent bar)
// ═══════════════════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 6,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_gold, _goldLight],
            ),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : _textPri,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// QUICK STATS STRIP  (3 mini stat pills in a row)
// ═══════════════════════════════════════════════════════════════════════════
class _QuickStatsStrip extends StatelessWidget {
  final int activeGroups;
  final int trustScore;
  final double nextPayoutAmt;
  final bool isDark;

  const _QuickStatsStrip({
    required this.activeGroups,
    required this.trustScore,
    required this.nextPayoutAmt,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatPill(
            icon: Icons.account_tree_rounded,
            label: 'ACTIVE',
            value: '$activeGroups Groups',
            accent: AppTheme.primaryColor,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatPill(
            icon: Icons.shield_rounded,
            label: 'TRUST',
            value: '$trustScore / 100',
            accent: _gold,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatPill(
            icon: Icons.auto_graph_rounded,
            label: 'PAYOUT',
            value: CurrencyFormatter.format(nextPayoutAmt),
            accent: _emerald,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final bool isDark;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 14, color: accent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : _textSec,
                      letterSpacing: 0.2, // Reduced for better fit
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : _textPri,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROGRESS SUMMARY WIDGET
// ═══════════════════════════════════════════════════════════════════════════
class _ProgressSummary extends StatelessWidget {
  final List<EqubGroupModel> groups;
  final bool isDark;
  final AbayLocalizations l10n;

  const _ProgressSummary({
    required this.groups,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate overall progress across all groups
    double totalProgressSum = 0;
    int itemsCount = 0;

    for (final g in groups) {
      if (g.status?.toLowerCase() != 'completed') {
        // Mock total cycles as 12 if not specified elsewhere
        const total = 12;
        final current = g.currentCycle ?? 1;
        totalProgressSum += (current / total).clamp(0.0, 1.0);
        itemsCount++;
      }
    }

    final avgProgress = itemsCount > 0 ? totalProgressSum / itemsCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CustomPaint(
                  painter: _ProgressPainter(
                    progress: avgProgress,
                    color: AppTheme.primaryColor,
                    isDark: isDark,
                  ),
                ),
              ),
              Text(
                '${(avgProgress * 100).toInt()}%',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : _textPri,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SAVINGS PROGRESS',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : _textSec,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You are halfway to your goals!',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : _textPri,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: avgProgress,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : AppTheme.primaryColor.withValues(alpha: 0.05),
                    color: AppTheme.primaryColor,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isDark;

  _ProgressPainter({
    required this.progress,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 6.0;

    final bgPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.05)
          : color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    final angle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -3.14159 / 2,
      angle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DOT-GRID BACKGROUND PAINTER
// ═══════════════════════════════════════════════════════════════════════════
class _MeshGradientPainter extends CustomPainter {
  final Color color;
  const _MeshGradientPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    final random = [0.2, 0.5, 0.8, 0.3, 0.7, 0.9, 0.1, 0.4, 0.6];

    for (var i = 0; i < random.length; i++) {
      final x = size.width * random[i];
      final y = size.height * random[(i + 2) % random.length];
      final r = 100.0 + random[i] * 200.0;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_MeshGradientPainter old) => old.color != color;
}
