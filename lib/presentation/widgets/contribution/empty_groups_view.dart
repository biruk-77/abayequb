import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyGroupsView extends StatelessWidget {
  final bool isDark;

  const EmptyGroupsView({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.layers_clear_rounded,
            size: 80,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No active groups found',
            style: GoogleFonts.outfit(
              fontSize: 18,
              color: isDark ? Colors.white38 : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
