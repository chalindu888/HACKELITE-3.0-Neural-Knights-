import 'package:url_launcher/url_launcher.dart';
import '../../data/models/assessment.dart';
import '../../core/localization/app_translations.dart';

class SmsService {
  static String formatPatientMessage({
    required Assessment assessment,
    required AppLanguage language,
  }) {
    final patientName = assessment.patient.name;
    final condition = assessment.predictionResult.predictedCondition;
    final confidence = (assessment.predictionResult.confidence * 100).toStringAsFixed(0);
    final triage = assessment.predictionResult.triageLevel.label;
    final action = assessment.predictionResult.recommendedAction;
    final dateStr = '${assessment.createdAt.day}/${assessment.createdAt.month}/${assessment.createdAt.year}';

    switch (language) {
      case AppLanguage.sinhala:
        return 'MediSense AI සෞඛ්‍ය වාර්තාව ($dateStr)\n'
            'රෝගියා: $patientName\n'
            'තත්ත්වය: $condition ($confidence%)\n'
            'අවදානම: $triage\n'
            'උපදෙස: $action\n'
            '[මෙය AI ආදර්ශ වාර්තාවකි]';
      case AppLanguage.tamil:
        return 'MediSense AI சுகாதார அறிக்கை ($dateStr)\n'
            'நோயாளி: $patientName\n'
            'நிலைமை: $condition ($confidence%)\n'
            'அபாயம்: $triage\n'
            'பரிந்துரை: $action\n'
            '[மாதிரி AI அறிக்கை]';
      case AppLanguage.english:
        return 'MediSense AI Assessment Summary ($dateStr)\n'
            'Patient: $patientName\n'
            'Condition: $condition ($confidence%)\n'
            'Triage: $triage Risk\n'
            'Recommendation: $action\n'
            '[Demo / Simulated AI Result]';
    }
  }

  static Future<bool> sendSms({
    required String phoneNumber,
    required String messageText,
  }) async {
    final Uri uri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: <String, String>{
        'body': messageText,
      },
    );

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
    } catch (_) {}
    return false;
  }
}
