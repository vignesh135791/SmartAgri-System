import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../providers/acc.dart';
import '../services/websocket_service.dart';
import '../models/sensor_data.dart';

class AudioAccessibilityButton extends StatefulWidget {
  const AudioAccessibilityButton({super.key});

  @override
  State<AudioAccessibilityButton> createState() =>
      _AudioAccessibilityButtonState();
}

class _AudioAccessibilityButtonState extends State<AudioAccessibilityButton> {
  final FlutterTts flutterTts = FlutterTts();
  final WebSocketService _ws = WebSocketService();

  StreamSubscription? _sub;
  SensorData? _latestSensor;

  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();

    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.45);

    _sub = _ws.rawStream.listen((msg) {
      final data = _ws.parseSensor(msg);
      if (data != null) {
        _latestSensor = data;
      }
    });
  }

  Future<void> _configureLanguage(TtsLanguage language) async {
    if (language == TtsLanguage.tamil) {
      await flutterTts.setLanguage("ta-IN");
    } else {
      await flutterTts.setLanguage("en-US");
    }
  }

  Future<void> speak(BuildContext context) async {
    if (isSpeaking) return;

    final accProvider = context.read<AccessibilityProvider>();
    final language = accProvider.language;
    final screenIndex = accProvider.currentScreen;

    final sensor = _latestSensor;

    String text = "";

    switch (screenIndex) {

      case 0:
        if (language == TtsLanguage.tamil) {
          text = "இது சென்சார் கண்காணிப்பு திரை. ";

          if (sensor != null) {
            text +=
                "வெப்பநிலை ${sensor.temperature.toInt()} டிகிரி. "
                "ஈரப்பதம் ${sensor.humidity.toInt()} சதவீதம். "
                "ஒளி அளவு ${sensor.light.toInt()}. "
                "மண் ஈரப்பதம் ${sensor.soil.toInt()} சதவீதம்.";
          } else {
            text += "தற்போது சென்சார் தரவு கிடைக்கவில்லை.";
          }
        } else {
          text = "This is the sensor dashboard. ";

          if (sensor != null) {
            text +=
                "Temperature is ${sensor.temperature.toInt()} degrees. "
                "Humidity is ${sensor.humidity.toInt()} percent. "
                "Light intensity is ${sensor.light.toInt()}. "
                "Soil moisture is ${sensor.soil.toInt()} percent.";
          } else {
            text += "Sensor data is not available right now.";
          }
        }
        break;

      case 1:
        text = language == TtsLanguage.tamil
            ? "இது நேரடி கேமரா திரை."
            : "This is the live camera screen.";
        break;

      case 2:
        if (language == TtsLanguage.tamil) {
          text = "இது சென்சார் வரைபட திரை. ";

          if (sensor != null) {
            text +=
                "வெப்பநிலை ${sensor.temperature.toInt()} டிகிரி. "
                "ஈரப்பதம் ${sensor.humidity.toInt()} சதவீதம். "
                "ஒளி அளவு ${sensor.light.toInt()}. "
                "மண் ஈரப்பதம் ${sensor.soil.toInt()} சதவீதம்.";
          } else {
            text += "தற்போது சென்சார் தரவு இல்லை.";
          }
        } else {
          text = "This is the live sensor graph screen. ";

          if (sensor != null) {
            text +=
                "Temperature is ${sensor.temperature.toInt()} degrees. "
                "Humidity is ${sensor.humidity.toInt()} percent. "
                "Light is ${sensor.light.toInt()}. "
                "Soil moisture is ${sensor.soil.toInt()} percent.";
          } else {
            text += "Sensor data is not available.";
          }
        }
        break;

      default:
        text = language == TtsLanguage.tamil
            ? "இந்த திரையில் விவசாய தொடர்பான தகவல்கள் காணப்படுகின்றன."
            : "This screen shows agriculture related information.";
    }

    try {
      setState(() => isSpeaking = true);
      await flutterTts.stop();
      await _configureLanguage(language);
      await flutterTts.speak(text);
    } finally {
      if (mounted) {
        setState(() => isSpeaking = false);
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ws.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilityProvider>(
      builder: (_, provider, __) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            FloatingActionButton(
              heroTag: "speak_btn",
              backgroundColor: Colors.deepPurple,
              onPressed: () => speak(context),
              child: Icon(isSpeaking ? Icons.stop : Icons.volume_up),
            ),

            const SizedBox(height: 12),

            FloatingActionButton(
              heroTag: "lang_btn",
              mini: true,
              backgroundColor: Colors.orange,
              onPressed: () =>
                  context.read<AccessibilityProvider>().toggleLanguage(),
              child: Icon(
                provider.language == TtsLanguage.tamil
                    ? Icons.language
                    : Icons.translate,
              ),
            ),
          ],
        );
      },
    );
  }
}
