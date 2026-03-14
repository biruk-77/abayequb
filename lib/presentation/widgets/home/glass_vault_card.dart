import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/currency_formatter.dart';

class GlassVaultCard extends StatefulWidget {
  final double available;
  final double locked;

  const GlassVaultCard({
    super.key,
    required this.available,
    required this.locked,
  });

  @override
  State<GlassVaultCard> createState() => _GlassVaultCardState();
}

class _GlassVaultCardState extends State<GlassVaultCard> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24), // Increased top padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF003366).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Color(0xFF003366),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "TOTAL BALANCE",
                    style: GoogleFonts.outfit(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  _isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  color: Colors.grey[400],
                  size: 22,
                ),
                onPressed: () => setState(() => _isVisible = !_isVisible),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _isVisible
                ? "ETB ${CurrencyFormatter.format(widget.available + widget.locked).replaceAll('ETB ', '')}"
                : "••••••••",
            style: GoogleFonts.outfit(
              color: const Color(0xFF003366),
              fontSize: 34, // Slightly smaller
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _BalancePill(
                  label: "Available",
                  amount: widget.available,
                  color: const Color(0xFF22C55E),
                  bgColor: const Color(0xFFECFDF5),
                  isVisible: _isVisible,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _BalancePill(
                  label: "Locked",
                  amount: widget.locked,
                  color: const Color(0xFFE2A014),
                  bgColor: const Color(0xFFFFF7ED),
                  isVisible: _isVisible,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalancePill extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final Color bgColor;
  final bool isVisible;

  const _BalancePill({
    required this.label,
    required this.amount,
    required this.color,
    required this.bgColor,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isVisible 
              ? "ETB ${CurrencyFormatter.formatCompact(amount).replaceAll('ETB ', '')}" 
              : "•••",
            style: GoogleFonts.outfit(
              color: Colors.black.withValues(alpha: 0.8),
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
