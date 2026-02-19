import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class AppPhysics {
  // Spring simulation for natural motion
  static const SpringDescription gentleSpring = SpringDescription(
    mass: 1.0,
    stiffness: 170.0,
    damping: 12.0,
  );

  static const SpringDescription bouncySpring = SpringDescription(
    mass: 1.0,
    stiffness: 200.0,
    damping: 8.0,
  );

  // Custom parametric curves
  static const Cubic easeInOutBack = Cubic(0.68, -0.55, 0.265, 1.55);
  static const Cubic easeOutElastic = Cubic(
    0.25,
    0.1,
    0.25,
    1.5,
  ); // approximate
}

// Helper to convert spring description to simulation
SpringSimulation createSpringSimulation({
  required SpringDescription spring,
  required double start,
  required double end,
  double velocity = 0.0,
}) {
  return SpringSimulation(spring, start, end, velocity);
}
