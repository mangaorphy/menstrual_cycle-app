import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:menstrual_tracker/screens/onboarding_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:menstrual_tracker/screens/main_screen.dart';
import 'package:menstrual_tracker/screens/log_period_screen.dart';
import 'package:menstrual_tracker/screens/log_mood_screen.dart';
import 'package:menstrual_tracker/screens/log_symptoms_screen.dart';
import 'package:menstrual_tracker/screens/log_flow_screen.dart';
import 'package:menstrual_tracker/screens/notification_settings_screen.dart';
import 'package:menstrual_tracker/providers/cycle_provider.dart';
import 'package:menstrual_tracker/providers/theme_provider.dart';
import 'package:menstrual_tracker/providers/auth_provider.dart';
import 'package:menstrual_tracker/providers/notification_provider.dart';
import 'package:menstrual_tracker/providers/education_provider.dart';
import 'package:menstrual_tracker/providers/language_provider.dart';
import 'package:menstrual_tracker/providers/navigation_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CycleProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => EducationProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
      ],
      child: MyApp(hasSeenOnboarding: hasSeenOnboarding),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool hasSeenOnboarding;
  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize providers after app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  Future<void> _initializeProviders() async {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    // Initialize notification provider which will handle period predictions
    await notificationProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp(
          title: 'Menstrual Cycle App',
          locale:
              languageProvider.materialLocale, // Use material-compatible locale
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // Only English for Material components
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            // Always use English for Material components to avoid errors
            return const Locale('en');
          },
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          home: widget.hasSeenOnboarding
              ? const MainScreen()
              : const OnboardingScreen(),
          routes: {
            '/log-period': (context) => const LogPeriodScreen(),
            '/log-mood': (context) => const LogMoodScreen(),
            '/log-symptoms': (context) => const LogSymptomsScreen(),
            '/log-flow': (context) => const LogFlowScreen(),
            '/notification-settings': (context) =>
                const NotificationSettingsScreen(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
