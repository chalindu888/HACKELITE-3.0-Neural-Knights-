import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../../core/localization/language_provider.dart';
import '../../../data/models/health_feature.dart';
import '../../assessment/logic/assessment_provider.dart';
import '../../../services/ble_service.dart';
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

  // BLE State
  final BleService _bleService = BleService();
  bool _isBleConnected = false;
  int _currentHeartRate = 0;

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

    // Listen to BLE Heart Rate Updates
    _bleService.onHeartRateUpdate = (hr) {
      if (mounted) {
        setState(() {
          _isBleConnected = true;
          _currentHeartRate = hr;
        });
        // Update the pulse text field
        final pulseFeatureId = HealthFeature.prototypeFeatures.firstWhere((f) => f.translationKey == 'pulse').id;
        if (_numControllers.containsKey(pulseFeatureId)) {
          _numControllers[pulseFeatureId]!.text = hr.toString();
          Provider.of<AssessmentProvider>(context, listen: false).updateFeature(pulseFeatureId, hr);
        }
      }
    };
  }

  @override
  void dispose() {
    for (var c in _numControllers.values) {
      c.dispose();
    }
    _bleService.disconnect();
    _bleService.stopSimulation();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission required')),
        );
        return;
      }

      bool available = await _speech.initialize();
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
          break;
        }
      }
    });
  }

  void _showBleDialog() {
    List<BleDevice> foundDevices = [];
    _bleService.onDevicesFound = (devices) {
      setState(() {
        foundDevices = devices;
      });
    };
    _bleService.startScan();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            _bleService.onDevicesFound = (devices) {
              setDialogState(() {
                foundDevices = devices;
              });
            };

            return AlertDialog(
              title: const Text('Connect Medical Device'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: Column(
                  children: [
                    const Text('Scanning for BLE Vitals devices...'),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: foundDevices.length,
                        itemBuilder: (context, index) {
                          final dev = foundDevices[index];
                          return ListTile(
                            leading: const Icon(Icons.bluetooth),
                            title: Text(dev.name),
                            onTap: () {
                              _bleService.connectToDevice(dev.device);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    ElevatedButton.icon(
                      onPressed: () {
                        _bleService.simulateDeviceConnection();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.science),
                      label: const Text('Simulate Device (Hackathon)'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade100, foregroundColor: Colors.orange.shade900),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _bleService.stopScan();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => _bleService.stopScan());
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
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          IconButton(
                            icon: Icon(_isBleConnected ? Icons.bluetooth_connected : Icons.bluetooth),
                            color: _isBleConnected ? Colors.blue : Colors.grey,
                            tooltip: 'Connect Medical Device',
                            onPressed: _showBleDialog,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Divider(),
                      if (_isBleConnected)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              const Icon(Icons.monitor_heart, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Text('Live Pulse: $_currentHeartRate bpm', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                            ],
                          ),
                        ),
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
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
