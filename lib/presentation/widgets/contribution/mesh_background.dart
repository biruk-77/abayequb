import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class MeshBackground extends StatefulWidget {
  final bool isDark;
  final Color primary;

  const MeshBackground({
    super.key,
    required this.isDark,
    required this.primary,
  });

  @override
  State<MeshBackground> createState() => _MeshBackgroundState();
}

class _MeshBackgroundState extends State<MeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: widget.isDark
              ? const Color(0xFF020617)
              : const Color(0xFFF8FAFC),
          child: Stack(
            children: [
              // Rotating Blob 1
              Positioned(
                top: -100 + (math.sin(_controller.value * math.pi * 2) * 50),
                right: -100 + (math.cos(_controller.value * math.pi * 2) * 30),
                child: _Blob(
                  size: 450,
                  color: widget.primary
                    .withValues(alpha: widget.isDark ? 0.2 : 0.1),
                  blur: 80,
                ),
              ),

              // Oscillating Blob 2
              Positioned(
                bottom: 200 + (math.cos(_controller.value * math.pi * 2) * 80),
                left: -150 + (math.sin(_controller.value * math.pi * 2) * 40),
                child: _Blob(
                  size: 400,
                  color: const Color(0xFF38BDF8)
                    .withValues(alpha: widget.isDark ? 0.15 : 0.08),
                  blur: 100,
                ),
              ),

              // Center accent blob
              Positioned(
                top:
                    MediaQuery.of(context).size.height * 0.4 +
                    (math.sin(_controller.value * math.pi * 2) * 100),
                right: MediaQuery.of(context).size.width * 0.2,
                child: _Blob(
                  size: 300,
                  color: widget.primary
                    .withValues(alpha: widget.isDark ? 0.1 : 0.05),
                  blur: 90,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  final double blur;

  const _Blob({required this.size, required this.color, required this.blur});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
