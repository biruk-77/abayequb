import 'dart:math';
import 'package:flutter/material.dart';

class HighEndPressedEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const HighEndPressedEffect({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  State<HighEndPressedEffect> createState() => _HighEndPressedEffectState();
}

class _HighEndPressedEffectState extends State<HighEndPressedEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;
  Offset _tapPosition = Offset.zero;
  double _maxRadius = 0;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    _tapPosition = box.globalToLocal(details.globalPosition);
    _maxRadius = box.size.longestSide * 1.2;
    _rippleController.forward(from: 0.0);
  }

  void _handleTapUp(TapUpDetails details) {
    _rippleController.reverse();
  }

  void _handleTapCancel() {
    _rippleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: CustomPaint(
        painter: _RipplePainter(
          position: _tapPosition,
          progress: _rippleController.value,
          maxRadius: _maxRadius,
          color: Theme.of(context).primaryColor.withOpacity(0.1),
        ),
        child: widget.child,
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final Offset position;
  final double progress;
  final double maxRadius;
  final Color color;

  _RipplePainter({
    required this.position,
    required this.progress,
    required this.maxRadius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = color.withOpacity(
        (1 - progress) * (1 - progress), // quadratic decay
      )
      ..style = PaintingStyle.fill;

    final double radius =
        maxRadius * (sin(progress * pi / 2) * 1.2).clamp(0.0, 1.0);

    canvas.drawCircle(position, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.position != position;
  }
}
