import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/equb_group_model.dart';
import '../../../data/models/equb_package_model.dart';
import '../abay_icon.dart';

class GroupListCard extends StatelessWidget {
  final EqubGroupModel group;
  final EqubPackageModel package;
  final bool isJoined;
  final bool isCompleted;
  final bool isDark;
  final VoidCallback onTap;

  const GroupListCard({
    super.key,
    required this.group,
    required this.package,
    required this.isJoined,
    required this.isCompleted,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppTheme.primaryColor;
    final accent = AppTheme.accentColor;
    final totalPayout = (package.contributionAmount ?? 0) * (package.groupSize ?? 0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isJoined
                ? accent.withValues(alpha: 0.5)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05)),
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: AbayIcon(
                      name: group.name,
                      width: 28,
                      height: 28,
                      color: primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name ?? 'Group',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.people_rounded, size: 12, color: isDark ? Colors.white54 : Colors.black54),
                          const SizedBox(width: 4),
                          Text(
                            '${group.memberCount ?? 0}/${package.groupSize ?? 0}',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.loop_rounded, size: 12, color: isDark ? Colors.white54 : Colors.black54),
                          const SizedBox(width: 4),
                          Text(
                            'Rnd ${group.currentCycle ?? 1}',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isJoined ? accent : primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (isJoined ? accent : primary).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    isJoined ? 'CONTRIBUTE' : 'JOIN',
                    style: GoogleFonts.outfit(
                      color: isJoined ? primary : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
            const SizedBox(height: 12),
            
            // Extra Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSmallInfo(
                  Icons.payments_rounded,
                  'Payout',
                  CurrencyFormatter.format(totalPayout),
                  isDark,
                  primary,
                ),
                _buildSmallInfo(
                  Icons.shield_rounded,
                  'Reserve',
                  CurrencyFormatter.format(group.riskReserve ?? 0),
                  isDark,
                  const Color(0xFFD97706),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSmallInfo(IconData icon, String label, String value, bool isDark, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
