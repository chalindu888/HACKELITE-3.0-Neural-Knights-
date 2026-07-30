import '../../data/models/patient.dart';
import '../../data/models/prediction_result.dart';

abstract class PredictionService {
  Future<PredictionResult> predict({
    required Patient patient,
    required Map<String, dynamic> features,
    required String languageCode,
  });
}
