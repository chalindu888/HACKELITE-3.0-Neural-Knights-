import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/language_provider.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../data/models/patient.dart';
import '../../assessment/logic/assessment_provider.dart';
import 'patient_register_screen.dart';
import '../../assessment/screens/symptom_health_screen.dart';

class PatientLoginScreen extends StatefulWidget {
  const PatientLoginScreen({super.key});

  @override
  State<PatientLoginScreen> createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends State<PatientLoginScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Patient> _allPatients = [];
  List<Patient> _filteredPatients = [];

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  void _loadPatients() {
    final list = LocalStorageService.getAllPatients();
    setState(() {
      _allPatients = list;
      _filteredPatients = list;
    });
  }

  void _filterPatients(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) {
      setState(() => _filteredPatients = _allPatients);
      return;
    }
    setState(() {
      _filteredPatients = _allPatients.where((p) {
        final nameMatch = p.name.toLowerCase().contains(clean);
        final phoneMatch = p.phoneNumber.replaceAll(RegExp(r'\s+'), '').contains(clean);
        return nameMatch || phoneMatch;
      }).toList();
    });
  }

  void _selectPatientAndProceed(BuildContext context, Patient patient) {
    final assessmentProv = Provider.of<AssessmentProvider>(context, listen: false);
    assessmentProv.selectPatient(patient);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SymptomHealthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('login_select_patient')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Input Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterPatients,
                    decoration: InputDecoration(
                      hintText: lang.translate('search_patient'),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF0D9488)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterPatients('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Register CTA Button
              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PatientRegisterScreen(),
                    ),
                  );
                  _loadPatients(); // Refresh list after returning
                },
                icon: const Icon(Icons.person_add_alt_1),
                label: Text(lang.translate('register_new_patient')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '${lang.translate('patients')} (${_filteredPatients.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),

              // Patient List View
              Expanded(
                child: _filteredPatients.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_search_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'No patient accounts found.',
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap "Register New Patient" above to create an account.',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredPatients.length,
                        itemBuilder: (context, index) {
                          final patient = _filteredPatients[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFCCFBF1),
                                child: Text(
                                  patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P',
                                  style: const TextStyle(
                                    color: Color(0xFF0D9488),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                patient.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.phone, size: 14, color: Color(0xFF64748B)),
                                        const SizedBox(width: 4),
                                        Text(patient.phoneNumber, style: const TextStyle(fontSize: 13)),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${patient.age} yrs • ${patient.gender}',
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF0D9488)),
                              onTap: () => _selectPatientAndProceed(context, patient),
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
}
