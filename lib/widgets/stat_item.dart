import 'package:flutter/material.dart';

class StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const StatItem({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white24,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
