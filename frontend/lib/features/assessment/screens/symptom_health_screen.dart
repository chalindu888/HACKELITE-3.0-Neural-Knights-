import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
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
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';

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

  void _listen() async {
    if (!_isListening) {
      // Request permission
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission required')),
        );
        return;
      }

      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );

      if (available) {
        setState(() => _isListening = true);
        
        final langProvider = Provider.of<LanguageProvider>(context, listen: false);
        String localeId = 'en_US';
        if (langProvider.currentLanguage.code == 'si') localeId = 'si_LK';
        if (langProvider.currentLanguage.code == 'ta') localeId = 'ta_IN';

        _speech.listen(
          localeId: localeId,
          onResult: (val) {
            setState(() {
              _text = val.recognizedWords;
              _analyzeSpeechForSymptoms(_text.toLowerCase(), langProvider.currentLanguage.code);
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _analyzeSpeechForSymptoms(String transcript, String langCode) {
    final prov = Provider.of<AssessmentProvider>(context, listen: false);
    
    // Map of keywords per language
    final keywords = {
      'has_fever': {'en': ['fever'], 'si': ['උණ'], 'ta': ['காய்ச்சல்']},
      'has_cough': {'en': ['cough'], 'si': ['කැස්ස'], 'ta': ['இருமல்']},
      'has_headache': {'en': ['headache'], 'si': ['හිසරදය'], 'ta': ['தலைவலி']},
      'has_fatigue': {'en': ['fatigue', 'tired'], 'si': ['වෙහෙස', 'මහන්සි'], 'ta': ['சோர்வு']},
      'has_skin_rash': {'en': ['rash', 'skin'], 'si': ['පළු', 'ලප', 'දද'], 'ta': ['தடிப்பு']},
      'has_breathing_difficulty': {'en': ['breath', 'breathing'], 'si': ['හුස්ම', 'ශ්වසන'], 'ta': ['மூச்சு']},
    };

    keywords.forEach((featureId, langs) {
      final words = langs[langCode] ?? langs['en']!;
      for (var word in words) {
        if (transcript.contains(word)) {
          prov.updateFeature(featureId, true);
          break; // Found one keyword for this feature, check it and move on
        }
      }
    });
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _listen,
        icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
        label: Text(_isListening ? 'Listening...' : 'Voice Input'),
        backgroundColor: _isListening ? Colors.red : const Color(0xFF0D9488),
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
              
              if (_isListening)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    '🗣️ "$_text"',
                    style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ),

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
                          activeThumbColor: const Color(0xFF0D9488),
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
              const SizedBox(height: 80), // Padding for FAB
            ],
          ),
        ),
      ),
    );
  }
}
