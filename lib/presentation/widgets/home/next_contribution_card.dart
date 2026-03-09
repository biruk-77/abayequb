// lib/presentation/widgets/home/next_contribution_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/contribution_model.dart';
import '../../../l10n/app_localizations.dart';
import 'package:abushakir/abushakir.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';

class NextContributionCard extends StatelessWidget {
  final ContributionModel contribution;
  final VoidCallback onPay;

  const NextContributionCard({
    super.key,
    required this.contribution,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AbayLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.1 : 0.4),
                    Colors.white.withValues(alpha: isDark ? 0.02 : 0.1),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeader(l10n, isDark),
                      _buildDaysRemainingBadge(
                        contribution.daysRemaining ?? 0,
                        contribution.status,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildMainInfo(context, l10n, isDark),
                  const SizedBox(height: 20),
                  _buildFooter(context, l10n, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AbayLocalizations l10n, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.upcoming_rounded,
            color: AppTheme.accentColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          l10n.nextContribution,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDaysRemainingBadge(int days, String? status) {
    final isLate = status?.toLowerCase() == 'late';
    final isUrgent = days <= 2 || isLate;

    String text;
    if (isLate) {
      text = "LATE";
    } else if (days == 0) {
      text = "Due Today";
    } else if (days < 0) {
      text = "${days.abs()} Days Past Due";
    } else {
      text = "$days Days Left";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isUrgent
            ? AppTheme.errorColor.withValues(alpha: 0.1)
            : AppTheme.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent
              ? AppTheme.errorColor.withValues(alpha: 0.3)
              : AppTheme.successColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isUrgent ? AppTheme.errorColor : AppTheme.successColor,
        ),
      ),
    );
  }

  Widget _buildMainInfo(
    BuildContext context,
    AbayLocalizations l10n,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contribution.groupInfo?.name ?? "eQub Group",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Cycle #${contribution.cycleNumber ?? 0}",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${contribution.amount?.toStringAsFixed(0) ?? '0'} ETB",
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.accentColor,
              ),
            ),
            Text(
              "Contribution",
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: isDark ? Colors.white38 : AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(
    BuildContext context,
    AbayLocalizations l10n,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: isDark ? Colors.white38 : AppTheme.textSecondaryLight,
              ),
              const SizedBox(width: 6),
              Text(
                contribution.dueDate != null
                    ? "Due: ${_getEthiopianDate(context, contribution.dueDate!)}"
                    : "Due Date Not Set",
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: onPay,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            minimumSize: const Size(100, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 8,
            shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
          ),
          child: Text(
            "Pay Now",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  String _getEthiopianDate(BuildContext context, DateTime date) {
    try {
      final etDate = EtDatetime.fromMillisecondsSinceEpoch(
        date.millisecondsSinceEpoch,
      );
      final locale =
          Provider.of<LocaleProvider>(
            context,
            listen: false,
          ).locale?.languageCode ??
          'en';
      if (locale == 'am') {
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
        return '${amharicMonths[etDate.month - 1]} ${etDate.day}, ${etDate.year}';
      } else {
        final englishMonths = [
          "Meskerem",
          "Tikimt",
          "Hidar",
          "Tahsas",
          "Tir",
          "Yekatit",
          "Megabit",
          "Miyaziya",
          "Ginbot",
          "Sene",
          "Hamle",
          "Nehase",
          "Pagume",
        ];
        return '${englishMonths[etDate.month - 1]} ${etDate.day}, ${etDate.year}';
      }
    } catch (_) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
