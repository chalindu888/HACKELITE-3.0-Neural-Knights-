import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../data/local/local_storage_service.dart';

class SyncEngine {
  static final SyncEngine _instance = SyncEngine._internal();
  factory SyncEngine() => _instance;
  SyncEngine._internal();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  void initialize() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi)) {
        debugPrint('SyncEngine: Network restored. Triggering sync...');
        syncUnsyncedData();
      }
    });
    
    // Trigger initial sync on startup
    syncUnsyncedData();
  }

  Future<void> syncUnsyncedData() async {
    if (_isSyncing) return;
    
    // Check if we actually have internet
    final results = await Connectivity().checkConnectivity();
    if (!results.contains(ConnectivityResult.mobile) && !results.contains(ConnectivityResult.wifi)) {
      return;
    }

    _isSyncing = true;
    try {
      final unsynced = LocalStorageService.getUnsyncedAssessments();
      if (unsynced.isEmpty) {
        _isSyncing = false;
        return;
      }

      debugPrint('SyncEngine: Found ${unsynced.length} unsynced assessments. Syncing...');

      for (var assessment in unsynced) {
        // Prepare symptom strings from boolean features map
        List<String> activeSymptoms = [];
        assessment.features.forEach((key, val) {
          if (val == true) {
            activeSymptoms.add(key.replaceAll('_', ' ').toLowerCase());
          }
        });

        bool success = await ApiService.sendDiagnosisData(
          patientId: assessment.patient.id,
          symptoms: activeSymptoms,
          predictedDisease: assessment.predictionResult.predictedCondition,
          confidence: assessment.predictionResult.confidence.toStringAsFixed(2),
        );

        if (success) {
          // Mark as synced and update local storage
          assessment.isSynced = true;
          await LocalStorageService.updateAssessment(assessment);
          debugPrint('SyncEngine: Successfully synced assessment ${assessment.id}');
        } else {
          debugPrint('SyncEngine: Failed to sync assessment ${assessment.id}. Will retry later.');
        }
      }
    } catch (e) {
      debugPrint('SyncEngine: Error during sync process: $e');
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
