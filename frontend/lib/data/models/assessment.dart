import 'package:uuid/uuid.dart';
import 'patient.dart';
import 'prediction_result.dart';

class Assessment {
  final String id;
  final DateTime createdAt;
  final Patient patient;
  final Map<String, dynamic> features;
  final PredictionResult predictionResult;

  Assessment({
    String? id,
    DateTime? createdAt,
    required this.patient,
    required this.features,
    required this.predictionResult,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'patient': patient.toJson(),
      'features': features,
      'predictionResult': predictionResult.toJson(),
    };
  }

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      patient: Patient.fromJson(Map<String, dynamic>.from(json['patient'])),
      features: Map<String, dynamic>.from(json['features']),
      predictionResult: PredictionResult.fromJson(
          Map<String, dynamic>.from(json['predictionResult'])),
    );
  }
}
