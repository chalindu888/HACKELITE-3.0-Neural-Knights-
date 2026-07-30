import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../data/models/assessment.dart';
import '../../../data/models/prediction_result.dart';
import '../../../services/messaging/sms_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Assessment> _allAssessments = [];
  List<Assessment> _filteredAssessments = [];
  String _selectedTriageFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final list = LocalStorageService.getAllAssessments();
    setState(() {
      _allAssessments = list;
      _applyFilters();
    });
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredAssessments = _allAssessments.where((a) {
        final matchesQuery = query.isEmpty ||
            a.patient.name.toLowerCase().contains(query) ||
            a.patient.phoneNumber.contains(query) ||
            a.predictionResult.predictedCondition.toLowerCase().contains(query);

        final matchesTriage = _selectedTriageFilter == 'All' ||
            a.predictionResult.triageLevel.name.toLowerCase() == _selectedTriageFilter.toLowerCase();

        return matchesQuery && matchesTriage;
      }).toList();
    });
  }

  Future<void> _deleteAssessment(String id) async {
    await LocalStorageService.deleteAssessment(id);
    _loadHistory();
  }

  void _showDeleteDialog(BuildContext context, String id, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(lang.translate('delete_record')),
        content: Text(lang.translate('confirm_delete')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(lang.translate('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.triageCritical),
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteAssessment(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(lang.translate('record_deleted'))),
                );
              }
            },
            child: Text(lang.translate('delete')),
          ),
        ],
      ),
    );
  }

  void _showDetailsModal(BuildContext context, Assessment assessment, LanguageProvider lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final res = assessment.predictionResult;
        final patient = assessment.patient;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    lang.translate('prediction_results'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Patient Card
                  Card(
                    color: AppTheme.primaryLightTeal,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.primaryDarkTeal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Phone: ${patient.phoneNumber} • ${patient.age} yrs • ${patient.gender}',
                            style: const TextStyle(fontSize: 13, color: AppTheme.primaryDarkTeal),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Main Result
                  Text(
                    res.predictedCondition,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                  ),
                  const SizedBox(height: 6),
                  Text('Confidence: ${(res.confidence * 100).toStringAsFixed(0)}%'),
                  const SizedBox(height: 6),
                  Text('Triage: ${res.triageLevel.label} Risk'),
                  const SizedBox(height: 12),
                  const Divider(),

                  Text(
                    lang.translate('recommended_action'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(res.recommendedAction, style: const TextStyle(height: 1.4)),
                  const SizedBox(height: 20),

                  // Action buttons
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      final smsText = SmsService.formatPatientMessage(
                        assessment: assessment,
                        language: lang.currentLanguage,
                      );
                      SmsService.sendSms(phoneNumber: patient.phoneNumber, messageText: smsText);
                    },
                    icon: const Icon(Icons.sms),
                    label: Text(lang.translate('send_sms')),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('assessment_history')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Box
              TextField(
                controller: _searchController,
                onChanged: (_) => _applyFilters(),
                decoration: InputDecoration(
                  hintText: lang.translate('search_history'),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 12),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Low', 'Medium', 'High', 'Critical'].map((triage) {
                    final isSelected = _selectedTriageFilter == triage;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(triage),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryLightTeal,
                        onSelected: (val) {
                          setState(() {
                            _selectedTriageFilter = triage;
                            _applyFilters();
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Record List
              Expanded(
                child: _filteredAssessments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              lang.translate('no_recent_assessments'),
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredAssessments.length,
                        itemBuilder: (context, index) {
                          final item = _filteredAssessments[index];
                          final res = item.predictionResult;
                          final dateStr =
                              '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year} ${item.createdAt.hour}:${item.createdAt.minute.toString().padLeft(2, '0')}';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.patient.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  Text(
                                    dateStr,
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      res.predictedCondition,
                                      style: const TextStyle(
                                        color: AppTheme.primaryDarkTeal,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text('Conf: ${(res.confidence * 100).toStringAsFixed(0)}% • '),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getTriageBg(res.triageLevel),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            res.triageLevel.label,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: _getTriageColor(res.triageLevel),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _showDeleteDialog(context, item.id, lang),
                              ),
                              onTap: () => _showDetailsModal(context, item, lang),
                            ),
                          );
                        },
                      ),
              ),
            ],
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
