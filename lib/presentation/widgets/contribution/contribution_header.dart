import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class ContributionHeader extends StatelessWidget {
  final bool isDark;

  const ContributionHeader({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : Colors.black87,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
          Column(
            children: [
              Text(
                AppTheme.appName.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1.5,
                  color: isDark ? Colors.white : AppTheme.primaryColor,
                ),
              ),
              Container(
                height: 2,
                width: 30,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.more_horiz_rounded,
              color: isDark ? Colors.white70 : Colors.black45,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
