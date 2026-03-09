import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/equb_group_model.dart';
import '../../../data/models/equb_package_model.dart';

class DetailGlassCard extends StatelessWidget {
  final EqubGroupModel group;
  final EqubPackageModel package;
  final bool isDark;

  const DetailGlassCard({
    super.key,
    required this.group,
    required this.package,
    required this.isDark,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppTheme.primaryColor;
    final accent = AppTheme.accentColor;
    final totalPayout =
        (package.contributionAmount ?? 0) * (package.groupSize ?? 0);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D2F) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: primary.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ══════════════════════════════════════════
          //  TOP: Total Payout + Status
          // ══════════════════════════════════════════
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [primary.withValues(alpha: 0.3), primary.withValues(alpha: 0.1)]
                    : [primary.withValues(alpha: 0.06), primary.withValues(alpha: 0.02)],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Payout
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            size: 13,
                            color: accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'TOTAL PAYOUT',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(totalPayout),
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : primary,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(group.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _statusColor(group.status).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _statusColor(group.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        (group.status ?? 'active').toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: _statusColor(group.status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ══════════════════════════════════════════
          //  3 STATS ROW (Contribution, Members, Cycle)
          // ══════════════════════════════════════════
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              children: [
                _buildStat(
                  icon: Icons.payments_rounded,
                  label: 'Per Cycle',
                  value: CurrencyFormatter.format(
                    package.contributionAmount ?? 0,
                  ),
                  color: primary,
                ),
                _vertDivider(),
                _buildStat(
                  icon: Icons.people_alt_rounded,
                  label: 'Members',
                  value: '${group.memberCount ?? package.groupSize ?? 0}',
                  color: const Color(0xFF7C3AED),
                ),
                _vertDivider(),
                _buildStat(
                  icon: Icons.loop_rounded,
                  label: 'Round',
                  value:
                      '${group.currentCycle ?? 1}/${group.totalCycles ?? package.totalCycles ?? 0}',
                  color: const Color(0xFF0891B2),
                ),
              ],
            ),
          ),

          // ══════════════════════════════════════════
          //  INFO GRID (Start Date, Risk Reserve, Fee, Created)
          // ══════════════════════════════════════════
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  // Row 1: Start Date + Risk Reserve
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.calendar_today_rounded,
                          label: 'Started',
                          value: _formatDate(group.startDate),
                          color: const Color(0xFF059669),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.shield_rounded,
                          label: 'Risk Reserve',
                          value:
                              'ETB ${group.riskReserve?.toStringAsFixed(2) ?? '0.00'}',
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Row 2: Fee + Created
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.percent_rounded,
                          label: 'Service Fee',
                          value: '${package.feePercentage ?? 0}%',
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.access_time_rounded,
                          label: 'Created',
                          value: _formatDate(group.createdAt),
                          color: const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── STAT CELL (top row) ───
  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─── INFO TILE (bottom grid) ───
  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white38 : Colors.black38,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _vertDivider() {
    return Container(
      width: 1,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            isDark ? Colors.white12 : Colors.black12,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'paused':
        return const Color(0xFFF59E0B);
      case 'canceled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF10B981);
    }
  }
}
