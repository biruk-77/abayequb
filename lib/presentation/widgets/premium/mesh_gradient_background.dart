import 'package:flutter/material.dart';
import 'dart:ui';

class MeshGradientBackground extends StatelessWidget {
  final Widget child;
  const MeshGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // 1. Solid Base
        Container(color: theme.scaffoldBackgroundColor),

        // 2. Animated/Static Mesh Orbs
        Positioned(
          top: -100,
          left: -100,
          child: _buildOrb(
            300,
            (isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1))
                .withOpacity(isDark ? 0.12 : 0.08),
          ), // Indigo
        ),
        Positioned(
          bottom: 100,
          right: -150,
          child: _buildOrb(
            400,
            (isDark ? const Color(0xFF5EEAD4) : const Color(0xFF2DD4BF))
                .withOpacity(isDark ? 0.08 : 0.05),
          ), // Teal
        ),
        Positioned(
          top: 300,
          left: 200,
          child: _buildOrb(
            250,
            (isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B))
                .withOpacity(isDark ? 0.06 : 0.03),
          ), // Amber
        ),

        // 3. Subtle Grain/Noise overlay (if possible, but let's stick to glass)

        // 4. The Content
        child,
      ],
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
