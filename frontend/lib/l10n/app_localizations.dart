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

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @minRating.
  ///
  /// In en, this message translates to:
  /// **'Minimum rating'**
  String get minRating;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @ratingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingLabel;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

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
  /// **'Edit Task'**
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
  /// **'Failed to load data'**
  String get loadDataError;

  /// No description provided for @searchProfessionHint.
  ///
  /// In en, this message translates to:
  /// **'Search for professions...'**
  String get searchProfessionHint;

  /// No description provided for @takeQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Take the questionnaire'**
  String get takeQuestionnaire;

  /// No description provided for @viewRecommendations.
  ///
  /// In en, this message translates to:
  /// **'View recommendations'**
  String get viewRecommendations;

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

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us via'**
  String get contactUs;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @commonQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get commonQuestions;

  /// No description provided for @reportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get reportProblem;

  /// No description provided for @describeIssue.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue'**
  String get describeIssue;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @budgetPlaces.
  ///
  /// In en, this message translates to:
  /// **'Budget places'**
  String get budgetPlaces;

  /// No description provided for @dormitory.
  ///
  /// In en, this message translates to:
  /// **'Dormitory'**
  String get dormitory;

  /// No description provided for @militaryCenter.
  ///
  /// In en, this message translates to:
  /// **'Military center'**
  String get militaryCenter;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get taskTitle;

  /// No description provided for @taskDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get taskDescription;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @noTasksForDate.
  ///
  /// In en, this message translates to:
  /// **'No tasks for the selected date'**
  String get noTasksForDate;

  /// No description provided for @spheres.
  ///
  /// In en, this message translates to:
  /// **'Spheres'**
  String get spheres;

  /// No description provided for @tutors.
  ///
  /// In en, this message translates to:
  /// **'Tutors'**
  String get tutors;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @successRegistration.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get successRegistration;

  /// No description provided for @alreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Already registered?'**
  String get alreadyRegistered;

  /// No description provided for @registration.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registration;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @answer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answer;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get requiredField;

  /// No description provided for @questionnaire.
  ///
  /// In en, this message translates to:
  /// **'Questionnaire'**
  String get questionnaire;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login error'**
  String get loginError;

  /// No description provided for @teacherOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Teacher request'**
  String get teacherOfferTitle;

  /// No description provided for @teacherOfferSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Describe your goals and find the perfect teacher'**
  String get teacherOfferSubtitle;

  /// No description provided for @enterSubject.
  ///
  /// In en, this message translates to:
  /// **'Enter subject'**
  String get enterSubject;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @enterGoal.
  ///
  /// In en, this message translates to:
  /// **'Describe your goal'**
  String get enterGoal;

  /// No description provided for @availableTime.
  ///
  /// In en, this message translates to:
  /// **'Available time'**
  String get availableTime;

  /// No description provided for @enterAvailableTime.
  ///
  /// In en, this message translates to:
  /// **'When are you available?'**
  String get enterAvailableTime;

  /// No description provided for @format.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get format;

  /// No description provided for @enterFormat.
  ///
  /// In en, this message translates to:
  /// **'Online, offline or both'**
  String get enterFormat;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself or your wishes'**
  String get enterDescription;

  /// No description provided for @sendOffer.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendOffer;

  /// No description provided for @offerSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get offerSentTitle;

  /// No description provided for @offerSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your teacher request has been sent successfully!'**
  String get offerSentSuccess;

  /// No description provided for @offerSentContactSoon.
  ///
  /// In en, this message translates to:
  /// **'We will contact you soon.'**
  String get offerSentContactSoon;

  /// No description provided for @toMain.
  ///
  /// In en, this message translates to:
  /// **'To main page'**
  String get toMain;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @leaveRequest.
  ///
  /// In en, this message translates to:
  /// **'Leave a request'**
  String get leaveRequest;

  /// No description provided for @priceLessThan1000.
  ///
  /// In en, this message translates to:
  /// **'Less than 1000'**
  String get priceLessThan1000;

  /// No description provided for @price1000to2000.
  ///
  /// In en, this message translates to:
  /// **'1000–2000'**
  String get price1000to2000;

  /// No description provided for @price2000to3000.
  ///
  /// In en, this message translates to:
  /// **'2000–3000'**
  String get price2000to3000;

  /// No description provided for @priceMoreThan3000.
  ///
  /// In en, this message translates to:
  /// **'More than 3000'**
  String get priceMoreThan3000;

  /// No description provided for @subjectMath.
  ///
  /// In en, this message translates to:
  /// **'Mathematics'**
  String get subjectMath;

  /// No description provided for @subjectPhysics.
  ///
  /// In en, this message translates to:
  /// **'Physics'**
  String get subjectPhysics;

  /// No description provided for @subjectChemistry.
  ///
  /// In en, this message translates to:
  /// **'Chemistry'**
  String get subjectChemistry;

  /// No description provided for @subjectBiology.
  ///
  /// In en, this message translates to:
  /// **'Biology'**
  String get subjectBiology;

  /// No description provided for @subjectRussianLang.
  ///
  /// In en, this message translates to:
  /// **'Russian Language'**
  String get subjectRussianLang;

  /// No description provided for @subjectLiterature.
  ///
  /// In en, this message translates to:
  /// **'Literature'**
  String get subjectLiterature;

  /// No description provided for @subjectHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get subjectHistory;

  /// No description provided for @subjectSocialStudies.
  ///
  /// In en, this message translates to:
  /// **'Social Studies'**
  String get subjectSocialStudies;

  /// No description provided for @subjectInformatics.
  ///
  /// In en, this message translates to:
  /// **'Informatics'**
  String get subjectInformatics;

  /// No description provided for @subjectEnglishLang.
  ///
  /// In en, this message translates to:
  /// **'English Language'**
  String get subjectEnglishLang;

  /// No description provided for @subjectGeography.
  ///
  /// In en, this message translates to:
  /// **'Geography'**
  String get subjectGeography;

  /// No description provided for @subjectGermanLang.
  ///
  /// In en, this message translates to:
  /// **'German Language'**
  String get subjectGermanLang;

  /// No description provided for @subjectFrenchLang.
  ///
  /// In en, this message translates to:
  /// **'French Language'**
  String get subjectFrenchLang;

  /// No description provided for @subjectSpanishLang.
  ///
  /// In en, this message translates to:
  /// **'Spanish Language'**
  String get subjectSpanishLang;

  /// No description provided for @subjectMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get subjectMusic;

  /// No description provided for @subjectDrawing.
  ///
  /// In en, this message translates to:
  /// **'Drawing'**
  String get subjectDrawing;

  /// No description provided for @subjectChineseLang.
  ///
  /// In en, this message translates to:
  /// **'Chinese Language'**
  String get subjectChineseLang;

  /// No description provided for @notCompleted.
  ///
  /// In en, this message translates to:
  /// **'Not completed'**
  String get notCompleted;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;
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
