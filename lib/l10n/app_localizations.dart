import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sn'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Menstrual Health Tracker'**
  String get appTitle;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Get started button text
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Done button text
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Calendar tab label
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// Insights tab label
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// Settings tab label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Cycle overview section title
  ///
  /// In en, this message translates to:
  /// **'Cycle Overview'**
  String get cycleOverview;

  /// Next period label
  ///
  /// In en, this message translates to:
  /// **'Next Period'**
  String get nextPeriod;

  /// Days away text
  ///
  /// In en, this message translates to:
  /// **'days away'**
  String get daysAway;

  /// Log period button text
  ///
  /// In en, this message translates to:
  /// **'Log Period'**
  String get logPeriod;

  /// Log mood button text
  ///
  /// In en, this message translates to:
  /// **'Log Mood'**
  String get logMood;

  /// Log symptoms button text
  ///
  /// In en, this message translates to:
  /// **'Log Symptoms'**
  String get logSymptoms;

  /// Education section title
  ///
  /// In en, this message translates to:
  /// **'Menstrual Health Education'**
  String get menstrualHealthEducation;

  /// Video library title
  ///
  /// In en, this message translates to:
  /// **'Video Library'**
  String get videoLibrary;

  /// Quizzes title
  ///
  /// In en, this message translates to:
  /// **'Knowledge Quizzes'**
  String get knowledgeQuizzes;

  /// Product guide title
  ///
  /// In en, this message translates to:
  /// **'Product Guide'**
  String get productGuide;

  /// Product guide description
  ///
  /// In en, this message translates to:
  /// **'Learn about menstrual products and how to use them safely'**
  String get learnAboutProducts;

  /// Videos watched stat
  ///
  /// In en, this message translates to:
  /// **'Videos Watched'**
  String get videosWatched;

  /// Watch time stat
  ///
  /// In en, this message translates to:
  /// **'Watch Time'**
  String get watchTime;

  /// Completed text
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Best score text
  ///
  /// In en, this message translates to:
  /// **'Best Score'**
  String get bestScore;

  /// Start quiz button text
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get startQuiz;

  /// Retake quiz button text
  ///
  /// In en, this message translates to:
  /// **'Retake Quiz'**
  String get retakeQuiz;

  /// Watch now button text
  ///
  /// In en, this message translates to:
  /// **'Watch Now'**
  String get watchNow;

  /// Watch again button text
  ///
  /// In en, this message translates to:
  /// **'Watch Again'**
  String get watchAgain;

  /// Mark watched button text
  ///
  /// In en, this message translates to:
  /// **'Mark Watched'**
  String get markWatched;

  /// Video marked as watched message
  ///
  /// In en, this message translates to:
  /// **'Video marked as watched! 🎉'**
  String get videoMarkedWatched;

  /// Quiz complete message
  ///
  /// In en, this message translates to:
  /// **'Quiz Complete!'**
  String get quizComplete;

  /// Your score text
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// Excellent work message
  ///
  /// In en, this message translates to:
  /// **'Excellent work! 🎉'**
  String get excellentWork;

  /// Good job message
  ///
  /// In en, this message translates to:
  /// **'Good job! Keep learning! 📚'**
  String get goodJob;

  /// Keep practicing message
  ///
  /// In en, this message translates to:
  /// **'Keep practicing! You\'ll do better next time! 💪'**
  String get keepPracticing;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Previous button text
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// Finish quiz button text
  ///
  /// In en, this message translates to:
  /// **'Finish Quiz'**
  String get finishQuiz;

  /// Questions text
  ///
  /// In en, this message translates to:
  /// **'questions'**
  String get questions;

  /// Estimated time text
  ///
  /// In en, this message translates to:
  /// **'Estimated time'**
  String get estimatedTime;

  /// Beginner difficulty level
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// Intermediate difficulty level
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// Advanced difficulty level
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// Tampon instructions title
  ///
  /// In en, this message translates to:
  /// **'How to Use Tampons Safely'**
  String get tamponInstructions;

  /// Safety tips section title
  ///
  /// In en, this message translates to:
  /// **'Safety Tips'**
  String get safetyTips;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Shona language option
  ///
  /// In en, this message translates to:
  /// **'Shona'**
  String get shona;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sn':
      return AppLocalizationsSn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
