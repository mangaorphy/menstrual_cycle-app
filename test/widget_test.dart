// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:menstrual_tracker/main.dart';
import 'package:menstrual_tracker/providers/cycle_provider.dart';
import 'package:menstrual_tracker/providers/theme_provider.dart';
import 'package:menstrual_tracker/providers/auth_provider.dart';
import 'package:menstrual_tracker/providers/notification_provider.dart';
import 'package:menstrual_tracker/providers/education_provider.dart';
import 'package:menstrual_tracker/providers/language_provider.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app with all providers and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => CycleProvider()),
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => AuthProvider()),
          ChangeNotifierProvider(create: (context) => NotificationProvider()),
          ChangeNotifierProvider(create: (context) => EducationProvider()),
          ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ],
        child: const MyApp(hasSeenOnboarding: false),
      ),
    );

    // Wait for the widget to build
    await tester.pumpAndSettle();

    // Verify that the app loads (we can check for any common widget)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
