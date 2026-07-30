import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/assessment.dart';
import '../../../data/models/prediction_result.dart';
import '../../../services/messaging/sms_service.dart';
import '../../assessment/logic/assessment_provider.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isSaved = false;

  Color _getTriageColor(TriageLevel level) {
    switch (level) {
      case TriageLevel.low:
        return AppTheme.triageLow;
      case TriageLevel.medium:
        return AppTheme.triageMedium;
      case TriageLevel.high:
        return AppTheme.triageHigh;
      case TriageLevel.critical:
        return AppTheme.triageCritical;
    }
  }

  Color _getTriageBg(TriageLevel level) {
    switch (level) {
      case TriageLevel.low:
        return AppTheme.triageLowBg;
      case TriageLevel.medium:
        return AppTheme.triageMediumBg;
      case TriageLevel.high:
        return AppTheme.triageHighBg;
      case TriageLevel.critical:
        return AppTheme.triageCriticalBg;
    }
  }

  Future<void> _handleSaveAssessment(BuildContext context) async {
    final prov = Provider.of<AssessmentProvider>(context, listen: false);
    final lang = Provider.of<LanguageProvider>(context, listen: false);

    await prov.saveCurrentAssessment();
    setState(() {
      _isSaved = true;
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.translate('saved_successfully')),
          backgroundColor: AppTheme.primaryTeal,
        ),
      );
    }
  }

  void _showSmsDialog(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final prov = Provider.of<AssessmentProvider>(context, listen: false);
    final patient = prov.selectedPatient;
    final result = prov.currentResult;

    if (patient == null || result == null) return;

    final Assessment currentAssessment = prov.lastSavedAssessment ??
        Assessment(
          patient: patient,
          features: Map<String, dynamic>.from(prov.features),
          predictionResult: result,
        );

    final smsText = SmsService.formatPatientMessage(
      assessment: currentAssessment,
      language: lang.currentLanguage,
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.sms, color: AppTheme.primaryTeal),
              const SizedBox(width: 8),
              Expanded(child: Text(lang.translate('sms_title'), style: const TextStyle(fontSize: 18))),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${lang.translate('sms_recipient')}: ${patient.phoneNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Text(
                  lang.translate('sms_preview'),
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Text(
                    smsText,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: smsText));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(lang.translate('copied_toast'))),
                );
              },
              icon: const Icon(Icons.copy, size: 16),
              label: Text(lang.translate('copy_text')),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                await SmsService.sendSms(
                  phoneNumber: patient.phoneNumber,
                  messageText: smsText,
                );
              },
              icon: const Icon(Icons.send, size: 16),
              label: Text(lang.translate('launch_sms')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final prov = Provider.of<AssessmentProvider>(context);
    final result = prov.currentResult;
    final patient = prov.selectedPatient;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: Text(lang.translate('prediction_results'))),
        body: const Center(child: Text('No result available.')),
      );
    }

    final triageColor = _getTriageColor(result.triageLevel);
    final triageBg = _getTriageBg(result.triageLevel);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('prediction_results')),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Patient Header Card
              if (patient != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Phone: ${patient.phoneNumber} • Age: ${patient.age}',
                              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLightTeal,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            patient.gender,
                            style: const TextStyle(
                              color: AppTheme.primaryDarkTeal,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Main Prediction Header Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        lang.translate('main_condition'),
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        result.predictedCondition,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDarkTeal,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Confidence Badge & Gauge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLightTeal,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.analytics, color: AppTheme.primaryTeal, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  '${lang.translate('confidence')}: ${(result.confidence * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryDarkTeal,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Triage Risk Level Badge
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: triageBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: triageColor, width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shield_outlined, color: triageColor),
                            const SizedBox(width: 8),
                            Text(
                              '${lang.translate('triage_level')}: ',
                              style: TextStyle(fontSize: 14, color: triageColor, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              _getTriageText(result.triageLevel, lang),
                              style: TextStyle(fontSize: 16, color: triageColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Recommended Action Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.medical_services_outlined, color: AppTheme.primaryTeal),
                          const SizedBox(width: 8),
                          Text(
                            lang.translate('recommended_action'),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        result.recommendedAction,
                        style: const TextStyle(fontSize: 15, height: 1.4, color: AppTheme.textDark),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Differential Diagnosis breakdown
              if (result.rankedPredictions.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.translate('differential_diagnosis'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ...result.rankedPredictions.map((rp) {
                          final pct = (rp.probability * 100).toStringAsFixed(0);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        rp.condition,
                                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                                      ),
                                    ),
                                    Text(
                                      '$pct%',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: rp.probability,
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  color: AppTheme.primaryTeal,
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // SMS Button
              ElevatedButton.icon(
                onPressed: () => _showSmsDialog(context),
                icon: const Icon(Icons.sms),
                label: Text(lang.translate('send_sms')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppTheme.accentCyan,
                ),
              ),
              const SizedBox(height: 12),

              // Save Offline Button
              OutlinedButton.icon(
                onPressed: _isSaved ? null : () => _handleSaveAssessment(context),
                icon: Icon(_isSaved ? Icons.check_circle : Icons.save_alt),
                label: Text(_isSaved ? 'Saved Offline' : lang.translate('save_locally')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 12),

              // New Assessment Button
              TextButton(
                onPressed: () {
                  prov.resetFlow();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Back to Home / Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTriageText(TriageLevel level, LanguageProvider lang) {
    switch (level) {
      case TriageLevel.low:
        return lang.translate('triage_low');
      case TriageLevel.medium:
        return lang.translate('triage_medium');
      case TriageLevel.high:
        return lang.translate('triage_high');
      case TriageLevel.critical:
        return lang.translate('triage_critical');
    }
  }
}
