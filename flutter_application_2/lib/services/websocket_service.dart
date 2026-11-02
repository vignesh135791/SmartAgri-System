import 'dart:convert';
import '../config/app_config.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/sensor_data.dart';

class WebSocketService {
  final WebSocketChannel channel;

  WebSocketService()
      : channel = WebSocketChannel.connect(
          Uri.parse(AppConfig.websocketUrl),
        ) {
    debugPrint("🔌 WebSocketService: Connecting to ${AppConfig.websocketUrl}");
  }

  Stream<dynamic> get rawStream => channel.stream;

  String _cleanJson(String message) {
    final jsonStart = message.indexOf('{');
    if (jsonStart != -1) {
      message = message.substring(jsonStart);
    }

    message = message.replaceAll("'", '"');

    return message.trim();
  }

  SensorData? parseSensor(dynamic message) {
    if (message is String) {
      try {
        final cleaned = _cleanJson(message);
        final json = jsonDecode(cleaned);
        
        if (json is Map<String, dynamic> && json['type'] == 'enriched_data') {
          final sensorMap = Map<String, dynamic>.from(json['sensor_data']);

          if (json.containsKey('weather')) {
            sensorMap['weather'] = json['weather'];
          }
          if (json.containsKey('crop_prediction')) {
            sensorMap['crop_prediction'] = json['crop_prediction'];
          }
          
          return SensorData.fromJson(sensorMap);
        }
        
        return SensorData.fromJson(json);
      } catch (error) {
        debugPrint("Sensor JSON parse failed: $error");
      }
    }
    return null;
  }

  Map<String, dynamic>? parseEnrichedData(dynamic message) {
    if (message is String) {
      try {
        final Map<String, dynamic> json = jsonDecode(message);
        if (json['type'] == 'enriched_data') {
          return json;
        }
      } catch (_) {}
    }
    return null;
  }

  Uint8List? parseImage(dynamic message) {
    if (message is Uint8List) return message;

    if (message is List<int>) {
      return Uint8List.fromList(message);
    }

    if (message is String) {
      try {
        final Map<String, dynamic> json = jsonDecode(message);
        if (json.containsKey('processed_image') && json['processed_image'] != "") {
          return base64Decode(json['processed_image']);
        }
      } catch (_) {}
    }

    return null;
  }

  void send(String message) {
    channel.sink.add(message);
  }

  void dispose() {
    channel.sink.close();
  }
}
