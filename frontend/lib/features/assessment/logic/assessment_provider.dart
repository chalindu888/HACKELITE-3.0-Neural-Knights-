import 'package:flutter/material.dart';
import '../../../data/models/patient.dart';
import '../../../data/models/health_feature.dart';
import '../../../data/models/prediction_result.dart';
import '../../../data/models/assessment.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../services/prediction/prediction_service.dart';
import '../../../services/prediction/teammate_tflite_prediction_service.dart';
import '../../../services/sync_engine.dart';

class AssessmentProvider extends ChangeNotifier {
  final PredictionService _predictionService = TeammateTflitePredictionService();

  Patient? _selectedPatient;
  Map<String, dynamic> _features = {};
  bool _isPredicting = false;
  PredictionResult? _currentResult;
  Assessment? _lastSavedAssessment;
  String? _errorMessage;

  Patient? get selectedPatient => _selectedPatient;
  Map<String, dynamic> get features => _features;
  bool get isPredicting => _isPredicting;
  PredictionResult? get currentResult => _currentResult;
  Assessment? get lastSavedAssessment => _lastSavedAssessment;
  String? get errorMessage => _errorMessage;

  AssessmentProvider() {
    _resetFeatures();
  }

  void _resetFeatures() {
    _features = {};
    for (var f in HealthFeature.prototypeFeatures) {
      _features[f.id] = f.defaultValue;
    }
  }

  void selectPatient(Patient patient) {
    _selectedPatient = patient;
    notifyListeners();
  }

  void clearSelectedPatient() {
    _selectedPatient = null;
    notifyListeners();
  }

  void updateFeature(String featureId, dynamic value) {
    _features[featureId] = value;
    notifyListeners();
  }

  Future<PredictionResult?> runPrediction(String languageCode) async {
    if (_selectedPatient == null) {
      _errorMessage = 'No patient selected';
      notifyListeners();
      return null;
    }

    _isPredicting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _predictionService.predict(
        patient: _selectedPatient!,
        features: _features,
        languageCode: languageCode,
      );
      _currentResult = result;
      _isPredicting = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isPredicting = false;
      _errorMessage = 'Prediction error: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<Assessment?> saveCurrentAssessment() async {
    if (_selectedPatient == null || _currentResult == null) return null;

    final assessment = Assessment(
      patient: _selectedPatient!,
      features: Map<String, dynamic>.from(_features),
      predictionResult: _currentResult!,
    );

    await LocalStorageService.saveAssessment(assessment);
    _lastSavedAssessment = assessment;
    notifyListeners();
    
    // Attempt to sync immediately if internet is available
    SyncEngine().syncUnsyncedData();
    
    return assessment;
  }

  void resetFlow() {
    _selectedPatient = null;
    _currentResult = null;
    _lastSavedAssessment = null;
    _errorMessage = null;
    _resetFeatures();
    notifyListeners();
  }
}
