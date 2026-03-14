// lib/presentation/widgets/home/quick_actions_row.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickActionsRow extends StatelessWidget {
  final VoidCallback? onDeposit;
  final VoidCallback? onWithdraw;
  final VoidCallback? onHistory;
  final VoidCallback? onCalendar;
  final VoidCallback? onRefer;
  final VoidCallback? onDispute;
  final VoidCallback? onAccounts;

  const QuickActionsRow({
    super.key,
    this.onDeposit,
    this.onWithdraw,
    this.onHistory,
    this.onCalendar,
    this.onRefer,
    this.onDispute,
    this.onAccounts,
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
              Icons.wallet_rounded,
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

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark 
                    ? Colors.white.withValues(alpha: 0.05) 
                    : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon, 
                  color: const Color(0xFF003366), // Match mockup deep blue
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : const Color(0xFF003366),
          ),
        ),
      ],
    );
  }
}
