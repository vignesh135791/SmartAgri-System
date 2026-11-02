import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/yield_repository.dart';

class YieldComparisonChart extends StatelessWidget {
  const YieldComparisonChart({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<YieldRepository>();
    final records = repo.records;

    final now = DateTime.now();
    final thisYear = now.year;
    final thisYearRecords =
        records.where((r) => r.date.year == thisYear).toList();

    int dayOfYear(DateTime d) {
      final start = DateTime(d.year, 1, 1);
      return d.difference(start).inDays + 1;
    }

    final thisYearSpots = thisYearRecords
        .map((r) => FlSpot(dayOfYear(r.date).toDouble(), r.yieldPerAcre))
        .toList();

    final lastYearSpots = <FlSpot>[
      const FlSpot(1, 100),
      const FlSpot(5, 130),
      const FlSpot(10, 170),
      const FlSpot(15, 160),
      const FlSpot(20, 110),
      const FlSpot(25, 150),
      const FlSpot(31, 200),
      const FlSpot(60, 190),
      const FlSpot(90, 210),
      const FlSpot(120, 180),
      const FlSpot(150, 220),
      const FlSpot(180, 200),
      const FlSpot(210, 230),
      const FlSpot(240, 210),
      const FlSpot(270, 240),
      const FlSpot(300, 220),
      const FlSpot(330, 250),
      const FlSpot(365, 240),
    ];

    if (thisYearSpots.isEmpty && lastYearSpots.isEmpty) {
      return const Center(child: Text("No yield data yet"));
    }

    final allY = [...thisYearSpots, ...lastYearSpots].map((e) => e.y);
    final minY = allY.reduce((a, b) => a < b ? a : b) * 0.9;
    final maxY = allY.reduce((a, b) => a > b ? a : b) * 1.1;

    final minX = 1.0;
    final maxX = 366.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Yield Comparison (This Year vs Last Year)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Text(
            "Current data vs baseline historical data",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 260,
            child: LineChart(
              LineChartData(
                minX: minX,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),

                titlesData: FlTitlesData(
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 60,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final date = DateTime(thisYear)
                            .add(Duration(days: value.toInt() - 1));
                        return Text(
                          DateFormat('MMM').format(date),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (maxY - minY) / 4,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: thisYearSpots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),

                  LineChartBarData(
                    spots: lastYearSpots,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                Icon(Icons.circle, size: 12, color: Colors.blue),
                SizedBox(width: 6),
                Text("This Year (Current Month)"),
                SizedBox(width: 20),
                Icon(Icons.circle, size: 12, color: Colors.green),
                SizedBox(width: 6),
                Text("Last Year (Full Year)"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
