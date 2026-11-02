import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../services/websocket_service.dart';
import '../models/sensor_data.dart';
import 'package:fl_chart/fl_chart.dart';

class DataProvider extends ChangeNotifier {
  final WebSocketService _sensorStream = WebSocketService();
  late StreamSubscription _sensorSubscription;

  SensorData? _sensorData;
  Uint8List? _currentImage;
  DateTime _lastImageTime = DateTime.fromMillisecondsSinceEpoch(0);
  bool _isConnected = false;

  final List<FlSpot> _lightHistory = [];
  final List<FlSpot> _humidityHistory = [];
  final List<FlSpot> _soilHistory = [];
  final List<FlSpot> _tempHistory = [];
  double _chartPosition = 0;
  final int _maxHistoryPoints = 50;

  DateTime _lastGraphUpdate = DateTime.now();

  SensorData? get sensorData => _sensorData;
  Uint8List? get currentImage => _currentImage;
  DateTime get lastImageTime => _lastImageTime;
  bool get isConnected => _isConnected;

  List<FlSpot> get lightHistory => List.unmodifiable(_lightHistory);
  List<FlSpot> get humidityHistory => List.unmodifiable(_humidityHistory);
  List<FlSpot> get soilHistory => List.unmodifiable(_soilHistory);
  List<FlSpot> get tempHistory => List.unmodifiable(_tempHistory);
  double get maxX => _chartPosition;

  DataProvider() {
    Future.microtask(_startSensorStream);
  }

  void _startSensorStream() {
    try {
      _sensorSubscription = _sensorStream.rawStream.listen(
        (incomingMessage) {
          try {
            final enrichedPacket =
                _sensorStream.parseEnrichedData(incomingMessage);
            if (enrichedPacket != null) {
              _isConnected = true;

              _sensorData = SensorData.fromJson(enrichedPacket['sensor_data']);
              if (enrichedPacket.containsKey('weather') ||
                  enrichedPacket.containsKey('prediction')) {
                _sensorData = SensorData(
                  temperature: _sensorData!.temperature,
                  humidity: _sensorData!.humidity,
                  light: _sensorData!.light,
                  soil: _sensorData!.soil,
                  soilMoistureBackend: _sensorData!.soilMoistureBackend,
                  weather: enrichedPacket['weather'] != null
                      ? Weather.fromJson(enrichedPacket['weather'])
                      : _sensorData!.weather,
                  cropPrediction: enrichedPacket['prediction'] != null
                      ? CropPrediction.fromJson(enrichedPacket['prediction'])
                      : _sensorData!.cropPrediction,
                  lastUpdated: _sensorData!.lastUpdated,
                );
              }

              if (enrichedPacket['processed_image'] != null &&
                  enrichedPacket['processed_image'] != "") {
                final imageBytes = _sensorStream.parseImage(incomingMessage);
                if (imageBytes != null) {
                  _currentImage = imageBytes;
                  _lastImageTime = DateTime.now();
                }
              }

              _updateGraphData(_sensorData!);
              notifyListeners();
              return;
            }

            if (incomingMessage is Uint8List ||
                incomingMessage is List<int>) {
              final imageBytes = _sensorStream.parseImage(incomingMessage);
              if (imageBytes != null) {
                _currentImage = imageBytes;
                _lastImageTime = DateTime.now();
                _isConnected = true;
                notifyListeners();
                return;
              }
            }

            final sensorReading = _sensorStream.parseSensor(incomingMessage);
            if (sensorReading != null) {
              _sensorData = sensorReading;
              _isConnected = true;
              _updateGraphData(sensorReading);
              notifyListeners();
            }
          } catch (error) {
            debugPrint("Error parsing sensor message: $error");
          }
        },
        onError: (error) {
          debugPrint("WebSocket stream error: $error");
          _isConnected = false;
          notifyListeners();
        },
        onDone: () {
          debugPrint("WebSocket stream closed");
          _isConnected = false;
          notifyListeners();
        },
      );
    } catch (error) {
       debugPrint("Could not initialize WebSocket: $error");
    }
  }

  void _updateGraphData(SensorData reading) {
    final now = DateTime.now();
    if (now.difference(_lastGraphUpdate).inMilliseconds < 300) return;
    _lastGraphUpdate = now;

    _chartPosition++;
    _lightHistory.add(FlSpot(_chartPosition, reading.light.clamp(0, 1000) / 10));
    _humidityHistory.add(FlSpot(_chartPosition, reading.humidity));
    _soilHistory.add(FlSpot(_chartPosition, reading.soilPercent));
    _tempHistory.add(FlSpot(_chartPosition, reading.temperature));

    if (_lightHistory.length > _maxHistoryPoints) {
      _lightHistory.removeAt(0);
      _humidityHistory.removeAt(0);
      _soilHistory.removeAt(0);
      _tempHistory.removeAt(0);
    }
  }

  @override
  void dispose() {
    _sensorSubscription.cancel();
    _sensorStream.dispose();
    super.dispose();
  }
}
