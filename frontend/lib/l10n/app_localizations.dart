import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Smartify'**
  String get appTitle;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get hello;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @body.
  ///
  /// In en, this message translates to:
  /// **'body'**
  String get body;

  /// No description provided for @smartifyTest.
  ///
  /// In en, this message translates to:
  /// **'Smartify Test'**
  String get smartifyTest;

  /// No description provided for @questionnaireSent.
  ///
  /// In en, this message translates to:
  /// **'Questionnaire sent!'**
  String get questionnaireSent;

  /// No description provided for @questionnaireError.
  ///
  /// In en, this message translates to:
  /// **'Error sending questionnaire'**
  String get questionnaireError;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other:'**
  String get other;

  /// No description provided for @yourOption.
  ///
  /// In en, this message translates to:
  /// **'Your option'**
  String get yourOption;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose a theme'**
  String get chooseTheme;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get go;

  /// No description provided for @loginToAccount.
  ///
  /// In en, this message translates to:
  /// **'Login to account'**
  String get loginToAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'By using Smartify, you agree to the Terms of Use and Privacy Policy.'**
  String get termsAndPrivacy;

  /// No description provided for @universities.
  ///
  /// In en, this message translates to:
  /// **'Universities'**
  String get universities;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @subjectFilterHere.
  ///
  /// In en, this message translates to:
  /// **'Subject filter will be here'**
  String get subjectFilterHere;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @newSubject.
  ///
  /// In en, this message translates to:
  /// **'New subject'**
  String get newSubject;

  /// No description provided for @subjectName.
  ///
  /// In en, this message translates to:
  /// **'Subject name'**
  String get subjectName;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTask;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline:'**
  String get deadline;

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTask;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @subjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get subjects;

  /// No description provided for @searchUniversity.
  ///
  /// In en, this message translates to:
  /// **'Search university'**
  String get searchUniversity;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email 1 / 3'**
  String get enterYourEmail;

  /// No description provided for @exampleEmail.
  ///
  /// In en, this message translates to:
  /// **'example@example'**
  String get exampleEmail;

  /// No description provided for @emailError.
  ///
  /// In en, this message translates to:
  /// **'Email error!'**
  String get emailError;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @confirmYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email 2 / 3'**
  String get confirmYourEmail;

  /// No description provided for @weSentCodeTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a five-digit code to'**
  String get weSentCodeTo;

  /// No description provided for @enterItBelow.
  ///
  /// In en, this message translates to:
  /// **'enter it below:'**
  String get enterItBelow;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @invalidCodeOrConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Invalid code or connection error'**
  String get invalidCodeOrConnectionError;

  /// No description provided for @confirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Confirm email'**
  String get confirmEmail;

  /// No description provided for @didNotReceiveEmail.
  ///
  /// In en, this message translates to:
  /// **'Didn’t receive the email?'**
  String get didNotReceiveEmail;

  /// No description provided for @sendToAnotherAddress.
  ///
  /// In en, this message translates to:
  /// **'Send to another address'**
  String get sendToAnotherAddress;

  /// No description provided for @chooseNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password 3 / 3'**
  String get chooseNewPassword;

  /// No description provided for @min8Characters.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters'**
  String get min8Characters;

  /// No description provided for @atLeastOneDigit.
  ///
  /// In en, this message translates to:
  /// **'At least one digit (0-9)'**
  String get atLeastOneDigit;

  /// No description provided for @atLeastOneSpecialCharacter.
  ///
  /// In en, this message translates to:
  /// **'At least one special character (e.g.: ! @ # % ^ & * ( ) - _ + = )'**
  String get atLeastOneSpecialCharacter;

  /// No description provided for @registrationError.
  ///
  /// In en, this message translates to:
  /// **'Registration error'**
  String get registrationError;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @passwordSuccessfullyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your password has been successfully updated!'**
  String get passwordSuccessfullyUpdated;

  /// No description provided for @exploreEducationWithOneClick.
  ///
  /// In en, this message translates to:
  /// **'Explore the world of education with one click.'**
  String get exploreEducationWithOneClick;

  /// No description provided for @usingSmartify.
  ///
  /// In en, this message translates to:
  /// **'By using Smartify, you agree to\n'**
  String get usingSmartify;

  /// No description provided for @termsOfUseAndPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'the Terms of Use and Privacy Policy.'**
  String get termsOfUseAndPrivacyPolicy;

  /// No description provided for @subjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Subject name'**
  String get subjectTitle;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @forAllTime.
  ///
  /// In en, this message translates to:
  /// **'For all time'**
  String get forAllTime;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @deleteSubject.
  ///
  /// In en, this message translates to:
  /// **'Delete subject'**
  String get deleteSubject;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @moreThanHundredUniversities.
  ///
  /// In en, this message translates to:
  /// **'More than a hundred universities'**
  String get moreThanHundredUniversities;

  /// No description provided for @preparationForEge.
  ///
  /// In en, this message translates to:
  /// **'Preparation for EGE'**
  String get preparationForEge;

  /// No description provided for @trackYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Track your progress'**
  String get trackYourProgress;

  /// No description provided for @careerOffers.
  ///
  /// In en, this message translates to:
  /// **'Career offers'**
  String get careerOffers;

  /// No description provided for @hugeCareerBase.
  ///
  /// In en, this message translates to:
  /// **'Huge career base'**
  String get hugeCareerBase;

  /// No description provided for @teachers.
  ///
  /// In en, this message translates to:
  /// **'Teachers'**
  String get teachers;

  /// No description provided for @moreThanHundredTeachers.
  ///
  /// In en, this message translates to:
  /// **'More than a hundred teachers'**
  String get moreThanHundredTeachers;

  /// No description provided for @loadDataError.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get loadDataError;

  /// No description provided for @searchProfessionHint.
  ///
  /// In en, this message translates to:
  /// **'Search profession...'**
  String get searchProfessionHint;

  /// No description provided for @takeQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Take questionnaire'**
  String get takeQuestionnaire;

  /// No description provided for @noTitle.
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get noTitle;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  String get contactUs;
  String get faq;
  String get commonQuestions;
  String get reportProblem;
  String get describeIssue;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
