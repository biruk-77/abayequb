// lib/presentation/screens/package_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../providers/equb_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/abay_icon.dart';
import '../../data/models/equb_package_model.dart';

class PackageSelectionScreen extends StatefulWidget {
  const PackageSelectionScreen({super.key});

  @override
  State<PackageSelectionScreen> createState() => _PackageSelectionScreenState();
}

class _PackageSelectionScreenState extends State<PackageSelectionScreen> {
  String _filter = 'All';
  final List<String> _tabs = ['All', 'Weekly', 'Monthly', 'Daily'];

  static const List<Color> _cardAccents = [
    AppTheme.accentColor,
    Color(0xFF4F8EF7),
    AppTheme.successColor,
    Color(0xFFC084FC),
    Color(0xFFF97316),
    Color(0xFF2DD4BF),
    Color(0xFFF472B6),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EqubProvider>().fetchPackages();
    });
  }

  List<EqubPackageModel> _filtered(List<EqubPackageModel> packages) {
    if (_filter == 'All') return packages;
    return packages.where((p) {
      return p.schedule?.name.toLowerCase() == _filter.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final equbProvider = context.watch<EqubProvider>();
    final packages = _filtered(equbProvider.packages);
    final isLoading = equbProvider.isLoading;
    final error = equbProvider.error;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Immersive Header ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            floating: false,
            automaticallyImplyLeading: false,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.royalGradient,
                    ),
                  ),
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accentColor.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ABAY EQUB',
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.accentColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2.5,
                                    ),
                                  ),
                                  Text(
                                    AppConstants.appName,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              _buildAvatar(user),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            'Choose a Package',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Find the right eQub plan for your goals',
                            style: GoogleFonts.outfit(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Filter Chips ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.primaryColor,
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _tabs.map((tab) {
                    final selected = _filter == tab;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = tab),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                selected ? AppTheme.accentColor : Colors.white
                                  .withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tab,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: selected
                                  ? AppTheme.primaryColor
                                  : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────
          if (isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.accentColor),
              ),
            )
          else if (error != null)
            SliverFillRemaining(child: _buildError(error))
          else if (packages.isEmpty)
            SliverFillRemaining(child: _buildEmpty())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final package = packages[index];
                  final accent = _cardAccents[index % _cardAccents.length];
                  return FadeInUp(
                    delay: Duration(milliseconds: 60 * index),
                    duration: const Duration(milliseconds: 400),
                    child: _PackageCard(
                      package: package,
                      accent: accent,
                      onTap: () {
                        context.push(
                          '/packages/contribution/${package.id}',
                          extra: package,
                        );
                      },
                    ),
                  );
                }, childCount: packages.length),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.accentColor, width: 2),
      ),
      child: CircleAvatar(
        backgroundColor: Colors.white24,
        backgroundImage:
            user?.profileImage != null && user!.profileImage!.isNotEmpty
            ? AbayIcon.getImageProvider(user.profileImage)
            : null,
        radius: 20,
        child: user?.profileImage == null || user!.profileImage!.isEmpty
            ? const Icon(Icons.person, color: Colors.white70, size: 20)
            : null,
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTheme.errorColor,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.outfit(color: AppTheme.textSecondaryLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<EqubProvider>().fetchPackages(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No packages found',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different filter',
            style: GoogleFonts.outfit(color: AppTheme.textSecondaryLight),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Package Card
// ─────────────────────────────────────────────────────────────────────────────

class _PackageCard extends StatelessWidget {
  final EqubPackageModel package;
  final Color accent;
  final VoidCallback onTap;

  const _PackageCard({
    required this.package,
    required this.accent,
    required this.onTap,
  });

  String _scheduleLabel() {
    switch (package.schedule) {
      case EqubSchedule.daily:
        return 'Daily';
      case EqubSchedule.weekly:
        return 'Weekly';
      case EqubSchedule.monthly:
        return 'Monthly';
      default:
        return 'Flexible';
    }
  }

  IconData _scheduleIcon() {
    switch (package.schedule) {
      case EqubSchedule.daily:
        return Icons.wb_sunny_rounded;
      case EqubSchedule.weekly:
        return Icons.calendar_view_week_rounded;
      case EqubSchedule.monthly:
        return Icons.calendar_month_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              // Colored accent strip at top
              Container(
                height: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withValues(alpha: 0.4)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Row(
                  children: [
                    // Icon box
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: AbayIcon(
                          iconPath: package.iconPath,
                          name: package.name,
                          fit: BoxFit.contain,
                          color: accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Text info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          Text(
                            package.name ?? AppConstants.appName,
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),

                          // Schedule badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_scheduleIcon(), color: accent, size: 11),
                                const SizedBox(width: 4),
                                Text(
                                  _scheduleLabel(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Stats
                          Wrap(
                            spacing: 16,
                            runSpacing: 6,
                            children: [
                              _stat(
                                Icons.payments_rounded,
                                'Contribution',
                                package.contributionAmount != null
                                    ? CurrencyFormatter.format(
                                        package.contributionAmount!,
                                      )
                                    : '—',
                              ),
                              _stat(
                                Icons.group_rounded,
                                'Group',
                                package.groupSize != null
                                    ? '${package.groupSize} members'
                                    : '—',
                              ),
                            ],
                          ),

                          if (package.targetAmount != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.flag_rounded,
                                  size: 14,
                                  color: AppTheme.textSecondaryLight,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Target: ${CurrencyFormatter.format(package.targetAmount!)} ${AppConstants.currency}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: AppTheme.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),
                    // Arrow button
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppTheme.royalGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
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

  Widget _stat(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 11, color: AppTheme.textSecondaryLight),
            const SizedBox(width: 3),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
