import 'package:flutter/material.dart';
import 'package:menstrual_tracker/screens/home_screen.dart';
import 'package:menstrual_tracker/screens/welcome_screen.dart';
import 'package:menstrual_tracker/providers/cycle_provider.dart';
import 'package:menstrual_tracker/providers/theme_provider.dart';
import 'package:menstrual_tracker/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CycleProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Cycle Tracker',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: Consumer<CycleProvider>(
              builder: (context, cycleProvider, child) {
                // Show welcome screen if user hasn't completed initial setup
                if (cycleProvider.cycles.isEmpty &&
                    !cycleProvider.isInitialSetupComplete) {
                  return const WelcomeScreen();
                }
                return const HomeScreen();
              },
            ),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
