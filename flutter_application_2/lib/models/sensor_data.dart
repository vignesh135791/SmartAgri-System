class Weather {
  final String description;
  final double rainProbability;
  final double cloudCover;
  final bool isSkyVisible;
  final String warning;

  Weather({
    required this.description,
    required this.rainProbability,
    required this.cloudCover,
    required this.isSkyVisible,
    this.warning = "",
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      description: json['description'] ?? "Unknown",
      rainProbability: (json['rain_probability'] as num?)?.toDouble() ?? 0.0,
      cloudCover: (json['cloud_cover'] as num?)?.toDouble() ?? 0.0,
      isSkyVisible: json['is_sky_visible'] ?? true,
      warning: json['weather_warning'] ?? "",
    );
  }
}

class ForecastItem {
  final String month;
  final String predictedCrop;
  final String expectedYield;
  final String weatherSummary;

  ForecastItem({
    required this.month,
    required this.predictedCrop,
    required this.expectedYield,
    required this.weatherSummary,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    return ForecastItem(
      month: json['month'] ?? "",
      predictedCrop: json['predicted_crop'] ?? "-",
      expectedYield: json['expected_yield'] ?? "-",
      weatherSummary: json['weather_summary'] ?? "-",
    );
  }
}

class CropPrediction {
  final List<String> suitableCrops;
  final double confidence;
  final List<ForecastItem> forecast;

  CropPrediction({
    required this.suitableCrops,
    required this.confidence,
    required this.forecast,
  });

  factory CropPrediction.fromJson(Map<String, dynamic> json) {
    return CropPrediction(
      suitableCrops: (json['suitable_crops'] as List?)
              ?.map((crop) => crop.toString())
              .toList() ??
          [],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      forecast: (json['forecast_2_months'] as List?)
              ?.map((forecast) => ForecastItem.fromJson(forecast))
              .toList() ??
          [],
    );
  }
}

class SensorData {
  final double temperature;
  final double humidity;
  final double light;
  final int soil; // raw ADC (Legacy)
  final double? soilMoistureBackend; // New field from MML backend
  final Weather? weather;
  final CropPrediction? cropPrediction;
  final double lastUpdated;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.light,
    required this.soil,
    this.soilMoistureBackend,
    this.weather,
    this.cropPrediction,
    this.lastUpdated = 0,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    final temperatureValue = json['temperature'] ?? json['temp'] ?? 0;
    final humidityValue = json['humidity'] ?? json['hum'] ?? 0;
    final lightValue =
        json['light_intensity'] ?? json['light'] ?? json['lux'] ?? 0;
    final soilRaw = json['soil'] ?? 1023;
    final backendSoilMoisture =
        (json['soil_moisture'] as num?)?.toDouble();

    return SensorData(
      temperature: (temperatureValue as num).toDouble(),
      humidity: (humidityValue as num).toDouble(),
      light: (lightValue as num).toDouble(),
      soil: (soilRaw as num).toInt(),
      soilMoistureBackend: backendSoilMoisture,
      weather: json['weather'] != null ? Weather.fromJson(json['weather']) : null,
      cropPrediction: json['crop_prediction'] != null ? CropPrediction.fromJson(json['crop_prediction']) : null,
      lastUpdated: (json['last_updated'] as num?)?.toDouble() ?? 0,
    );
  }

  double get soilPercent {
    if (soilMoistureBackend != null) {
      return soilMoistureBackend!.clamp(0, 100);
    }

    const int dry = 1023;
    const int wet = 350;

    final moisturePercent = (dry - soil) / (dry - wet) * 100;
    return moisturePercent.clamp(0, 100);
  }
}
