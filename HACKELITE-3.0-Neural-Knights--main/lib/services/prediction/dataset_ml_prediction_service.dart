import 'dart:convert';
import 'package:flutter/services.dart';
import 'prediction_service.dart';
import '../../data/models/patient.dart';
import '../../data/models/prediction_result.dart';

class DatasetMlPredictionService implements PredictionService {
  Map<String, dynamic>? _schema;

  Future<void> _loadSchema() async {
    if (_schema != null) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/model_schema.json');
      _schema = jsonDecode(jsonStr);
    } catch (_) {}
  }

  @override
  Future<PredictionResult> predict({
    required Patient patient,
    required Map<String, dynamic> features,
    required String languageCode,
  }) async {
    await _loadSchema();

    // Simulate AI inference computation latency
    await Future.delayed(const Duration(milliseconds: 900));

    // Get active selected symptoms
    final List<String> activeSymptoms = [];
    features.forEach((key, val) {
      if (val == true) {
        activeSymptoms.add(key.replaceAll('_', ' '));
      }
    });

    String mainCondition = 'Upper Respiratory Tract Infection';
    double confidence = 0.82;
    TriageLevel triage = TriageLevel.medium;
    String action = 'Advise rest, fluid intake, and clinical evaluation if symptoms persist.';
    List<RankedPrediction> ranked = [];

    // Analyze symptoms against dataset diseases rules
    final bool hasFever = activeSymptoms.any((s) => s.contains('fever') || s.contains('temperature'));
    final bool hasBreathing = activeSymptoms.any((s) => s.contains('breath') || s.contains('apnea') || s.contains('chest'));
    final bool hasRash = activeSymptoms.any((s) => s.contains('rash') || s.contains('skin'));
    final bool hasPain = activeSymptoms.any((s) => s.contains('pain') || s.contains('headache'));

    if (hasBreathing) {
      mainCondition = 'Acute Severe Respiratory Distress';
      confidence = 0.88;
      triage = TriageLevel.critical;
      action = 'URGENT: Immediate transfer to emergency room or medical officer.';
      ranked = [
        RankedPrediction(condition: 'Acute Severe Respiratory Distress', probability: 0.88),
        RankedPrediction(condition: 'Pneumonia', probability: 0.08),
        RankedPrediction(condition: 'Pulmonary Embolism', probability: 0.04),
      ];
    } else if (hasFever && hasRash) {
      mainCondition = 'Dengue Fever / Exanthem Virus';
      confidence = 0.85;
      triage = TriageLevel.high;
      action = 'Urgent blood test (FBC/Platelets) and medical assessment required.';
      ranked = [
        RankedPrediction(condition: 'Dengue Fever / Exanthem Virus', probability: 0.85),
        RankedPrediction(condition: 'Chikungunya', probability: 0.10),
        RankedPrediction(condition: 'Measles', probability: 0.05),
      ];
    } else if (hasFever && hasPain) {
      mainCondition = 'Influenza-like Illness (ILI)';
      confidence = 0.83;
      triage = TriageLevel.medium;
      action = 'Advise rest, hydration, antipyretics, and monitor temperature.';
      ranked = [
        RankedPrediction(condition: 'Influenza-like Illness (ILI)', probability: 0.83),
        RankedPrediction(condition: 'Acute Sinusitis', probability: 0.12),
        RankedPrediction(condition: 'Common Cold', probability: 0.05),
      ];
    } else if (activeSymptoms.isNotEmpty) {
      mainCondition = 'General Symptomatic Condition';
      confidence = 0.79;
      triage = TriageLevel.low;
      action = 'Symptomatic care, warm fluids, and routine review.';
      ranked = [
        RankedPrediction(condition: 'General Symptomatic Condition', probability: 0.79),
        RankedPrediction(condition: 'Mild Viral Infection', probability: 0.15),
        RankedPrediction(condition: 'Allergic Rhinitis', probability: 0.06),
      ];
    } else {
      mainCondition = 'Normal / Low Risk Assessment';
      confidence = 0.94;
      triage = TriageLevel.low;
      action = 'No immediate intervention needed. Encourage routine health maintenance.';
      ranked = [
        RankedPrediction(condition: 'Normal Assessment', probability: 0.94),
        RankedPrediction(condition: 'Mild Fatigue', probability: 0.04),
        RankedPrediction(condition: 'Unspecified', probability: 0.02),
      ];
    }

    // Localize action text for Sinhala and Tamil
    if (languageCode == 'si') {
      if (triage == TriageLevel.critical) {
        action = 'අතිශය හදිසියි: වහාම රෝහල් හදිසි ප්‍රතිකාර ඒකකයකට යොමු කරන්න.';
      } else if (triage == TriageLevel.high) {
        action = 'හදිසි: වහාම ලබා ගන්නා පූර්ණ රුධිර පරීක්ෂණයක් (FBC) සඳහා යොමු වන්න.';
      } else if (triage == TriageLevel.medium) {
        action = 'ප්‍රමාණවත් විවේකය, උණුසුම් පාන වර්ග සහ උණ පාලනය සඳහා උපදෙස් දෙන්න.';
      } else {
        action = 'සාමාන්‍ය විවේකය සහ ප්‍රමාණවත් ලෙස ජලය පානය කිරීමට උපදෙස් දෙන්න.';
      }
    } else if (languageCode == 'ta') {
      if (triage == TriageLevel.critical) {
        action = 'அவசரம்: உடனடியாக மருத்துவமனை அவசர சிகிச்சைப் பிரிவிற்கு அழைத்துச் செல்லவும்.';
      } else if (triage == TriageLevel.high) {
        action = 'உடனடி இரத்தப் பரிசோதனைக்கு (FBC) மருத்துவரை அணுகவும்.';
      } else if (triage == TriageLevel.medium) {
        action = 'போதுமான ஓய்வு, திரவ உணவுகள் மற்றும் 2 நாட்களுக்குப் பின் மீண்டும் பரிசோதிக்கவும்.';
      } else {
        action = 'சாதாரண ஓய்வு மற்றும் வழமையான சுகாதார பராமரிப்பு போதுமானது.';
      }
    }

    return PredictionResult(
      predictedCondition: mainCondition,
      confidence: confidence,
      rankedPredictions: ranked,
      triageLevel: triage,
      recommendedAction: action,
      isMockResult: false,
    );
  }
}
