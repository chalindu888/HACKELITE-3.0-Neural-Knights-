enum AppLanguage {
  english('en', 'English', '🇬🇧'),
  sinhala('si', 'සිංහල', '🇱🇰'),
  tamil('ta', 'தமிழ்', '🇱🇰');

  final String code;
  final String label;
  final String flag;

  const AppLanguage(this.code, this.label, this.flag);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}

class AppTranslations {
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'MediSense AI',
      'app_subtitle': 'Healthcare Assessment Tool for CHWs',
      'select_language': 'Select Language',
      'home': 'Home',
      'patients': 'Patients',
      'history': 'History',
      'new_assessment': 'New Assessment',
      'recent_assessments': 'Recent Assessments',
      'no_recent_assessments': 'No recent assessments found.',
      'total_patients': 'Total Patients',
      'total_assessments': 'Total Assessments',
      'quick_actions': 'Quick Actions',
      'search_patient': 'Search Patient by Phone / Name',
      'register_new_patient': 'Register New Patient',
      'patient_information': 'Patient Information',
      'select_patient': 'Select Patient',
      'login_select_patient': 'Patient Login / Select Account',
      'patient_name': 'Full Name',
      'phone_number': 'Phone Number',
      'phone_number_hint': 'e.g. 0771234567 or +94771234567',
      'age': 'Age (Years)',
      'gender': 'Gender',
      'male': 'Male',
      'female': 'Female',
      'other': 'Other',
      'additional_notes': 'Additional Notes (Optional)',
      'save_register_patient': 'Save & Proceed to Assessment',
      'enter_patient_details': 'Enter Patient Details',
      'patient_required_err': 'Patient name is required',
      'phone_required_err': 'Valid phone number is required (min 9 digits)',
      'age_required_err': 'Please enter a valid age between 0 and 120',
      'gender_required_err': 'Please select a gender',
      
      // Symptoms & Health Data
      'symptoms_and_vitals': 'Symptoms & Health Measurements',
      'symptoms_section': 'Current Symptoms',
      'vitals_section': 'Vital Signs & Measurements',
      'fever': 'Fever',
      'cough': 'Cough',
      'headache': 'Headache',
      'fatigue': 'Fatigue',
      'skin_rash': 'Skin Rash',
      'breathing_difficulty': 'Breathing Difficulty',
      
      'pulse': 'Pulse Rate',
      'pulse_unit': 'bpm',
      'sys_bp': 'Systolic BP',
      'dia_bp': 'Diastolic BP',
      'bp_unit': 'mmHg',
      'temperature': 'Body Temperature',
      'temp_unit': '°C',
      
      'continue_review': 'Proceed to Review',
      'review_assessment': 'Assessment Summary Review',
      'patient_summary': 'Patient Summary',
      'symptom_summary': 'Reported Symptoms',
      'vitals_summary': 'Vital Measurements',
      'edit': 'Edit',
      'run_ai_prediction': 'Run Mock AI Prediction',
      
      // Results
      'prediction_results': 'Assessment Results',
      'main_condition': 'Primary AI Prediction',
      'confidence': 'Confidence Score',
      'triage_level': 'Triage Risk Level',
      'recommended_action': 'Recommended Action',
      'differential_diagnosis': 'Ranked Differential Diagnosis',
      'demo_disclaimer_title': 'DEMO / MOCK AI RESULT',
      'demo_disclaimer_body': 'This result is a simulated AI-assisted prediction for demonstration purposes only. It is not a confirmed medical diagnosis. The final ML model will be connected in Phase 2.',
      'save_locally': 'Save Assessment Record Offline',
      'send_sms': 'Send Message to Patient',
      'saved_successfully': 'Assessment saved locally to offline storage.',
      
      // Triage
      'triage_low': 'Low Risk',
      'triage_medium': 'Medium Risk',
      'triage_high': 'High Risk',
      'triage_critical': 'Critical Risk',
      
      // SMS Dialog
      'sms_title': 'Send Checkup Summary SMS',
      'sms_recipient': 'Recipient Phone',
      'sms_preview': 'Message Preview',
      'launch_sms': 'Open SMS App',
      'copy_text': 'Copy Message Text',
      'copied_toast': 'Message copied to clipboard!',
      
      // History
      'assessment_history': 'Saved Offline History',
      'search_history': 'Search history by patient name or phone',
      'view_details': 'View Full Record',
      'delete_record': 'Delete Record',
      'confirm_delete': 'Are you sure you want to delete this assessment record?',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'record_deleted': 'Record deleted successfully.',
      'yes': 'Yes',
      'no': 'No',
      'normal': 'Normal',
      'abnormal': 'Abnormal',
    },
    'si': {
      'app_title': 'MediSense AI',
      'app_subtitle': 'සෞඛ්‍ය සේවකයන් සඳහා වූ AI ඇගයීම් පද්ධතිය',
      'select_language': 'භාෂාව තෝරන්න',
      'home': 'මුල් පිටුව',
      'patients': 'රෝගීන්',
      'history': 'වාර්තා එකතුව',
      'new_assessment': 'නව ඇගයීමක්',
      'recent_assessments': 'ඉදිරිපත් කළ මෑත ඇගයීම්',
      'no_recent_assessments': 'මෑත ඇගයීම් වාර්තා කිසිවක් හමු නොවීය.',
      'total_patients': 'මුළු රෝගීන් ගණන',
      'total_assessments': 'මුළු ඇගයීම් ගණන',
      'quick_actions': 'ඉක්මන් ක්‍රියාකාරකම්',
      'search_patient': 'දුරකථන අංකයෙන් / නමෙන් රෝගියා සොයන්න',
      'register_new_patient': 'නව රෝගියෙකු ලියාපදිංචි කරන්න',
      'patient_information': 'රෝගියාගේ තොරතුරු',
      'select_patient': 'රෝගියා තෝරන්න',
      'login_select_patient': 'රෝගී ගිණුමට පිවිසෙන්න / තෝරන්න',
      'patient_name': 'සම්පූර්ණ නම',
      'phone_number': 'දුරකථන අංකය',
      'phone_number_hint': 'උදා: 0771234567 හෝ +94771234567',
      'age': 'වයස (අවුරුදු)',
      'gender': 'ස්ත්‍රී / පුරුෂ භාවය',
      'male': 'පුරුෂ',
      'female': 'ස්ත්‍රී',
      'other': 'වෙනත්',
      'additional_notes': 'අමතර සටහන් (අවශ්‍ය නම් පමණි)',
      'save_register_patient': 'සුරක්ෂිත කර ඇගයීමට යන්න',
      'enter_patient_details': 'රෝගී තොරතුරු ඇතුළත් කරන්න',
      'patient_required_err': 'රෝගියාගේ නම ඇතුළත් කිරීම අනිවාර්යයි',
      'phone_required_err': 'වලංගු දුරකථන අංකයක් ඇතුළත් කරන්න (අවමය ඉලක්කම් 9)',
      'age_required_err': '0 ත් 120 ත් අතර නිවැරදි වයසක් ඇතුළත් කරන්න',
      'gender_required_err': 'කරුණාකර ස්ත්‍රී/පුරුෂ භාවය තෝරන්න',
      
      // Symptoms & Health Data
      'symptoms_and_vitals': 'රෝග ලක්ෂණ සහ සෞඛ්‍ය මිනුම්',
      'symptoms_section': 'වර්තමාන රෝග ලක්ෂණ',
      'vitals_section': 'ශාරීරික මිනුම් සහ සංඥා',
      'fever': 'උණ',
      'cough': 'කැස්ස',
      'headache': 'හිසරදය',
      'fatigue': 'වෙහෙස බව',
      'skin_rash': 'සමේ පළු / ලප',
      'breathing_difficulty': 'ශ්වසන අපහසුව',
      
      'pulse': 'හෘද ස්පන්දන වේගය',
      'pulse_unit': 'bpm',
      'sys_bp': 'සිස්ටොලික් රුධිර පීඩනය',
      'dia_bp': 'ඩයස්ටොලික් රුධිර පීඩනය',
      'bp_unit': 'mmHg',
      'temperature': 'ශරීර උෂ්ණත්වය',
      'temp_unit': '°C',
      
      'continue_review': 'සමාලෝචනයට යන්න',
      'review_assessment': 'ඇගයීම් සාරාංශ සමාලෝචනය',
      'patient_summary': 'රෝගියාගේ සාරාංශය',
      'symptom_summary': 'වාර්තා වූ රෝග ලක්ෂණ',
      'vitals_summary': 'ශාරීරික මිනුම්',
      'edit': 'සංස්කරණය',
      'run_ai_prediction': 'AI පූර්වානුමානය ලබාගන්න',
      
      // Results
      'prediction_results': 'ඇගයීම් ප්‍රතිඵල',
      'main_condition': 'ප්‍රධාන AI පූර්වානුමානය',
      'confidence': 'විශ්වාසනීයත්ව ප්‍රතිශතය',
      'triage_level': 'අවදානම් මට්ටම (Triage)',
      'recommended_action': 'නිර්දේශිත ක්‍රියාමාර්ගය',
      'differential_diagnosis': 'වෙනත් වියහැකි රෝගී තත්ත්වයන්',
      'demo_disclaimer_title': 'ආදර්ශ / MOCK AI ප්‍රතිඵලයකි',
      'demo_disclaimer_body': 'මෙය නිරූපණ අරමුණු සඳහා පමණක් සකස් කරන ලද AI පූර්වානුමානයකි. මෙය අවසාන වෛද්‍ය රෝග විනිශ්චයක් නොවේ.',
      'save_locally': 'වාර්තාව දුරකථනයෙහි සුරකින්න',
      'send_sms': 'රෝගියාට SMS පණිවුඩයක් යවන්න',
      'saved_successfully': 'ඇගයීම් වාර්තාව සාර්ථකව සුරකින ලදී.',
      
      // Triage
      'triage_low': 'අඩු අවදානම',
      'triage_medium': 'මධ්‍යම අවදානම',
      'triage_high': 'ඉහළ අවදානම',
      'triage_critical': 'අතිශය අධික අවදානම',
      
      // SMS Dialog
      'sms_title': 'රෝගියාට සෞඛ්‍ය වාර්තාව යැවීම',
      'sms_recipient': 'ලැබෙන්නාගේ දුරකථන අංකය',
      'sms_preview': 'පණිවුඩයේ සාරාංශය',
      'launch_sms': 'SMS යෙදවුම විවෘත කරන්න',
      'copy_text': 'පණිවුඩය පිටපත් කරන්න',
      'copied_toast': 'පණිවුඩය පිටපත් කරගන්නා ලදී!',
      
      // History
      'assessment_history': 'සුරකින ලද පෙර වාර්තා',
      'search_history': 'නමෙන් හෝ දුරකථන අංකයෙන් සොයන්න',
      'view_details': 'සම්පූර්ණ වාර්තාව බලන්න',
      'delete_record': 'වාර්තාව මකා දමන්න',
      'confirm_delete': 'ඔබට මෙම ඇගයීම් වාර්තාව මකා දැමීමට අවශ්‍යද?',
      'cancel': 'අවලංගු කරන්න',
      'delete': 'මකා දමන්න',
      'record_deleted': 'වාර්තාව මකා දමන ලදී.',
      'yes': 'ඔව්',
      'no': 'නැත',
      'normal': 'සාමාන්‍ය',
      'abnormal': 'අසාමාන්‍ය',
    },
    'ta': {
      'app_title': 'MediSense AI',
      'app_subtitle': 'சுகாதாரப் பணியாளர்களுக்கான AI மதிப்பீட்டு பயன்பாடு',
      'select_language': 'மொழியைத் தேர்ந்தெடுக்கவும்',
      'home': 'முகப்பு',
      'patients': 'நோயாளிகள்',
      'history': 'வரலாறு',
      'new_assessment': 'புதிய மதிப்பீடு',
      'recent_assessments': 'சமீபத்திய மதிப்பீடுகள்',
      'no_recent_assessments': 'சமீபத்திய மதிப்பீடுகள் எதுவும் கிடைக்கவில்லை.',
      'total_patients': 'மொத்த நோயாளிகள்',
      'total_assessments': 'மொத்த மதிப்பீடுகள்',
      'quick_actions': 'விரைவான செயல்பாடுகள்',
      'search_patient': 'தொலைபேசி / பெயர் மூலம் தேடுக',
      'register_new_patient': 'புதிய நோயாளியைப் பதிவு செய்க',
      'patient_information': 'நோயாளி விவரங்கள்',
      'select_patient': 'நோயாளியைத் தேர்ந்தெடுக்கவும்',
      'login_select_patient': 'நோயாளி உள்நுழைவு / கணக்கைத் தேர்ந்தெடுக்கவும்',
      'patient_name': 'முழு பெயர்',
      'phone_number': 'தொலைபேசி எண்',
      'phone_number_hint': 'எ.கா: 0771234567 அல்லது +94771234567',
      'age': 'வயது (ஆண்டுகள்)',
      'gender': 'பாலினம்',
      'male': 'ஆண்',
      'female': 'பெண்',
      'other': 'மற்றவை',
      'additional_notes': 'கூடுதல் குறிப்புகள் (விருப்பத்தேர்வு)',
      'save_register_patient': 'சேமித்து மதிப்பீட்டிற்குச் செல்லவும்',
      'enter_patient_details': 'நோயாளி விவரங்களை உள்ளிடவும்',
      'patient_required_err': 'நோயாளியின் பெயர் கட்டாயமானது',
      'phone_required_err': 'சரியான தொலைபேசி எண்ணை உள்ளிடவும் (குறைந்தது 9 இலக்கங்கள்)',
      'age_required_err': '0 முதல் 120 வரையிலான சரியான வயதை உள்ளிடவும்',
      'gender_required_err': 'தயவுசெய்து பாலினத்தைத் தேர்ந்தெடுக்கவும்',
      
      // Symptoms & Health Data
      'symptoms_and_vitals': 'அறிகுறிகள் மற்றும் சுகாதார அளவீடுகள்',
      'symptoms_section': 'தற்போதைய அறிகுறிகள்',
      'vitals_section': 'உடல் முக்கிய அளவீடுகள்',
      'fever': 'காய்ச்சல்',
      'cough': 'இருமல்',
      'headache': 'தலைவலி',
      'fatigue': 'சோர்வு',
      'skin_rash': 'தோல் தடிப்பு',
      'breathing_difficulty': 'மூச்சுத்திணறல்',
      
      'pulse': 'நாடித்துடிப்பு வீதம்',
      'pulse_unit': 'bpm',
      'sys_bp': 'சிஸ்டோலிக் இரத்த அழுத்தம்',
      'dia_bp': 'டயாஸ்டோலிக் இரத்த அழுத்தம்',
      'bp_unit': 'mmHg',
      'temperature': 'உடல் வெப்பநிலை',
      'temp_unit': '°C',
      
      'continue_review': 'மதிப்பாய்விற்குச் செல்லவும்',
      'review_assessment': 'மதிப்பீட்டு சுருக்க மதிப்பாய்வு',
      'patient_summary': 'நோயாளி சுருக்கம்',
      'symptom_summary': 'அறிவிக்கப்பட்ட அறிகுறிகள்',
      'vitals_summary': 'உடல் அளவீடுகள்',
      'edit': 'திருத்து',
      'run_ai_prediction': 'AI கணிப்பை இயக்கவும்',
      
      // Results
      'prediction_results': 'மதிப்பீட்டு முடிவுகள்',
      'main_condition': 'முதன்மை AI கணிப்பு',
      'confidence': 'நம்பிக்கை சதவீதம்',
      'triage_level': 'அபாய நிலை (Triage)',
      'recommended_action': 'பரிந்துரைக்கப்பட்ட நடவடிக்கை',
      'differential_diagnosis': 'சாத்தியமான பிற மருத்துவ நிலைகள்',
      'demo_disclaimer_title': 'மாதிரி / MOCK AI முடிவு',
      'demo_disclaimer_body': 'இந்த முடிவு ஆராய்வதற்காக உருவாக்கப்பட்ட ஒரு மாதிரி கணிப்பாகும். இது இறுதி மருத்துவ பரிசோதனை முடிவு அல்ல.',
      'save_locally': 'முடிவை ஆஃப்லைனில் சேமிக்கவும்',
      'send_sms': 'நோயாளிக்கு SMS அனுப்பவும்',
      'saved_successfully': 'மதிப்பீட்டு அறிக்கை வெற்றிகரமாக சேமிக்கப்பட்டது.',
      
      // Triage
      'triage_low': 'குறைந்த அபாயம்',
      'triage_medium': 'நடுத்தர அபாயம்',
      'triage_high': 'அதிக அபாயம்',
      'triage_critical': 'மிகவும் தீவிரமான அபாயம்',
      
      // SMS Dialog
      'sms_title': 'நோயாளிக்கு SMS அனுப்பவும்',
      'sms_recipient': 'பெறுநரின் தொலைபேசி எண்',
      'sms_preview': 'செய்தி முன்னோட்டம்',
      'launch_sms': 'SMS பயன்பாட்டைத் திறக்கவும்',
      'copy_text': 'செய்தியை பிரதி எடுக்கவும்',
      'copied_toast': 'செய்தி பிரதி எடுக்கப்பட்டது!',
      
      // History
      'assessment_history': 'சேமிக்கப்பட்ட பதிவுகள்',
      'search_history': 'பெயர் அல்லது தொலைபேசி எண் மூலம் தேடுக',
      'view_details': 'முழு விவரங்களையும் காண்க',
      'delete_record': 'பதிவை நீக்கு',
      'confirm_delete': 'இந்த பதிவை நிச்சயமாக நீக்க விரும்புகிறீர்களா?',
      'cancel': 'ரத்து செய்',
      'delete': 'நீக்கு',
      'record_deleted': 'பதிவு வெற்றிகரமாக நீக்கப்பட்டது.',
      'yes': 'ஆம்',
      'no': 'இல்லை',
      'normal': 'சாதாரண',
      'abnormal': 'அசாதாரண',
    },
  };

  static String getText(String key, String langCode) {
    if (_localizedValues.containsKey(langCode) &&
        _localizedValues[langCode]!.containsKey(key)) {
      return _localizedValues[langCode]![key]!;
    }
    // Fallback to English
    return _localizedValues['en']![key] ?? key;
  }
}
