// lib/presentation/widgets/home/quick_actions_row.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class QuickActionsRow extends StatelessWidget {
  final VoidCallback? onDeposit;
  final VoidCallback? onWithdraw;
  final VoidCallback? onHistory;
  final VoidCallback? onCalendar;
  final VoidCallback? onRefer;

  const QuickActionsRow({
    super.key,
    this.onDeposit,
    this.onWithdraw,
    this.onHistory,
    this.onCalendar,
    this.onRefer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildAction(
              context,
              Icons.account_balance_wallet_rounded,
              "Deposit",
              onDeposit,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildAction(
              context,
              Icons.redo_rounded,
              "Withdraw",
              onWithdraw,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildAction(
              context,
              Icons.receipt_long_rounded,
              "History",
              onHistory,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildAction(
              context,
              Icons.calendar_month_rounded,
              "Calendar",
              onCalendar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback? onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            width: 1,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.1),
                    AppTheme.primaryColor.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? Colors.white60
                        : AppTheme.primaryColor.withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
