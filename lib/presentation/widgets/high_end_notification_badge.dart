import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../../core/theme/physics.dart';
import '../../core/theme/app_theme.dart';

class HighEndNotificationBadge extends StatefulWidget {
  final int count;
  final Widget child;
  final SpringDescription? spring;

  const HighEndNotificationBadge({
    super.key,
    required this.count,
    required this.child,
    this.spring,
  });

  @override
  State<HighEndNotificationBadge> createState() =>
      _HighEndNotificationBadgeState();
}

class _HighEndNotificationBadgeState extends State<HighEndNotificationBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _scaleAnimation = _controller.drive(Tween<double>(begin: 1.0, end: 1.0));
  }

  @override
  void didUpdateWidget(covariant HighEndNotificationBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count && widget.count > 0) {
      _animateBounce();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateBounce() {
    final spring = widget.spring ?? AppPhysics.bouncySpring;
    final simulation = SpringSimulation(spring, 1.0, 1.2, 0.0);
    _scaleAnimation = _controller.drive(Tween<double>(begin: 1.0, end: 1.2));
    _controller.animateWith(simulation).whenComplete(() {
      if (!mounted) return;
      final returnSim = SpringSimulation(spring, 1.2, 1.0, 0.0);
      _scaleAnimation = _controller.drive(Tween<double>(begin: 1.2, end: 1.0));
      _controller.animateWith(returnSim);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (widget.count > 0)
          Positioned(
            top: -2,
            right: -2,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, _) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.notificationRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      widget.count > 9 ? '9+' : widget.count.toString(),
                      style: AppTheme.caption.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
