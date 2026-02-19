import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../../data/models/equb_group_model.dart';
import '../../../core/utils/currency_formatter.dart';

class PremiumGroupCard extends StatefulWidget {
  final EqubGroupModel group;
  final double contributionAmount;
  final int currentCycle;
  final int totalCycles;
  final int? payoutOrder;
  final VoidCallback onTap;

  const PremiumGroupCard({
    super.key,
    required this.group,
    required this.contributionAmount,
    required this.currentCycle,
    this.totalCycles = 12,
    this.payoutOrder,
    required this.onTap,
  });

  @override
  State<PremiumGroupCard> createState() => _PremiumGroupCardState();
}

class _PremiumGroupCardState extends State<PremiumGroupCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Get a unique color scheme for each card based on its name
  _CardTheme _getTheme() {
    final name = widget.group.name ?? '';
    if (name.contains('Gold') || name.contains('Diamond')) {
      return _CardTheme(
        colors: [
          const Color(0xFFB45309),
          const Color(0xFFF59E0B),
        ], // Amber/Gold
        icon: Icons.auto_awesome,
      );
    } else if (name.contains('Silver') || name.contains('Starter')) {
      return _CardTheme(
        colors: [const Color(0xFF334155), const Color(0xFF64748B)], // Slate
        icon: Icons.rocket_launch_rounded,
      );
    } else if (name.contains('Business') || name.contains('Pro')) {
      return _CardTheme(
        colors: [const Color(0xFF4F46E5), const Color(0xFF818CF8)], // Indigo
        icon: Icons.business_center_rounded,
      );
    }
    // Default: Emerald/Teal
    return _CardTheme(
      colors: [const Color(0xFF059669), const Color(0xFF10B981)],
      icon: Icons.account_balance_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getTheme();
    final double progress = (widget.currentCycle / widget.totalCycles).clamp(
      0.0,
      1.0,
    );
    final bool isCompleted = widget.group.status?.toLowerCase() == 'completed';

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 280,
          height: 200,
          margin: const EdgeInsets.only(right: 16),
          child: Stack(
            children: [
              // 1. Background Gradient Container
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: theme.colors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colors[0].withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),

              // 2. Decorative Patterns (The "Card" look)
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  theme.icon,
                  size: 140,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),

              // 3. Glass Overlay for content
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.0,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Group Name + R-Number
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.group.name?.toUpperCase() ??
                                    'EQUB GROUP',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.payoutOrder != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'PO-${widget.payoutOrder}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),

                        // Middle: Amount
                        Text(
                          'Contribution',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.format(widget.contributionAmount),
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const Spacer(),

                        // Bottom: Progress
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'CYCLE ${widget.currentCycle}/${widget.totalCycles}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.8),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Stack(
                              children: [
                                Container(
                                  height: 4,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.easeOutCubic,
                                  height: 4,
                                  width: 240 * progress,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.5),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Status Badge (top floating)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.grey.shade800
                        : Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isCompleted ? 'COMPLETED' : 'ACTIVE',
                    style: GoogleFonts.outfit(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardTheme {
  final List<Color> colors;
  final IconData icon;

  _CardTheme({required this.colors, required this.icon});
}
