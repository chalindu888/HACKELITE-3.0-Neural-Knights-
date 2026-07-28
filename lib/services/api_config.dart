import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8000"; // Android Emulator
    }
    return "http://127.0.0.1:8000";   // iOS/Web
  }

  static String get syncSymptoms => "$baseUrl/api/v1/sync/symptoms";
  static String get syncDiseases => "$baseUrl/api/v1/sync/diseases";
  static String get syncDiagnosis => "$baseUrl/api/v1/sync/diagnosis"
}