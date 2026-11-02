import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/sensor_data.dart';
import 'cw.dart';
import '../widgets/recommendation_card.dart';

class ProductivityScreen extends StatelessWidget {
  const ProductivityScreen({super.key});

  LineChartBarData _line(List<FlSpot> data, Color color) {
    return LineChartBarData(
      spots: data,
      isCurved: true,
      barWidth: 2,
      color: color,
      dotData: FlDotData(show: false),
    );
  }

  Widget _liveGraphCard(DataProvider provider) {
    if (provider.lightHistory.isEmpty) {
       return const Center(child: Text("Waiting for sensor data..."));
    }

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
            "Live Sensor Graph",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                minX: provider.maxX > 50 ? provider.maxX - 50 : 0,
                maxX: provider.maxX,
                lineBarsData: [
                  _line(provider.lightHistory, Colors.blue),
                  _line(provider.humidityHistory, Colors.green),
                  _line(provider.soilHistory, Colors.brown),
                  _line(provider.tempHistory, Colors.red),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cropSuggestionCard(CropPrediction? data) {
    if (data == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🌱 AI Crop Suggestions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 8),
          Text(
            "Recommended: ${data.suitableCrops.join(", ")}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            "Confidence: ${(data.confidence * 100).toStringAsFixed(1)}%",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          const Text(
            "Forecast (Next 2 Months):",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              headingRowHeight: 40,
              dataRowHeight: 50,
              columns: const [
                DataColumn(label: Text("Month")),
                DataColumn(label: Text("Crop")),
                DataColumn(label: Text("Yield")),
                DataColumn(label: Text("Weather")),
              ],
              rows: data.forecast.map((f) {
                return DataRow(cells: [
                  DataCell(Text(f.month)),
                  DataCell(Text(f.predictedCrop)),
                  DataCell(Text(f.expectedYield)),
                  DataCell(Text(f.weatherSummary)),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DataProvider>(
        builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: const Color(0xFF1E4F9B),
                padding: const EdgeInsets.only(
                  top: 40,
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                width: double.infinity,
                child: const Text(
                  "Productivity and Rainfall",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),

              Expanded(
                child: SafeArea(
                  top: false,
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      const YieldComparisonChart(),
                      const SizedBox(height: 20),
                      
                      _liveGraphCard(provider),
                      const SizedBox(height: 20),

                      const RecommendationCard(),
                      const SizedBox(height: 20),

                      if (provider.sensorData?.cropPrediction != null)
                        _cropSuggestionCard(provider.sensorData!.cropPrediction!),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Monthly Rainfall Chart",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                "assets/images/chart2.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
