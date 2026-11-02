import 'package:flutter/material.dart';
import 'circle.dart';
import '../services/websocket_service.dart';
import '../models/sensor_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WebSocketService _webSocketService = WebSocketService();
  SensorData? sensorData;

  static const double soilThreshold = 75.0;
  bool showAlert = false;
  DateTime? alertStartTime;

  @override
  void initState() {
    super.initState();

    _webSocketService.rawStream.listen((message) {
      final data = _webSocketService.parseSensor(message);
    if (data == null) return;
      final now = DateTime.now();

      setState(() {
        sensorData = data;
        if (data.soilPercent > soilThreshold) {
          if (!showAlert) {
            showAlert = true;
            alertStartTime = now;
          }
        }

        if (showAlert && alertStartTime != null) {
          final elapsed = now.difference(alertStartTime!);
          if (elapsed.inMinutes >= 2) {
            showAlert = false;
            alertStartTime = null;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (sensorData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF1E4F9B),
            padding: const EdgeInsets.only(top: 40, bottom: 16, left: 16),
            child: const Text(
              "SmartAgri",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CircularGauge(
                          value: sensorData!.light.toStringAsFixed(0),
                          unit: "LUX",
                          label: "Light intensity",
                          color: Colors.yellowAccent,
                          percent: (sensorData!.light / 100).clamp(0.0, 1.0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CircularGauge(
                          value: sensorData!.humidity.toStringAsFixed(0),
                          unit: "%",
                          label: "Humidity",
                          color: Colors.blue,
                          percent: (sensorData!.humidity / 100).clamp(0.0, 1.0),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: CircularGauge(
                          value: sensorData!.soilPercent.toStringAsFixed(0),
                          unit: "%",
                          label: "Soil Moisture",
                          color: Colors.orange,
                          percent: (sensorData!.soilPercent / 100),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CircularGauge(
                          value: sensorData!.temperature.toStringAsFixed(0),
                          unit: "°C",
                          label: "Temperature",
                          color: Colors.red,
                          percent: (sensorData!.temperature / 100).clamp(0.0, 1.0),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (showAlert)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1A7A5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ALERT:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Soil moisture is high (${sensorData!.soilPercent.toStringAsFixed(1)}%). "
                            "No watering required at this time.",
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2CC65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "SUGGESTION\nBarley crop will be suitable for upcoming weather",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
