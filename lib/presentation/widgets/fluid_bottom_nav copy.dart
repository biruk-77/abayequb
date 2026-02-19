import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

// --- DATA MODEL ---
class NavBarItem {
  final IconData icon;
  final String label;
  final bool hasNotification;

  NavBarItem({
    required this.icon,
    required this.label,
    this.hasNotification = false,
  });
}

// --- THEME SYSTEM ---
class FuturisticTheme {
  final LinearGradient glowGradient;
  final Color accentColor;
  final Color baseColor;
  final Color secondaryAccent;

  FuturisticTheme({
    required this.glowGradient,
    required this.accentColor,
    required this.baseColor,
    required this.secondaryAccent,
  });

  factory FuturisticTheme.cyberpunk() {
    return FuturisticTheme(
      glowGradient: const LinearGradient(
        colors: [Color(0xFF42E8E0), Color(0xFF7B26F7), Color(0xFF5C57F0)],
        stops: [0.1, 0.5, 0.9],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentColor: const Color(0xFF42E8E0),
      secondaryAccent: const Color(0xFF7B26F7),
      baseColor: const Color(0xFF0A0A12),
    );
  }
}

// --- THE MASTERPIECE NAV BAR ---
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
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _xProgress;

  late AnimationController _pulseController;
  late Ticker _globalTicker;

  double _idleTime = 0.0;
  final FuturisticTheme _theme = FuturisticTheme.cyberpunk();

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _xProgress =
        Tween<double>(
          begin: widget.selectedIndex.toDouble(),
          end: widget.selectedIndex.toDouble(),
        ).animate(
          CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
        );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _globalTicker = createTicker((elapsed) {
      if (mounted) {
        setState(() {
          _idleTime = elapsed.inMicroseconds / 1000000.0;
        });
      }
    });
    _globalTicker.start();
  }

  @override
  void didUpdateWidget(FuturisticNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _xProgress =
          Tween<double>(
            begin: _xProgress.value,
            end: widget.selectedIndex.toDouble(),
          ).animate(
            CurvedAnimation(
              parent: _mainController,
              curve: const ElasticOutCurve(0.7),
            ),
          );
      _mainController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _globalTicker.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (index == widget.selectedIndex) return;
    HapticFeedback.mediumImpact();
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    const double barHeight = 70.0;
    final double barWidth = MediaQuery.of(context).size.width - 40;

    return Container(
      height: barHeight + 40,
      width: barWidth,
      alignment: Alignment.bottomCenter,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // LAYER 0: The Quantum Glass Pod
          CustomPaint(
            size: Size(barWidth, barHeight),
            painter: QuantumNeuromorphicPainter(
              progress: _xProgress.value,
              totalItems: widget.items.length,
              idleTime: _idleTime,
              theme: _theme,
            ),
          ),

          // LAYER 1: Interactive Icons
          SizedBox(
            height: barHeight,
            width: barWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: widget.items.asMap().entries.map((entry) {
                final int i = entry.key;
                final bool isActive = i == widget.selectedIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _handleTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: _QuantumIcon(
                      item: entry.value,
                      isActive: isActive,
                      theme: _theme,
                      idleTime: _idleTime,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantumIcon extends StatelessWidget {
  final NavBarItem item;
  final bool isActive;
  final FuturisticTheme theme;
  final double idleTime;

  const _QuantumIcon({
    required this.item,
    required this.isActive,
    required this.theme,
    required this.idleTime,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: isActive ? 1.0 : 0.0),
      curve: Curves.elasticOut,
      builder: (context, val, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (isActive)
                  Transform.scale(
                    scale: 1.2 + (math.sin(idleTime * 5) * 0.1),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.accentColor.withOpacity(0.4 * val),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                Icon(
                  item.icon,
                  size: 24 + (6 * val),
                  color: Color.lerp(
                    Colors.white.withOpacity(0.35),
                    Colors.white,
                    val,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Neon status dot
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: val,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: theme.accentColor, blurRadius: 4),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class QuantumNeuromorphicPainter extends CustomPainter {
  final double progress;
  final int totalItems;
  final double idleTime;
  final FuturisticTheme theme;

  QuantumNeuromorphicPainter({
    required this.progress,
    required this.totalItems,
    required this.idleTime,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double itemWidth = w / totalItems;
    final double activeX = (progress + 0.5) * itemWidth;

    // 0. INITIAL TRANSFORMATION (Lateral Stretch/Inertia)
    final double tLin = progress - progress.floor();
    final double wring = (1.0 - (2.0 * (0.5 - tLin).abs())).clamp(0.0, 1.0);
    final double stretchX = 1.0 + (wring * 0.04);
    final double skewX = (progress - progress.roundToDouble()) * -0.05 * wring;

    canvas.save();
    canvas.translate(w / 2, h / 2);
    canvas.scale(stretchX, 1.0);
    // Skew based on travel direction
    final Matrix4 transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateY(skewX);
    canvas.transform(transform.storage);
    canvas.translate(-w / 2, -h / 2);

    // 1. AURA GLOW (Dynamic environment light)
    canvas.save();
    canvas.translate(activeX, h / 2);
    canvas.drawCircle(
      Offset.zero,
      65,
      Paint()
        ..shader = RadialGradient(
          colors: [theme.accentColor.withOpacity(0.12), Colors.transparent],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: 65))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35),
    );
    canvas.restore();

    // 2. MAGNETIC DEFORMATION LOGIC
    final double stretchPower = math.pow(wring, 0.8).toDouble();

    double edgeOffset(double x, double edgeSign) {
      final double dist = (x - activeX).abs() / (itemWidth * 1.5);
      final double proximity = math
          .pow(1.0 - dist.clamp(0.0, 1.0), 3.0)
          .toDouble();

      // Pull deformation: Edge pulls towards indicator
      final double pull = proximity * (8.0 + stretchPower * 12.0) * edgeSign;
      // Latent wobble: Box feels alive
      final double wobble = math.sin(idleTime * 2 + x * 0.05) * 1.5;

      return pull + wobble;
    }

    final path = Path();
    const double r = 24.0;
    const int segments = 80;

    // Build the dynamic "Magnetic Pod" path
    path.moveTo(r, 0 + edgeOffset(r, 1.0));
    for (int i = 1; i <= segments; i++) {
      double x = r + (w - 2 * r) * (i / segments);
      path.lineTo(x, 0 + edgeOffset(x, 1.0));
    }

    path.arcToPoint(
      Offset(w, r + edgeOffset(w, 1.0)),
      radius: const Radius.circular(r),
      clockwise: true,
    );
    path.lineTo(w, h - r + edgeOffset(w, -1.0));
    path.arcToPoint(
      Offset(w - r, h + edgeOffset(w - r, -1.0)),
      radius: const Radius.circular(r),
      clockwise: true,
    );

    for (int i = segments; i >= 0; i--) {
      double x = r + (w - 2 * r) * (i / segments);
      path.lineTo(x, h + edgeOffset(x, -1.0));
    }

    path.arcToPoint(
      Offset(0, h - r + edgeOffset(0, -1.0)),
      radius: const Radius.circular(r),
      clockwise: true,
    );
    path.lineTo(0, r + edgeOffset(0, 1.0));
    path.arcToPoint(
      Offset(r, 0 + edgeOffset(r, 1.0)),
      radius: const Radius.circular(r),
      clockwise: true,
    );
    path.close();

    // 2. DEEP GLASS BASE
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [
            theme.baseColor.withOpacity(0.96),
            const Color(0xFF101020).withOpacity(0.9),
            theme.baseColor.withOpacity(0.96),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(path.getBounds()),
    );

    // 3. NEON SCANNING BORDER (Animated sweeping light)
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = SweepGradient(
          center: Alignment(((activeX / w) * 2) - 1.0, 0.0),
          colors: [
            Colors.white.withOpacity(0.02),
            theme.accentColor.withOpacity(0.4),
            theme.secondaryAccent,
            theme.accentColor.withOpacity(0.4),
            Colors.white.withOpacity(0.02),
          ],
          stops: const [0.0, 0.45, 0.5, 0.55, 1.0],
          transform: GradientRotation(idleTime * 0.4),
        ).createShader(path.getBounds()),
    );

    // 4. QUANTUM "GHOST" TRAILS (Chromatic Aberration)
    _drawQuantumGhosts(canvas, activeX, h, theme, idleTime);

    // 5. THE ACTIVE NUCLEUS (Indicator core)
    final nucleusRect = Rect.fromCenter(
      center: Offset(activeX, h / 2),
      width: 55,
      height: 48,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(nucleusRect, const Radius.circular(18)),
      Paint()
        ..shader = RadialGradient(
          colors: [
            theme.accentColor.withOpacity(0.18),
            theme.secondaryAccent.withOpacity(0.05),
            Colors.transparent,
          ],
        ).createShader(nucleusRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // TOP REFLECTION (Hardware polished look)
    final reflectionPath = Path();
    reflectionPath.addRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(r, 4, w - 2 * r, 12),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      ),
    );
    canvas.drawPath(
      reflectionPath,
      Paint()..color = Colors.white.withOpacity(0.05),
    );

    canvas.restore(); // Restore initial transform
  }

  void _drawQuantumGhosts(
    Canvas canvas,
    double x,
    double h,
    FuturisticTheme theme,
    double time,
  ) {
    final ghostSize = const Size(45, 40);
    final paint = Paint()..blendMode = BlendMode.screen;

    // Cyan Ghost (Lagging slightly)
    final cyanPos = x + math.sin(time * 8) * 2.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cyanPos - 4, h / 2),
          width: ghostSize.width,
          height: ghostSize.height,
        ),
        const Radius.circular(14),
      ),
      paint
        ..color = const Color(0xFF00FFFF).withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Magenta Ghost (Leading slightly)
    final magentaPos = x + math.cos(time * 8) * 2.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(magentaPos + 4, h / 2),
          width: ghostSize.width,
          height: ghostSize.height,
        ),
        const Radius.circular(14),
      ),
      paint
        ..color = const Color(0xFFFF00FF).withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
