// lib/presentation/widgets/home/next_payout_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/payout_model.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import 'package:abushakir/abushakir.dart';

class NextPayoutCard extends StatelessWidget {
  final PayoutModel payout;

  const NextPayoutCard({super.key, required this.payout});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.successColor.withValues(alpha: isDark ? 0.3 : 0.1),
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.successColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.auto_graph_rounded,
                              color: AppTheme.successColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Upcoming Payout",
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white70
                                  : AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                AppTheme.successColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          "WINNER",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              payout.groupName,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDark ? Colors.white : AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Estimated Payout Date",
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white54
                                    : AppTheme.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${payout.amount.toStringAsFixed(0)} ETB",
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.successColor,
                            ),
                          ),
                          Text(
                            "To Wallet",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white38
                                  : AppTheme.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 14,
                        color: isDark
                            ? Colors.white38
                            : AppTheme.textSecondaryLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getEthiopianDate(context, payout.payoutDate),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white54
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
