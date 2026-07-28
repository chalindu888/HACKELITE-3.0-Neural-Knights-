enum TriageLevel {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  final String label;
  const TriageLevel(this.label);

  static TriageLevel fromString(String val) {
    return TriageLevel.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase() || e.label.toLowerCase() == val.toLowerCase(),
      orElse: () => TriageLevel.medium,
    );
  }
}

class RankedPrediction {
  final String condition;
  final double probability; // 0.0 to 1.0

  RankedPrediction({
    required this.condition,
    required this.probability,
  });

  Map<String, dynamic> toJson() => {
        'condition': condition,
        'probability': probability,
      };

  factory RankedPrediction.fromJson(Map<String, dynamic> json) {
    return RankedPrediction(
      condition: json['condition'] as String,
      probability: (json['probability'] as num).toDouble(),
    );
  }
}

class PredictionResult {
  final String predictedCondition;
  final double confidence; // e.g. 0.82
  final List<RankedPrediction> rankedPredictions;
  final TriageLevel triageLevel;
  final String recommendedAction;
  final bool isMockResult;

  PredictionResult({
    required this.predictedCondition,
    required this.confidence,
    required this.rankedPredictions,
    required this.triageLevel,
    required this.recommendedAction,
    this.isMockResult = true,
  });

  Map<String, dynamic> toJson() => {
        'predictedCondition': predictedCondition,
        'confidence': confidence,
        'rankedPredictions': rankedPredictions.map((x) => x.toJson()).toList(),
        'triageLevel': triageLevel.name,
        'recommendedAction': recommendedAction,
        'isMockResult': isMockResult,
      };

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      predictedCondition: json['predictedCondition'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      rankedPredictions: (json['rankedPredictions'] as List)
          .map((x) => RankedPrediction.fromJson(Map<String, dynamic>.from(x)))
          .toList(),
      triageLevel: TriageLevel.fromString(json['triageLevel'] as String),
      recommendedAction: json['recommendedAction'] as String,
      isMockResult: json['isMockResult'] as bool? ?? true,
    );
  }
}
