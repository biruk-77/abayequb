import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/equb_group_model.dart';
import '../../../data/models/equb_package_model.dart';
import '../../../core/theme/app_theme.dart';

class ContributionButton extends StatelessWidget {
  final List<EqubGroupModel> groups;
  final int selectedIndex;
  final EqubPackageModel package;
  final bool isJoined;
  final bool isCompleted;

  const ContributionButton({
    super.key,
    required this.groups,
    required this.selectedIndex,
    required this.package,
    required this.isJoined,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty || selectedIndex < 0 || selectedIndex >= groups.length) {
      return const SizedBox.shrink();
    }

    final selectedGroup = groups[selectedIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor;
    final Color fgColor;
    final String label;
    final IconData icon;

    if (isCompleted) {
      bgColor = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200;
      fgColor = isDark ? Colors.white38 : Colors.black38;
      label = 'GROUP COMPLETED';
      icon = Icons.check_circle_rounded;
    } else if (isJoined) {
      bgColor = AppTheme.accentColor;
      fgColor = AppTheme.primaryColor;
      label = 'CONTINUE TO PAYMENT';
      icon = Icons.arrow_forward_rounded;
    } else {
      bgColor = AppTheme.primaryColor;
      fgColor = Colors.white;
      label = 'JOIN THIS CIRCLE';
      icon = Icons.add_circle_outline_rounded;
    }

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isCompleted
            ? []
            : [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isCompleted
              ? null
              : () async {
                  if (isJoined) {
                    context.push(
                      '/payment',
                      extra: {
                        'amount': (package.contributionAmount ?? 0).toDouble(),
                        'packageName': package.name,
                        'groupId': selectedGroup.id,
                      },
                    );
                  } else {
                    final result = await context.push<bool>(
                      '/enrollment',
                      extra: {'group': selectedGroup, 'package': package},
                    );
                    if (result == true) {}
                  }
                },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: fgColor),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: fgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
