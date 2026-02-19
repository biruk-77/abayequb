import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/theme/app_theme.dart';

class GlassBalanceCard extends StatefulWidget {
  final double available;
  final double locked;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  const GlassBalanceCard({
    super.key,
    required this.available,
    required this.locked,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  @override
  State<GlassBalanceCard> createState() => _GlassBalanceCardState();
}

class _GlassBalanceCardState extends State<GlassBalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _shineAnimation = Tween<double>(
      begin: -2.5,
      end: 2.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double totalBalance = widget.available + widget.locked;

    return Container(
      width: double.infinity,
      height: 340, // Increased height for better content fit
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Stack(
          children: [
            // 1. Base Gradient Layer
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A), // Deep Slate
                    Color(0xFF1E293B), // Slate 800
                    Color(0xFF0F5156), // Deep Emerald/Teal hint
                  ],
                ),
              ),
            ),

            // 2. Dynamic Glow Orbs
            _buildAnimatedOrb(
              top: -60,
              right: -60,
              color: const Color(0xFF6366F1).withOpacity(0.5), // Indigo
              size: 240,
            ),
            _buildAnimatedOrb(
              bottom: -80,
              left: -40,
              color: AppTheme.primaryColor.withOpacity(0.45), // Emerald
              size: 280,
            ),
            _buildAnimatedOrb(
              top: 50,
              left: 80,
              color: const Color(0xFFF59E0B).withOpacity(0.2), // Amber
              size: 140,
            ),

            // 3. Glass Content Layer
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 24, // Slightly more vertical padding
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1.5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.02),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Distribute space evenly
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildIconBadge(
                              Icons.account_balance_wallet_rounded,
                              const Color(0xFFFCD34D),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ABAY WALLET',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.5,
                                  ),
                                ),
                                Text(
                                  'Secure Digital Assets',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        _buildVisibilityToggle(),
                      ],
                    ),

                    // --- Main Balance Section ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'TOTAL PORTFOLIO',
                              style: GoogleFonts.outfit(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.trending_up,
                              color: const Color(0xFF34D399).withOpacity(0.6),
                              size: 14,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.isVisible
                                  ? CurrencyFormatter.format(totalBalance)
                                  : '••••••••',
                              key: ValueKey(widget.isVisible),
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 36, // Slightly larger font
                                fontWeight: FontWeight.w900,
                                letterSpacing: widget.isVisible ? -1.0 : 4.0,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // --- Multi-Balance Grid ---
                    Row(
                      children: [
                        Expanded(
                          child: _buildHighContrastBalance(
                            'AVAILABLE',
                            widget.available,
                            const Color(0xFF34D399), // Emerald
                            Icons.account_balance_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildHighContrastBalance(
                            'LOCKED',
                            widget.locked,
                            const Color(0xFFFBBF24), // Amber
                            Icons.lock_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 4. Premium Shine Effect
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _shineAnimation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    widthFactor: 0.5,
                    heightFactor: 3.0,
                    alignment: Alignment(_shineAnimation.value, 0),
                    child: Transform.rotate(
                      angle: 0.6,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.0),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBadge(IconData icon, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Center(child: Icon(icon, color: color, size: 24)),
    );
  }

  Widget _buildVisibilityToggle() {
    return InkWell(
      onTap: widget.onToggleVisibility,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Icon(
          widget.isVisible
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildHighContrastBalance(
    String label,
    double amount,
    Color accent,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 14),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.isVisible ? CurrencyFormatter.format(amount) : '••••',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20, // Significantly larger
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedOrb({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
    required double size,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withOpacity(0)],
            stops: const [0.2, 1.0],
          ),
        ),
      ),
    );
  }
}
