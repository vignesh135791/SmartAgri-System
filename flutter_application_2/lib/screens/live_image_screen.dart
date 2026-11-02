import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class LiveImageScreen extends StatelessWidget {
  const LiveImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DataProvider>(
        builder: (context, provider, child) {
          final hasImage = provider.currentImage != null;
          final imageTime = provider.lastImageTime;
          final sensorData = provider.sensorData;
          final weather = sensorData?.weather;

          final bool isSkyVisible = weather?.isSkyVisible ?? true; 
          
          final String rainProbText = !isSkyVisible 
              ? "--" 
              : "${weather?.rainProbability.toStringAsFixed(1) ?? "0.0"}%";

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  color: const Color(0xFF1E4F9B),
                  child: const Text(
                    "LIVE IMAGE",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 40),

                Center(
                  child: Container(
                    width: 260,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          spreadRadius: 2,
                          blurRadius: 8,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: hasImage
                        ? Image.memory(
                            provider.currentImage!,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  width: 260,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.cloud, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Rain Probability: $rainProbText",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!isSkyVisible) ...[
                         const SizedBox(height: 4),
                         const Text(
                           "⚠️ Sky not visible - Check Camera",
                           style: TextStyle(
                             color: Colors.red, 
                             fontSize: 12, 
                             fontWeight: FontWeight.bold
                           ),
                         )
                      ]
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  hasImage
                      ? "IMAGE RECEIVED AT ${_formatTime(imageTime)}"
                      : "Waiting for camera...",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}:"
        "${time.second.toString().padLeft(2, '0')}";
  }
}
