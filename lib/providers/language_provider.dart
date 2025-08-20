import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en'); // Default to English
  bool _isLoading = false;

  Locale get locale => _locale;
  bool get isLoading => _isLoading;

  // For Material components, use English as fallback for unsupported locales
  Locale get materialLocale {
    // Since Material components don't support Shona, use English as fallback
    if (_locale.languageCode == 'sn') {
      return const Locale('en');
    }
    return _locale;
  }

  // Supported locales - keep both for our app content
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('sn'), // Shona
  ];

  // Material supported locales - only English
  static const List<Locale> materialSupportedLocales = [
    Locale('en'), // English only for Material components
  ];

  LanguageProvider() {
    _loadLanguage();
  }

  // Load saved language preference
  Future<void> _loadLanguage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'en';
      _locale = Locale(languageCode);
    } catch (e) {
      // If there's an error, default to English
      _locale = const Locale('en');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Change language
  Future<void> changeLanguage(Locale newLocale) async {
    if (_locale == newLocale) return;

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', newLocale.languageCode);
      _locale = newLocale;
    } catch (e) {
      // Handle error if needed
      debugPrint('Error saving language preference: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get language name for display
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'sn':
        return 'Shona';
      default:
        return 'English';
    }
  }

  // Get language name in native script
  String getLanguageNameNative(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'sn':
        return 'Shona';
      default:
        return 'English';
    }
  }

  // Check if a locale is supported
  bool isSupported(Locale locale) {
    return supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }
}
