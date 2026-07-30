import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../data/models/assessment.dart';
import '../../../data/models/prediction_result.dart';
import '../../patient/screens/patient_login_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../assessment/logic/assessment_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _totalPatients = 0;
  int _totalAssessments = 0;
  List<Assessment> _recentAssessments = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    final patients = LocalStorageService.getAllPatients();
    final assessments = LocalStorageService.getAllAssessments();

    setState(() {
      _totalPatients = patients.length;
      _totalAssessments = assessments.length;
      _recentAssessments = assessments.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final assessmentProv = Provider.of<AssessmentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.health_and_safety, color: Colors.white),
            const SizedBox(width: 8),
            Text(AppConstants.appName),
          ],
        ),
        actions: [
          // Language Switcher Dropdown
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: PopupMenuButton<AppLanguage>(
              icon: Row(
                children: [
                  Text(lang.currentLanguage.flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
              onSelected: (AppLanguage selected) {
                lang.setLanguage(selected);
                LocalStorageService.saveLanguageCode(selected.code);
              },
              itemBuilder: (BuildContext context) {
                return AppLanguage.values.map((AppLanguage language) {
                  return PopupMenuItem<AppLanguage>(
                    value: language,
                    child: Row(
                      children: [
                        Text(language.flag, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Text(
                          language.label,
                          style: TextStyle(
                            fontWeight: lang.currentLanguage == language
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadDashboardData(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner / Greeting
                Card(
                  color: AppTheme.primaryTeal,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.translate('app_subtitle'),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Community Health Assessment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.offline_pin, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Offline Mode Active (Hive)',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Stats Row
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.people_outline, color: AppTheme.primaryTeal, size: 28),
                              const SizedBox(height: 10),
                              Text(
                                '$_totalPatients',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lang.translate('total_patients'),
                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.assignment_outlined, color: AppTheme.accentCyan, size: 28),
                              const SizedBox(height: 10),
                              Text(
                                '$_totalAssessments',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lang.translate('total_assessments'),
                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Main CTA: Start New Assessment
                ElevatedButton.icon(
                  onPressed: () async {
                    assessmentProv.resetFlow();
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PatientLoginScreen(),
                      ),
                    );
                    _loadDashboardData();
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 24),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: Text(
                      lang.translate('new_assessment'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Secondary Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PatientLoginScreen(),
                            ),
                          );
                          _loadDashboardData();
                        },
                        icon: const Icon(Icons.badge_outlined),
                        label: Text(lang.translate('patients')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HistoryScreen(),
                            ),
                          );
                          _loadDashboardData();
                        },
                        icon: const Icon(Icons.history),
                        label: Text(lang.translate('history')),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent Assessments Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang.translate('recent_assessments'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (_recentAssessments.isNotEmpty)
                      TextButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HistoryScreen(),
                            ),
                          );
                          _loadDashboardData();
                        },
                        child: const Text('View All'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Recent Assessments Feed
                _recentAssessments.isEmpty
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.description_outlined, size: 48, color: Colors.grey),
                                const SizedBox(height: 8),
                                Text(
                                  lang.translate('no_recent_assessments'),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: _recentAssessments.map((a) {
                          final res = a.predictionResult;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text(a.patient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${res.predictedCondition} • ${(res.confidence * 100).toStringAsFixed(0)}%'),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getTriageBg(res.triageLevel),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  res.triageLevel.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getTriageColor(res.triageLevel),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
}
