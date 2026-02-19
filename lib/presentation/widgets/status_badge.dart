import 'package:flutter/material.dart';

enum StatusType { paid, due, late, locked }

class StatusBadge extends StatelessWidget {
  final StatusType status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case StatusType.paid:
        color = Colors.green;
        label = 'PAID';
        break;
      case StatusType.due:
        color = Colors.orange;
        label = 'DUE';
        break;
      case StatusType.late:
        color = Colors.red;
        label = 'LATE';
        break;
      case StatusType.locked:
        color = Colors.grey;
        label = 'LOCKED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
