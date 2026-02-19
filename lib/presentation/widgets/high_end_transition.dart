import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;
import '../../core/theme/physics.dart';

enum TransitionType { fade, scale, slide, morph }

class HighEndTransition extends StatefulWidget {
  final bool visible;
  final Widget child;
  final TransitionType type;
  final Curve curve;
  final Duration duration;

  const HighEndTransition({
    super.key,
    required this.visible,
    required this.child,
    this.type = TransitionType.fade,
    this.curve = AppPhysics.easeInOutBack,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<HighEndTransition> createState() => _HighEndTransitionState();
}

class _HighEndTransitionState extends State<HighEndTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    if (widget.visible) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant HighEndTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible != widget.visible) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        Widget transformed = child!;
        switch (widget.type) {
          case TransitionType.fade:
            transformed = Opacity(opacity: _animation.value, child: child);
            break;
          case TransitionType.scale:
            transformed = Transform.scale(
              scale: _animation.value,
              child: child,
            );
            break;
          case TransitionType.slide:
            transformed = Transform.translate(
              offset: Offset(0, lerpDouble(50, 0, _animation.value)!),
              child: child,
            );
            break;
          case TransitionType.morph:
            transformed = Opacity(opacity: _animation.value, child: child);
            break;
        }
        return transformed;
      },
      child: widget.child,
    );
  }
}
