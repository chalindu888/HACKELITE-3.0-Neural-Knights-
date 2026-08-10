import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/patient.dart';
import '../models/assessment.dart';

class LocalStorageService {
  static Box? _patientsBox;
  static Box? _assessmentsBox;
  static Box? _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _patientsBox = await Hive.openBox(AppConstants.patientsBox);
    _assessmentsBox = await Hive.openBox(AppConstants.assessmentsBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
  }

  // --- Settings ---
  static Future<void> saveLanguageCode(String code) async {
    await _settingsBox?.put(AppConstants.languageKey, code);
  }

  static String getLanguageCode() {
    return _settingsBox?.get(AppConstants.languageKey, defaultValue: 'en') as String;
  }

  // --- Patients ---
  static Future<void> savePatient(Patient patient) async {
    final jsonStr = jsonEncode(patient.toJson());
    await _patientsBox?.put(patient.id, jsonStr);
  }

  static List<Patient> getAllPatients() {
    if (_patientsBox == null) return [];
    final List<Patient> list = [];
    for (var key in _patientsBox!.keys) {
      final raw = _patientsBox!.get(key);
      if (raw != null) {
        try {
          final Map<String, dynamic> map = jsonDecode(raw as String);
          list.add(Patient.fromJson(map));
        } catch (_) {}
      }
    }
    // Sort latest first
    list.sort((a, b) => b.registeredDate.compareTo(a.registeredDate));
    return list;
  }

  static Patient? getPatientByPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final all = getAllPatients();
    for (var p in all) {
      if (p.phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '') == clean) {
        return p;
      }
    }
    return null;
  }

  // --- Assessments ---
  static Future<void> saveAssessment(Assessment assessment) async {
    final jsonStr = jsonEncode(assessment.toJson());
    await _assessmentsBox?.put(assessment.id, jsonStr);
  }

  static List<Assessment> getAllAssessments() {
    if (_assessmentsBox == null) return [];
    final List<Assessment> list = [];
    for (var key in _assessmentsBox!.keys) {
      final raw = _assessmentsBox!.get(key);
      if (raw != null) {
        try {
          final Map<String, dynamic> map = jsonDecode(raw as String);
          list.add(Assessment.fromJson(map));
        } catch (_) {}
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  static List<Assessment> getUnsyncedAssessments() {
    return getAllAssessments().where((a) => !a.isSynced).toList();
  }

  static Future<void> updateAssessment(Assessment assessment) async {
    final jsonStr = jsonEncode(assessment.toJson());
    await _assessmentsBox?.put(assessment.id, jsonStr);
  }

  static Future<void> deleteAssessment(String id) async {
    await _assessmentsBox?.delete(id);
  }

  static List<Assessment> getAssessmentsForPatient(String patientId) {
    return getAllAssessments().where((a) => a.patient.id == patientId).toList();
  }
}
