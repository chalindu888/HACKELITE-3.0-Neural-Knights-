import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  
  static Future<List<dynamic>> fetchSymptoms() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.syncSymptoms));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching symptoms: $e");
      return [];
    }
  }

  
  static Future<bool> sendDiagnosisData({
    required String patientId,
    required String name,
    required int age,
    required List<String> symptoms,
    required String predictedDisease,
    required String confidence,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.syncDiagnosis),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "patient_id": patientId,
          "name": name,
          "age": age,
          "symptoms": symptoms,
          "diagnosis": "$predictedDisease (Confidence: $confidence)",
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error uploading diagnosis: $e");
      return false;
    }
  }
}