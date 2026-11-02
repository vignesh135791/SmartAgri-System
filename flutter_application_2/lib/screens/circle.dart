import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CircularGauge extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  final Color color;
  final double percent;

  const CircularGauge({
    super.key,
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 45,
            lineWidth: 10,
            percent: percent,
            progressColor: color,
            backgroundColor: color.withOpacity(0.2),
            circularStrokeCap: CircularStrokeCap.round,
            center: Text(
              value,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          Text(unit, style: const TextStyle(fontSize: 14)),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}