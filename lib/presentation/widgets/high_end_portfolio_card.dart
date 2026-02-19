import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../../core/theme/physics.dart';
import '../../core/theme/app_theme.dart';

class HighEndPortfolioCard extends StatefulWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const HighEndPortfolioCard({
    super.key,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  State<HighEndPortfolioCard> createState() => _HighEndPortfolioCardState();
}

class _HighEndPortfolioCardState extends State<HighEndPortfolioCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<double>? _animationX, _animationY;

  double _dragX = 0.0, _dragY = 0.0;
  final double _maxAngle = 0.2; // radians (~11.5°)

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    _controller.stop();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset local = box.globalToLocal(details.globalPosition);
    final Size size = box.size;

    // Calculate offset from center, normalized to [-1, 1]
    final double dx = (local.dx - size.width / 2) / (size.width / 2);
    final double dy = (local.dy - size.height / 2) / (size.height / 2);

    // Clamp to avoid extreme angles
    _dragX = dx.clamp(-1.0, 1.0) * _maxAngle;
    _dragY = dy.clamp(-1.0, 1.0) * _maxAngle;

    setState(() {});
  }

  void _handlePanEnd(DragEndDetails details) {
    final double velocityX = details.velocity.pixelsPerSecond.dx / 500;

    _animationX = _controller.drive(Tween<double>(begin: _dragX, end: 0.0));
    _animationY = _controller.drive(Tween<double>(begin: _dragY, end: 0.0));

    final simulationX = SpringSimulation(
      AppPhysics.gentleSpring,
      _dragX,
      0.0,
      velocityX,
    );
    _controller.animateWith(simulationX);
  }

  @override
  Widget build(BuildContext context) {
    final double rotateX = _animationX?.value ?? _dragX;
    final double rotateY = _animationY?.value ?? _dragY;

    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTap: widget.onTap,
      child: Transform(
        transform: _buildRotationMatrix(rotateX, rotateY),
        alignment: FractionalOffset.center,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: AppTheme.caption),
              const SizedBox(height: 4),
              Text(widget.value, style: AppTheme.headline),
            ],
          ),
        ),
      ),
    );
  }

  Matrix4 _buildRotationMatrix(double rotateX, double rotateY) {
    final matrix = Matrix4.identity();
    matrix.rotateX(-rotateX); // invert to feel natural
    matrix.rotateY(rotateY);
    // Apply a subtle perspective
    matrix.setEntry(3, 2, 0.001);
    return matrix;
  }
}
