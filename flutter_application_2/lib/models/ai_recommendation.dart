class CropRecommendation {
  const CropRecommendation({
    required this.crop,
    required this.confidence,
    required this.reasons,
  });

  final String crop;
  final double confidence;
  final List<String> reasons;

  factory CropRecommendation.fromJson(Map<String, dynamic> json) {
    return CropRecommendation(
      crop: json['crop'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      reasons: (json['reasons'] as List<dynamic>)
          .map((reason) => reason.toString())
          .toList(),
    );
  }
}

class AiRecommendation {
  const AiRecommendation({
    required this.status,
    required this.summary,
    required this.confidence,
    required this.recommendations,
    required this.productivityInsights,
  });

  final String status;
  final String summary;
  final double confidence;
  final List<CropRecommendation> recommendations;
  final List<String> productivityInsights;

  factory AiRecommendation.fromJson(Map<String, dynamic> json) {
    return AiRecommendation(
      status: json['status'] as String,
      summary: json['summary'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((item) =>
              CropRecommendation.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      productivityInsights: (json['productivity_insights'] as List<dynamic>)
          .map((insight) => insight.toString())
          .toList(),
    );
  }
}
