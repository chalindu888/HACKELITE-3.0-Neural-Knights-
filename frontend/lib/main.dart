import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/language_provider.dart';
import 'data/local/local_storage_service.dart';
import 'features/assessment/logic/assessment_provider.dart';
import 'features/home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive offline storage
  await LocalStorageService.init();

  runApp(const MediSenseApp());
}

class MediSenseApp extends StatelessWidget {
  const MediSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Read saved language from Hive
    final savedLangCode = LocalStorageService.getLanguageCode();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final langProv = LanguageProvider();
            langProv.setLanguageByCode(savedLangCode);
            return langProv;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => AssessmentProvider(),
        ),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, lang, child) {
          return MaterialApp(
            title: 'MediSense AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
