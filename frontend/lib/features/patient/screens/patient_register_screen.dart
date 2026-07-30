import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/language_provider.dart';
import '../../../data/models/patient.dart';
import '../../../data/local/local_storage_service.dart';
import '../../assessment/logic/assessment_provider.dart';
import '../../assessment/screens/symptom_health_screen.dart';

class PatientRegisterScreen extends StatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  State<PatientRegisterScreen> createState() => _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends State<PatientRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedGender = 'Male';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(LanguageProvider lang) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final newPatient = Patient(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        gender: _selectedGender,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      // Save offline to Hive
      await LocalStorageService.savePatient(newPatient);

      if (!mounted) return;

      // Select patient in Provider
      final assessmentProv = Provider.of<AssessmentProvider>(context, listen: false);
      assessmentProv.selectPatient(newPatient);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Patient "${newPatient.name}" registered successfully!')),
      );

      // Navigate to Symptom & Health Data screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SymptomHealthScreen(),
        ),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving patient: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('register_new_patient')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  lang.translate('enter_patient_details'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D9488),
                      ),
                ),
                const SizedBox(height: 20),

                // Patient Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '${lang.translate('patient_name')} *',
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return lang.translate('patient_required_err');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone Number (Mandatory)
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: '${lang.translate('phone_number')} *',
                    hintText: lang.translate('phone_number_hint'),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  validator: (val) {
                    final err = Patient.validatePhone(val);
                    if (err != null) {
                      return lang.translate('phone_required_err');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Age (Mandatory number 0-120)
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '${lang.translate('age')} *',
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return lang.translate('age_required_err');
                    }
                    final age = int.tryParse(val.trim());
                    if (age == null || age < 0 || age > 120) {
                      return lang.translate('age_required_err');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Gender Selection
                Text(
                  '${lang.translate('gender')} *',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                RadioGroup<String>(
                  groupValue: _selectedGender,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedGender = val);
                    }
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text(lang.translate('male')),
                          value: 'Male',
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text(lang.translate('female')),
                          value: 'Female',
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Additional Notes
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: lang.translate('additional_notes'),
                    prefixIcon: const Icon(Icons.notes),
                  ),
                ),
                const SizedBox(height: 28),

                // Submit Button
                ElevatedButton(
                  onPressed: _isSaving ? null : () => _submitForm(lang),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          lang.translate('save_register_patient'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
