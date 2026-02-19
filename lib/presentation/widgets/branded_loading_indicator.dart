import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class BrandedLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const BrandedLoadingIndicator({
    super.key,
    this.size = 50,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? Theme.of(context).colorScheme.secondary;
    
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulsing ring
          Pulse(
            infinite: true,
            child: Container(
              width: size * 1.2,
              height: size * 1.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: activeColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
            ),
          ),
          // Spinning indicator
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(activeColor),
            ),
          ),
          // Inner pulsing logo/dot
          ZoomIn(
            duration: const Duration(seconds: 1),
            child: Container(
              width: size * 0.4,
              height: size * 0.4,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withOpacity(0.5),
                    blurRadius: 10,
                  )
                ]
              ),
            ),
          ),
        ],
      ),
    );
  }
}
