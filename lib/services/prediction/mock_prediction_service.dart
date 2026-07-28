import 'prediction_service.dart';
import '../../data/models/patient.dart';
import '../../data/models/prediction_result.dart';

class MockPredictionService implements PredictionService {
  @override
  Future<PredictionResult> predict({
    required Patient patient,
    required Map<String, dynamic> features,
    required String languageCode,
  }) async {
    // Simulate AI inference calculation delay
    await Future.delayed(const Duration(milliseconds: 1200));

    final bool fever = features['fever'] == true;
    final bool cough = features['cough'] == true;
    final bool headache = features['headache'] == true;
    final bool fatigue = features['fatigue'] == true;
    final bool skinRash = features['skin_rash'] == true;
    final bool breathingDiff = features['breathing_difficulty'] == true;

    final num temp = (features['temperature'] as num?) ?? 37.0;
    final num pulse = (features['pulse'] as num?) ?? 72;
    final num sysBp = (features['systolic_bp'] as num?) ?? 120;
    final num diaBp = (features['diastolic_bp'] as num?) ?? 80;

    String mainCondition = 'General Mild Viral Illness';
    double confidence = 0.78;
    TriageLevel triage = TriageLevel.low;
    String action = 'Advise rest, adequate fluid intake, and monitor symptoms over 48 hours.';
    List<RankedPrediction> ranked = [];

    // Heuristic logic for mock AI simulation
    if (breathingDiff || sysBp > 160 || diaBp > 100 || sysBp < 90 || temp >= 39.5 || pulse > 120) {
      mainCondition = 'Acute Severe Respiratory Distress / Hypertensive Urgency';
      confidence = 0.89;
      triage = TriageLevel.critical;
      action = 'URGENT: Immediate referral to hospital emergency room or medical officer.';
      ranked = [
        RankedPrediction(condition: 'Severe Acute Respiratory Distress', probability: 0.89),
        RankedPrediction(condition: 'Complicated Dengue Fever', probability: 0.07),
        RankedPrediction(condition: 'Bacterial Pneumonia', probability: 0.04),
      ];
    } else if (fever && skinRash && headache) {
      mainCondition = 'Possible Dengue Fever';
      confidence = 0.84;
      triage = TriageLevel.high;
      action = 'Seek urgent blood test (FBC/Platelet count) and clinic evaluation.';
      ranked = [
        RankedPrediction(condition: 'Possible Dengue Fever', probability: 0.84),
        RankedPrediction(condition: 'Chikungunya / Viral Exanthem', probability: 0.11),
        RankedPrediction(condition: 'Influenza Type A', probability: 0.05),
      ];
    } else if (fever && cough && (temp > 38.0)) {
      mainCondition = 'Influenza-like Illness (ILI)';
      confidence = 0.81;
      triage = TriageLevel.medium;
      action = 'Provide antipyretics, advise isolation at home, and review in 2 days if fever persists.';
      ranked = [
        RankedPrediction(condition: 'Influenza-like Illness', probability: 0.81),
        RankedPrediction(condition: 'Acute Bronchitis', probability: 0.14),
        RankedPrediction(condition: 'Common Cold', probability: 0.05),
      ];
    } else if (cough || headache || fatigue) {
      mainCondition = 'Upper Respiratory Tract Infection (Common Cold)';
      confidence = 0.76;
      triage = TriageLevel.low;
      action = 'Symptomatic relief, warm fluids, rest, and routine follow-up.';
      ranked = [
        RankedPrediction(condition: 'Upper Respiratory Infection', probability: 0.76),
        RankedPrediction(condition: 'Mild Viral Fever', probability: 0.18),
        RankedPrediction(condition: 'Allergic Rhinitis', probability: 0.06),
      ];
    } else {
      mainCondition = 'Normal / Low Risk Symptom Profile';
      confidence = 0.92;
      triage = TriageLevel.low;
      action = 'No immediate intervention needed. Encourage routine health maintenance.';
      ranked = [
        RankedPrediction(condition: 'Normal Assessment', probability: 0.92),
        RankedPrediction(condition: 'Mild Fatigue', probability: 0.05),
        RankedPrediction(condition: 'Unspecified Symptom', probability: 0.03),
      ];
    }

    // Localize action if language is Sinhala or Tamil
    if (languageCode == 'si') {
      if (triage == TriageLevel.critical) {
        action = 'අතිශය හදිසියි: වහාම රෝහල් හදිසි ප්‍රතිකාර ඒකකයකට හෝ වෛද්‍යවරයෙකු වෙත යොමු කරන්න.';
      } else if (triage == TriageLevel.high) {
        action = 'හදිසි: වහාම ලබා ගන්නා පූර්ණ රුධිර පරීක්ෂණයක් (FBC) සඳහා වෛද්‍යවරයෙකු හමුවන්න.';
      } else if (triage == TriageLevel.medium) {
        action = 'ප්‍රමාණවත් විවේකය, උණුසුම් පාන වර්ග සහ උණ පාලනය සඳහා ප්‍රතිකාර ලබාදෙන්න.';
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
      isMockResult: true,
    );
  }
}
