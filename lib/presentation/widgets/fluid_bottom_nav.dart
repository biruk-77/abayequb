import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────

class NavBarItem {
  final IconData icon;
  final String label;
  final bool hasNotification;
  final int notificationCount;

  NavBarItem({
    required this.icon,
    required this.label,
    this.hasNotification = false,
    this.notificationCount = 0,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN WIDGET: THE OBSIDIAN BAR (Professional & Premium)
// ─────────────────────────────────────────────────────────────────────────────

class FuturisticNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<NavBarItem> items;

  const FuturisticNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  State<FuturisticNavBar> createState() => _FuturisticNavBarState();
}

class _FuturisticNavBarState extends State<FuturisticNavBar>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _anim; // Runs from 0.0 to (items.length - 1).0
  int _prevIndex = 0;

  @override
  void initState() {
    super.initState();
    _prevIndex = widget.selectedIndex;
    _ensureAnimations();
  }

  void _ensureAnimations() {
    if (_controller != null) return;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Slower, heavier feel
    );

    // We animate the VALUE directly (index), not just 0->1
    _anim =
        Tween<double>(
          begin: widget.selectedIndex.toDouble(),
          end: widget.selectedIndex.toDouble(),
        ).animate(
          CurvedAnimation(
            parent: _controller!,
            curve: Curves.fastLinearToSlowEaseIn, // "Expensive" mechanical feel
          ),
        );
  }

  void _updateAnimationTarget() {
    _ensureAnimations();
    // Create a new tween to animate from current value to new target
    _anim =
        Tween<double>(
          begin: _anim?.value ?? _prevIndex.toDouble(),
          end: widget.selectedIndex.toDouble(),
        ).animate(
          CurvedAnimation(
            parent: _controller!,
            curve: Curves.fastLinearToSlowEaseIn,
          ),
        );

    _controller!.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(FuturisticNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _prevIndex = oldWidget.selectedIndex;
      _updateAnimationTarget();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (index == widget.selectedIndex) return;
    HapticFeedback.lightImpact(); // Subtle click
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    _ensureAnimations();

    // Compact height
    const double height = 72.0;
    const Color activeColor = Colors.white;
    const Color inactiveColor = Color(
      0xFFAABBCB,
    ); // Lighter blue-gray for better contrast on dark teal

    return RepaintBoundary(
      child: Container(
        height: height,
        // Floating but low and wide
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(
            0xFF0D4348,
          ).withOpacity(0.98), // Deep Teal from theme
          borderRadius: BorderRadius.circular(32), // Fully rounded ends
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32), // Match decoration
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Stack(
              children: [
                // ─────────────────────────────────────────────────────────────────
                // 1. THE FLOATING HIGHLIGHT (Backlight)
                // ─────────────────────────────────────────────────────────────────
                AnimatedBuilder(
                  animation: _anim!,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: _ObsidianHighlightPainter(
                        animationValue: _anim!.value,
                        count: widget.items.length,
                        color: activeColor,
                      ),
                    );
                  },
                ),

                // ─────────────────────────────────────────────────────────────────
                // 2. ICONS & LABELS
                // ─────────────────────────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(widget.items.length, (index) {
                    final item = widget.items[index];
                    final bool isSelected = index == widget.selectedIndex;

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _handleTap(index),
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic, // Smooth entry
                          tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
                          builder: (context, t, child) {
                            return Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                // Icon: Moves up slightly and turns white
                                Transform.translate(
                                  offset: Offset(0, -10.0 * t),
                                  child: Icon(
                                    item.icon,
                                    // Interpolate color smoothly
                                    color: Color.lerp(
                                      inactiveColor,
                                      activeColor,
                                      t,
                                    ),
                                    size: 24, // Standard, professional size
                                  ),
                                ),

                                // Text: Always visible, different style for active/inactive
                                Positioned(
                                  bottom:
                                      12 + (2.0 * t), // Slight lift when active
                                  child: Text(
                                    item.label,
                                    style: TextStyle(
                                      color: Color.lerp(
                                        inactiveColor.withOpacity(0.7),
                                        activeColor,
                                        t,
                                      ),
                                      fontSize:
                                          10 + (1.0 * t), // Swells slightly
                                      fontWeight: t > 0.5
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      letterSpacing: 0.2 + (0.3 * t),
                                      shadows: [
                                        if (t > 0.1)
                                          Shadow(
                                            color: activeColor.withOpacity(
                                              0.3 * t,
                                            ),
                                            blurRadius: 8 * t,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Notification Badge: Minimal red dot
                                if (item.hasNotification)
                                  Positioned(
                                    top: 18,
                                    right: 24,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFFF3B30,
                                        ), // System Red
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF0D4348),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAINTER: THE OBSIDIAN BACKLIGHT
// ─────────────────────────────────────────────────────────────────────────────
class _ObsidianHighlightPainter extends CustomPainter {
  final double animationValue;
  final int count;
  final Color color;

  _ObsidianHighlightPainter({
    required this.animationValue,
    required this.count,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (count == 0) return;

    final double itemWidth = size.width / count;
    final double h = size.height;

    // Calculate precise center based on animation value
    final double centerX = (animationValue * itemWidth) + (itemWidth / 2);
    final double centerY = h / 2;

    // 1. The "Spotlight" Gradient (Vertical Beam)
    // A very subtle beam of light that highlights the active column
    final Rect bgRect = Rect.fromLTWH(0, 0, size.width, h);

    // Mask the beam to the current position
    final Paint beamPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          ((centerX / size.width) * 2) - 1,
          -0.6,
        ), // Top-center of item
        radius: 0.5,
        colors: [color.withOpacity(0.15), color.withOpacity(0.0)],
        stops: const [0.0, 1.0],
      ).createShader(bgRect);

    canvas.drawRect(bgRect, beamPaint);

    // 2. The Active Indicator (Refined Pill)
    // A small, glowing pill behind the icon

    final RRect pillRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(
          centerX,
          centerY - 8,
        ), // Centered behind the icon's lifted position
        width: 48,
        height: 48,
      ),
      const Radius.circular(16),
    );

    canvas.drawRRect(
      pillRect,
      Paint()
        ..color = color
            .withOpacity(0.08) // Very faint glass background
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          10,
        ), // Soft edges
    );

    // 3. The Active "Dash" at the bottom
    // Minimalist line indicating selection
    final RRect dashRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, h - 2), // Stuck to bottom
        width: 16,
        height: 3,
      ),
      const Radius.circular(1.5),
    );

    canvas.drawRRect(dashRect, Paint()..color = color.withOpacity(0.8));
  }

  @override
  bool shouldRepaint(covariant _ObsidianHighlightPainter old) {
    return old.animationValue != animationValue;
  }
}
