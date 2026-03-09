import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/equb_group_model.dart';
import '../../../core/theme/app_theme.dart';
import '../abay_icon.dart';

class GroupCarouselItem extends StatelessWidget {
  final EqubGroupModel group;
  final int index;
  final double pageValue;
  final bool isDark;
  final Color primary;

  const GroupCarouselItem({
    super.key,
    required this.group,
    required this.index,
    required this.pageValue,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    // PageView Transformation
    double relativePosition = index - pageValue;
    double scale = (1 - (relativePosition.abs() * 0.15)).clamp(0.0, 1.0);
    double opacity = (1 - (relativePosition.abs() * 0.4)).clamp(0.0, 1.0);
    double rotation = (relativePosition * 0.15).clamp(-0.2, 0.2);
    double translate = relativePosition * 40;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // perspective
        ..rotateY(rotation)
        ..scaleByDouble(scale, scale, 1.0, 1.0)
        ..translateByDouble(translate, 0.0, 0.0, 1.0),
      alignment: Alignment.center,
      child: Opacity(
        opacity: opacity,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primary,
                primary.withValues(alpha: 0.8),
                primary.withAlpha(200),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: isDark ? 0.4 : 0.25),
                blurRadius: 25,
                spreadRadius: -5,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // Decorative background pattern
                Positioned(
                  top: -40,
                  right: -40,
                  child: Transform.rotate(
                    angle: relativePosition * 0.5,
                    child: Opacity(
                      opacity: 0.15,
                      child: const Icon(
                        Icons.blur_on_rounded,
                        size: 220,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Badge indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          group.status?.toUpperCase() ?? 'ACTIVE',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      AbayIcon(
                        name: group.name,
                        width: 52,
                        height: 52,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),

                      Text(
                        group.name ?? 'Group',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),

                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.accentColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentColor,
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Verified Savings Circle',
                            style: GoogleFonts.outfit(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
