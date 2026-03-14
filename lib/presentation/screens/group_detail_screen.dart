import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/equb_package_model.dart';
import '../../data/models/equb_group_model.dart';
import '../providers/equb_provider.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/contribution/detail_glass_card.dart';
import '../widgets/contribution/contribution_button.dart';

class GroupDetailScreen extends StatelessWidget {
  final EqubGroupModel group;
  final EqubPackageModel package;

  const GroupDetailScreen({
    super.key,
    required this.group,
    required this.package,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              // TOP BAR
              _buildTopBar(context, isDark),

              const SizedBox(height: 16),

              // MAIN CONTENT
              Expanded(
                child: Consumer<EqubProvider>(
                  builder: (context, provider, _) {
                    final isJoined = provider.myMemberships.any(
                      (m) => m.groupId.toString() == group.id.toString(),
                    );
                    final isCompleted = group.status?.toLowerCase() == 'completed';

                    return Column(
                      children: [
                        // DETAIL CARD
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: DetailGlassCard(
                              key: ValueKey(group.id),
                              group: group,
                              package: package,
                              isDark: isDark,
                            ),
                          ),
                        ),

                        // ACTION BUTTON
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                          child: ContributionButton(
                            groups: [group],
                            selectedIndex: 0,
                            package: package,
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

  Widget _buildTopBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                "GROUP DETAILS",
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
                  Icons.group_rounded,
                  size: 14,
                  color: AppTheme.accentColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${group.memberCount ?? 0} MBRS',
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
}
