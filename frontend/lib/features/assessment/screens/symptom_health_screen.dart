import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/language_provider.dart';
import '../../../data/models/health_feature.dart';
import '../../assessment/logic/assessment_provider.dart';
import 'review_screen.dart';

class SymptomHealthScreen extends StatefulWidget {
  const SymptomHealthScreen({super.key});

  @override
  State<SymptomHealthScreen> createState() => _SymptomHealthScreenState();
}

class _SymptomHealthScreenState extends State<SymptomHealthScreen> {
  late Map<String, TextEditingController> _numControllers;

  @override
  void initState() {
    super.initState();
    _numControllers = {};
    final prov = Provider.of<AssessmentProvider>(context, listen: false);
    for (var f in HealthFeature.prototypeFeatures) {
      if (f.type == FeatureType.numerical) {
        final val = prov.features[f.id] ?? f.defaultValue;
        _numControllers[f.id] = TextEditingController(text: val.toString());
      }
    }
  }

  @override
  void dispose() {
    for (var c in _numControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final prov = Provider.of<AssessmentProvider>(context);
    final patient = prov.selectedPatient;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('symptoms_and_vitals')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Active Patient Header Banner
              if (patient != null)
                Card(
                  color: const Color(0xFFCCFBF1),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        const Icon(Icons.account_circle, size: 40, color: Color(0xFF0D9488)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F766E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${patient.age} yrs • ${patient.gender} • ${patient.phoneNumber}',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF0F766E)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle, color: Color(0xFF0D9488)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Symptoms Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.sick_outlined, color: Color(0xFF0D9488)),
                          const SizedBox(width: 8),
                          Text(
                            lang.translate('symptoms_section'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Divider(),
                      ...HealthFeature.prototypeFeatures
                          .where((f) => f.type == FeatureType.boolean)
                          .map((f) {
                        final isChecked = prov.features[f.id] == true;
                        return SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            lang.translate(f.translationKey),
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                          value: isChecked,
                          activeColor: const Color(0xFF0D9488),
                          onChanged: (val) {
                            prov.updateFeature(f.id, val);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Vitals & Measurements Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.favorite_outline, color: Color(0xFF0D9488)),
                          const SizedBox(width: 8),
                          Text(
                            lang.translate('vitals_section'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Divider(),
                      const SizedBox(height: 8),
                      ...HealthFeature.prototypeFeatures
                          .where((f) => f.type == FeatureType.numerical)
                          .map((f) {
                        final controller = _numControllers[f.id];
                        final unitText = f.unit != null ? lang.translate(f.unit!) : '';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TextFormField(
                            controller: controller,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: lang.translate(f.translationKey),
                              suffixText: unitText,
                              helperText: f.minValue != null && f.maxValue != null
                                  ? 'Normal range: ${f.minValue} - ${f.maxValue}'
                                  : null,
                            ),
                            onChanged: (val) {
                              final numVal = num.tryParse(val.trim());
                              if (numVal != null) {
                                prov.updateFeature(f.id, numVal);
                              }
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Proceed Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReviewScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: Text(lang.translate('continue_review')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
