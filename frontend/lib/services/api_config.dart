import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000"; 
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return "http://10.0.2.2:8000"; 
    }
    return "http://127.0.0.1:8000"; 
  }

  static String get syncSymptoms => "$baseUrl/api/v1/sync/symptoms";
  static String get syncDiseases => "$baseUrl/api/v1/sync/diseases";
  static String get syncDiagnosis => "$baseUrl/api/v1/sync/diagnosis";
}