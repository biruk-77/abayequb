import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/equb_package_model.dart';
import '../providers/equb_provider.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/contribution/group_selector_list.dart';
import '../widgets/contribution/detail_glass_card.dart';
import '../widgets/contribution/empty_groups_view.dart';
import '../widgets/contribution/contribution_button.dart';

class ContributionLevelScreen extends StatefulWidget {
  final EqubPackageModel package;
  final String? initialGroupId;

  const ContributionLevelScreen({
    super.key,
    required this.package,
    this.initialGroupId,
  });

  @override
  State<ContributionLevelScreen> createState() =>
      _ContributionLevelScreenState();
}

class _ContributionLevelScreenState extends State<ContributionLevelScreen> {
  int _selectedGroupIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<EqubProvider>();
      await provider.fetchGroupsByPackage(widget.package.id);

      if (mounted) {
        final groups = provider.packageGroups;
        if (groups.isNotEmpty) {
          int index = 0;
          if (widget.initialGroupId != null) {
            final foundIndex = groups.indexWhere(
              (g) => g.id.toString() == widget.initialGroupId.toString(),
            );
            if (foundIndex != -1) index = foundIndex;
          }
          setState(() => _selectedGroupIndex = index);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.3, 0.7, 1.0],
            colors: isDark
                ? [
                    const Color(0xFF0A1628),
                    const Color(0xFF0F1D33),
                    const Color(0xFF0D1A2E),
                    const Color(0xFF080F1C),
                  ]
                : [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withValues(alpha: 0.85),
                    const Color(0xFFF0F4FA),
                    const Color(0xFFF8FAFC),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── PREMIUM TOP BAR ──
              _buildTopBar(context, isDark),

              // ── HERO PACKAGE INFO ──
              _buildPackageHero(isDark),

              SizedBox(height: screenHeight * 0.015),

              // ── MAIN CONTENT ──
              Expanded(
                child: Consumer<EqubProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: isDark ? AppTheme.accentColor : Colors.white,
                          strokeWidth: 2.5,
                        ),
                      );
                    }

                    final groups = provider.packageGroups;
                    if (groups.isEmpty) {
                      return EmptyGroupsView(isDark: isDark);
                    }

                    final displayIndex = _selectedGroupIndex.clamp(
                      0,
                      groups.length - 1,
                    );
                    final selectedGroup = groups[displayIndex];

                    final isJoined = provider.myMemberships.any(
                      (m) =>
                          m.groupId.toString() == selectedGroup.id.toString(),
                    );
                    final isCompleted =
                        selectedGroup.status?.toLowerCase() == 'completed';

                    return Column(
                      children: [
                        // ── GROUP SELECTOR ──
                        GroupSelectorList(
                          groups: groups,
                          selectedIndex: displayIndex,
                          isDark: isDark,
                          onSelected: (i) =>
                              setState(() => _selectedGroupIndex = i),
                        ),

                        SizedBox(height: screenHeight * 0.012),

                        // ── DETAIL CARD ──
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: DetailGlassCard(
                              key: ValueKey(selectedGroup.id),
                              group: selectedGroup,
                              package: widget.package,
                              isDark: isDark,
                            ),
                          ),
                        ),

                        // ── ACTION BUTTON ──
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                          child: ContributionButton(
                            groups: groups,
                            selectedIndex: displayIndex,
                            package: widget.package,
                            isJoined: isJoined,
                            isCompleted: isCompleted,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  TOP BAR (Back + Title + Badge)
  // ═══════════════════════════════════════════════════════
  Widget _buildTopBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Back
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          // App Title
          Column(
            children: [
              Text(
                AppTheme.appName.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 2,
                  color: isDark ? Colors.white : Colors.white,
                ),
              ),
              Container(
                height: 2,
                width: 24,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 14,
                  color: AppTheme.accentColor,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.package.schedule?.name.toUpperCase() ?? 'DAILY',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white70 : Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  HERO PACKAGE SECTION (Name + Amount)
  // ═══════════════════════════════════════════════════════
  Widget _buildPackageHero(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package Name
          Text(
            widget.package.name ?? 'Package',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          // Subtitle with contribution amount
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ETB ${widget.package.contributionAmount?.toStringAsFixed(0) ?? '0'}/cycle',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.group_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.package.groupSize ?? 0} members',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.percent_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.package.feePercentage ?? 0}% fee',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
