import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../../core/theme/physics.dart';

class HighEndActiveTab extends StatefulWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const HighEndActiveTab({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  State<HighEndActiveTab> createState() => _HighEndActiveTabState();
}

class _HighEndActiveTabState extends State<HighEndActiveTab>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  double _targetPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _positionAnimation = _controller.drive(Tween<double>(begin: 0.0, end: 0.0));
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _jumpToIndex(widget.selectedIndex),
    );
  }

  @override
  void didUpdateWidget(covariant HighEndActiveTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _animateToIndex(widget.selectedIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _jumpToIndex(int index) {
    if (!mounted) return;
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final double tabWidth = box.size.width / widget.tabs.length;
    _targetPosition = index * tabWidth;
    _controller.value = 1.0;
    _positionAnimation = _controller.drive(
      Tween<double>(begin: _targetPosition, end: _targetPosition),
    );
  }

  void _animateToIndex(int index) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final double tabWidth = box.size.width / widget.tabs.length;
    final double newPosition = index * tabWidth;

    final simulation = SpringSimulation(
      AppPhysics.gentleSpring,
      _targetPosition,
      newPosition,
      0,
    );
    _targetPosition = newPosition;
    _positionAnimation = _controller.drive(
      Tween<double>(begin: _positionAnimation.value, end: newPosition),
    );
    _controller.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double tabWidth = constraints.maxWidth / widget.tabs.length;

        return Stack(
          children: [
            Row(
              children: List.generate(widget.tabs.length, (index) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onTabSelected(index),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      child: Text(
                        widget.tabs[index],
                        style: TextStyle(
                          color: widget.selectedIndex == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              width: tabWidth,
              child: AnimatedBuilder(
                animation: _positionAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_positionAnimation.value, 0),
                    child: Center(
                      child: Container(
                        height: 3,
                        width: tabWidth * 0.6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
