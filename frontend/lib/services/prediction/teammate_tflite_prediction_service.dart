import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'prediction_service.dart';
import '../../data/models/patient.dart';
import '../../data/models/prediction_result.dart';

class TeammateTflitePredictionService implements PredictionService {
  List<String>? _symptomsList;
  List<String>? _diseasesLabels;
  Interpreter? _interpreter;

  Future<void> _loadModelArtifacts() async {
    if (_symptomsList != null && _diseasesLabels != null && _interpreter != null) return;

    try {
      final symJson = await rootBundle.loadString('assets/symptoms_list.json');
      final disJson = await rootBundle.loadString('assets/diseases_labels.json');

      _symptomsList = List<String>.from(jsonDecode(symJson));
      _diseasesLabels = List<String>.from(jsonDecode(disJson));
      
      _interpreter = await Interpreter.fromAsset('assets/medisense_model.tflite');
      print('TFLite model loaded successfully');
    } catch (e) {
      print('Error loading model artifacts: $e');
    }
  }

  @override
  Future<PredictionResult> predict({
    required Patient patient,
    required Map<String, dynamic> features,
    required String languageCode,
  }) async {
    await _loadModelArtifacts();

    if (_interpreter == null || _symptomsList == null || _diseasesLabels == null) {
      throw Exception('TFLite model or dictionaries failed to load');
    }

    final symptoms = _symptomsList!;
    final diseases = _diseasesLabels!;

    // 1. Prepare input tensor
    int inputSize = symptoms.length;
    List<double> inputFeatures = List.filled(inputSize, 0.0);

    features.forEach((key, val) {
      if (val == true) {
        String symptomName = key.replaceAll('_', ' ').toLowerCase();
        int idx = symptoms.indexWhere((s) => s.toLowerCase() == symptomName);
        if (idx != -1) {
          inputFeatures[idx] = 1.0;
        }
      }
    });

    var input = [inputFeatures]; // shape [1, inputSize]
    
    // 2. Prepare output tensor
    int numDiseases = diseases.length;
    var output = [List.filled(numDiseases, 0.0)]; // shape [1, numDiseases]

    // 3. Run Inference
    _interpreter!.run(input, output);

    // 4. Parse Results
    List<double> probabilities = output[0];
    
    double maxProb = 0.0;
    int maxIdx = 0;
    List<RankedPrediction> ranked = [];
    
    for (int i = 0; i < probabilities.length; i++) {
      double prob = probabilities[i];
      ranked.add(RankedPrediction(condition: _toTitleCase(diseases[i]), probability: prob));
      if (prob > maxProb) {
        maxProb = prob;
        maxIdx = i;
      }
    }
    
    // Sort descending
    ranked.sort((a, b) => b.probability.compareTo(a.probability));
    ranked = ranked.take(3).toList(); // Return top 3 predictions
    
    String mainCondition = _toTitleCase(diseases[maxIdx]);
    double confidence = maxProb;
    
    // 5. Determine Triage & Actions
    TriageLevel triage = _determineTriage(mainCondition, confidence);
    String action = _determineAction(triage, languageCode);

    return PredictionResult(
      predictedCondition: mainCondition,
      confidence: confidence,
      rankedPredictions: ranked,
      triageLevel: triage,
      recommendedAction: action,
      isMockResult: false,
    );
  }

  TriageLevel _determineTriage(String condition, double confidence) {
    String lowerCond = condition.toLowerCase();
    if (lowerCond.contains('ards') || lowerCond.contains('heart') || lowerCond.contains('stroke')) {
      return TriageLevel.critical;
    } else if (lowerCond.contains('dengue') || lowerCond.contains('pneumonia') || lowerCond.contains('malaria')) {
      return TriageLevel.high;
    } else if (lowerCond.contains('flu') || lowerCond.contains('infection')) {
      return TriageLevel.medium;
    }
    return TriageLevel.low;
  }

  String _determineAction(TriageLevel triage, String languageCode) {
    if (languageCode == 'si') {
      if (triage == TriageLevel.critical) {
        return 'අතිශය හදිසියි: වහාම රෝහල් හදිසි ප්‍රතිකාර ඒකකයකට යොමු කරන්න.';
      } else if (triage == TriageLevel.high) {
        return 'හදිසි: වහාම ලබා ගන්නා පූර්ණ රුධිර පරීක්ෂණයක් (FBC) සඳහා වෛද්‍යවරයෙකු හමුවන්න.';
      } else if (triage == TriageLevel.medium) {
        return 'ප්‍රමාණවත් විවේකය, උණුසුම් පාන වර්ග සහ උණ පාලනය සඳහා උපදෙස් දෙන්න.';
      } else {
        return 'සාමාන්‍ය විවේකය සහ ප්‍රමාණවත් ලෙස ජලය පානය කිරීමට උපදෙස් දෙන්න.';
      }
    } else if (languageCode == 'ta') {
      if (triage == TriageLevel.critical) {
        return 'அவசரம்: உடனடியாக மருத்துவமனை அவசர சிகிச்சைப் பிரிவிற்கு அழைத்துச் செல்லவும்.';
      } else if (triage == TriageLevel.high) {
        return 'உடனடி இரத்தப் பரிசோதனைக்கு (FBC) மருத்துவரை அணுகவும்.';
      } else if (triage == TriageLevel.medium) {
        return 'போதுமான ஓய்வு, திரவ உணவுகள் மற்றும் 2 நாட்களுக்குப் பின் மீண்டும் பரிசோதிக்கவும்.';
      } else {
        return 'சாதாரண ஓய்வு மற்றும் வழமையான சுகாதார பராமரிப்பு போதுமானது.';
      }
    } else {
      // English
      if (triage == TriageLevel.critical) {
        return 'URGENT: Immediate emergency referral required.';
      } else if (triage == TriageLevel.high) {
        return 'Urgent blood count (FBC) and medical clinic assessment.';
      } else if (triage == TriageLevel.medium) {
        return 'Advise rest, adequate fluids, and review if symptoms persist.';
      } else {
        return 'Routine symptomatic care, hydration, and rest.';
      }
    }
  }

  String _toTitleCase(String str) {
    return str.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
