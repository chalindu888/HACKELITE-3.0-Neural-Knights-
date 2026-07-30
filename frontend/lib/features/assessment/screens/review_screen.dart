import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/language_provider.dart';
import '../../../data/models/health_feature.dart';
import '../../assessment/logic/assessment_provider.dart';
import '../../results/screens/results_screen.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  Future<void> _handleRunPrediction(BuildContext context) async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final prov = Provider.of<AssessmentProvider>(context, listen: false);

    // Run prediction via MockPredictionService
    final result = await prov.runPrediction(lang.currentCode);

    if (result != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ResultsScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final prov = Provider.of<AssessmentProvider>(context);
    final patient = prov.selectedPatient;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('review_assessment')),
      ),
      body: SafeArea(
        child: prov.isPredicting
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF0D9488)),
                    const SizedBox(height: 20),
                    Text(
                      'Analyzing assessment data...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0D9488),
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Evaluating symptoms and vital parameters via AI model',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Patient Summary Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person, color: Color(0xFF0D9488)),
                                    const SizedBox(width: 8),
                                    Text(
                                      lang.translate('patient_summary'),
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                TextButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: Text(lang.translate('edit')),
                                ),
                              ],
                            ),
                            const Divider(),
                            if (patient != null) ...[
                              _buildSummaryRow(lang.translate('patient_name'), patient.name),
                              _buildSummaryRow(lang.translate('phone_number'), patient.phoneNumber),
                              _buildSummaryRow(lang.translate('age'), '${patient.age} yrs'),
                              _buildSummaryRow(lang.translate('gender'), patient.gender),
                              if (patient.notes != null)
                                _buildSummaryRow(lang.translate('additional_notes'), patient.notes!),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Symptoms Summary Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.sick_outlined, color: Color(0xFF0D9488)),
                                    const SizedBox(width: 8),
                                    Text(
                                      lang.translate('symptom_summary'),
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                TextButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: Text(lang.translate('edit')),
                                ),
                              ],
                            ),
                            const Divider(),
                            ...HealthFeature.prototypeFeatures
                                .where((f) => f.type == FeatureType.boolean)
                                .map((f) {
                              final isPresent = prov.features[f.id] == true;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      lang.translate(f.translationKey),
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isPresent ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isPresent ? lang.translate('yes') : lang.translate('no'),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: isPresent ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Vitals Summary Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.favorite_outline, color: Color(0xFF0D9488)),
                                    const SizedBox(width: 8),
                                    Text(
                                      lang.translate('vitals_summary'),
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                TextButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: Text(lang.translate('edit')),
                                ),
                              ],
                            ),
                            const Divider(),
                            ...HealthFeature.prototypeFeatures
                                .where((f) => f.type == FeatureType.numerical)
                                .map((f) {
                              final val = prov.features[f.id];
                              final unitText = f.unit != null ? lang.translate(f.unit!) : '';
                              return _buildSummaryRow(
                                lang.translate(f.translationKey),
                                '$val $unitText',
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Run Prediction CTA
                    ElevatedButton.icon(
                      onPressed: () => _handleRunPrediction(context),
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(lang.translate('run_ai_prediction')),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF0D9488),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}
