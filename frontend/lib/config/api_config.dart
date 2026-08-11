import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000";
    } else {
      // Use Laptop's actual Wi-Fi IP for Physical Device testing
      return "http://10.199.228.1:8000";
    }
    return "http://127.0.0.1:8000";
  }

  static String get syncSymptoms => "$baseUrl/api/v1/sync/symptoms";
  static String get syncDiseases => "$baseUrl/api/v1/sync/diseases";
  static String get syncDiagnosis => "$baseUrl/patients";
}