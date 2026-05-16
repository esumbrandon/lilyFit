import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'LilyFit'**
  String get appName;

  /// App tagline
  ///
  /// In en, this message translates to:
  /// **'Smart calorie management'**
  String get tagline;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

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

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @reenterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get reenterPassword;

  /// No description provided for @createPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Create a password (min. 6 characters)'**
  String get createPasswordHint;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning ☀️'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon 🌤️'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening 🌙'**
  String get goodEvening;

  /// No description provided for @aboutYou.
  ///
  /// In en, this message translates to:
  /// **'About You'**
  String get aboutYou;

  /// No description provided for @personalizeMessage.
  ///
  /// In en, this message translates to:
  /// **'Let\'s personalize your calorie management plan'**
  String get personalizeMessage;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @startTracking.
  ///
  /// In en, this message translates to:
  /// **'Start Tracking!'**
  String get startTracking;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @bodyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Body Metrics'**
  String get bodyMetrics;

  /// No description provided for @enterMetricsMessage.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your current measurements'**
  String get enterMetricsMessage;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @activityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get activityLevel;

  /// No description provided for @activityMessage.
  ///
  /// In en, this message translates to:
  /// **'How active are you?'**
  String get activityMessage;

  /// No description provided for @sedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get sedentary;

  /// No description provided for @sedentaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Little or no exercise'**
  String get sedentaryDesc;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @lightDesc.
  ///
  /// In en, this message translates to:
  /// **'Exercise 1-3 times/week'**
  String get lightDesc;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @moderateDesc.
  ///
  /// In en, this message translates to:
  /// **'Exercise 3-5 times/week'**
  String get moderateDesc;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @activeDesc.
  ///
  /// In en, this message translates to:
  /// **'Exercise 6-7 times/week'**
  String get activeDesc;

  /// No description provided for @veryActive.
  ///
  /// In en, this message translates to:
  /// **'Very Active'**
  String get veryActive;

  /// No description provided for @veryActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Physical job + exercise'**
  String get veryActiveDesc;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @goalMessage.
  ///
  /// In en, this message translates to:
  /// **'What\'s your health objective?'**
  String get goalMessage;

  /// No description provided for @loseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose Weight'**
  String get loseWeight;

  /// No description provided for @loseWeightDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a calorie deficit'**
  String get loseWeightDesc;

  /// No description provided for @maintainWeight.
  ///
  /// In en, this message translates to:
  /// **'Maintain Weight'**
  String get maintainWeight;

  /// No description provided for @maintainWeightDesc.
  ///
  /// In en, this message translates to:
  /// **'Stay at current weight'**
  String get maintainWeightDesc;

  /// No description provided for @gainWeight.
  ///
  /// In en, this message translates to:
  /// **'Gain Weight'**
  String get gainWeight;

  /// No description provided for @gainWeightDesc.
  ///
  /// In en, this message translates to:
  /// **'Build muscle mass'**
  String get gainWeightDesc;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Your Results'**
  String get results;

  /// No description provided for @resultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Here\'s your personalized plan'**
  String get resultsMessage;

  /// No description provided for @dailyCalorieTarget.
  ///
  /// In en, this message translates to:
  /// **'Daily Calorie Target'**
  String get dailyCalorieTarget;

  /// No description provided for @proteinTarget.
  ///
  /// In en, this message translates to:
  /// **'Protein Target'**
  String get proteinTarget;

  /// No description provided for @carbsTarget.
  ///
  /// In en, this message translates to:
  /// **'Carbs Target'**
  String get carbsTarget;

  /// No description provided for @fatTarget.
  ///
  /// In en, this message translates to:
  /// **'Fat Target'**
  String get fatTarget;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @todaysMeals.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Meals'**
  String get todaysMeals;

  /// No description provided for @hydration.
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get hydration;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get snacks;

  /// No description provided for @addFood.
  ///
  /// In en, this message translates to:
  /// **'Add Food'**
  String get addFood;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @searchFood.
  ///
  /// In en, this message translates to:
  /// **'Search Food'**
  String get searchFood;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search foods...'**
  String get searchHint;

  /// No description provided for @recentFoods.
  ///
  /// In en, this message translates to:
  /// **'Recent Foods'**
  String get recentFoods;

  /// No description provided for @popularFoods.
  ///
  /// In en, this message translates to:
  /// **'Popular Foods'**
  String get popularFoods;

  /// No description provided for @customFood.
  ///
  /// In en, this message translates to:
  /// **'Custom Food'**
  String get customFood;

  /// No description provided for @foodName.
  ///
  /// In en, this message translates to:
  /// **'Food Name'**
  String get foodName;

  /// No description provided for @servingSize.
  ///
  /// In en, this message translates to:
  /// **'Serving Size'**
  String get servingSize;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @waterGoal.
  ///
  /// In en, this message translates to:
  /// **'Water Goal'**
  String get waterGoal;

  /// No description provided for @glasses.
  ///
  /// In en, this message translates to:
  /// **'glasses'**
  String get glasses;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @resetData.
  ///
  /// In en, this message translates to:
  /// **'Reset Data'**
  String get resetData;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @weightProgress.
  ///
  /// In en, this message translates to:
  /// **'Weight Progress'**
  String get weightProgress;

  /// No description provided for @calorieIntake.
  ///
  /// In en, this message translates to:
  /// **'Calorie Intake'**
  String get calorieIntake;

  /// No description provided for @macroDistribution.
  ///
  /// In en, this message translates to:
  /// **'Macro Distribution'**
  String get macroDistribution;

  /// No description provided for @currentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current Weight'**
  String get currentWeight;

  /// No description provided for @targetWeight.
  ///
  /// In en, this message translates to:
  /// **'Target Weight'**
  String get targetWeight;

  /// No description provided for @weeklyAverage.
  ///
  /// In en, this message translates to:
  /// **'Weekly Average'**
  String get weeklyAverage;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get last30Days;

  /// No description provided for @last90Days.
  ///
  /// In en, this message translates to:
  /// **'Last 90 Days'**
  String get last90Days;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @consumed.
  ///
  /// In en, this message translates to:
  /// **'Consumed'**
  String get consumed;

  /// No description provided for @signUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign Up Failed'**
  String get signUpFailed;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @bodyInformation.
  ///
  /// In en, this message translates to:
  /// **'Body Information'**
  String get bodyInformation;

  /// No description provided for @dailyTargets.
  ///
  /// In en, this message translates to:
  /// **'Daily Targets'**
  String get dailyTargets;

  /// No description provided for @bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @applyLanguage.
  ///
  /// In en, this message translates to:
  /// **'Apply Language'**
  String get applyLanguage;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @membership.
  ///
  /// In en, this message translates to:
  /// **'Membership'**
  String get membership;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @privacyAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacyAndSecurity;

  /// No description provided for @foodDatabase.
  ///
  /// In en, this message translates to:
  /// **'Food Database'**
  String get foodDatabase;

  /// No description provided for @noFoodsFound.
  ///
  /// In en, this message translates to:
  /// **'No foods found'**
  String get noFoodsFound;

  /// No description provided for @waterIntake.
  ///
  /// In en, this message translates to:
  /// **'Water Intake'**
  String get waterIntake;

  /// No description provided for @addGlass.
  ///
  /// In en, this message translates to:
  /// **'Add Glass'**
  String get addGlass;

  /// No description provided for @removeGlass.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeGlass;

  /// No description provided for @tapToAddFood.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add food'**
  String get tapToAddFood;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String dayStreak(int count);

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @servings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servings;

  /// No description provided for @addToLog.
  ///
  /// In en, this message translates to:
  /// **'Add to Log'**
  String get addToLog;

  /// No description provided for @selectMealType.
  ///
  /// In en, this message translates to:
  /// **'Select meal type'**
  String get selectMealType;

  /// No description provided for @waterRemindersActive.
  ///
  /// In en, this message translates to:
  /// **'Water reminders active'**
  String get waterRemindersActive;

  /// No description provided for @configureReminders.
  ///
  /// In en, this message translates to:
  /// **'Configure reminders'**
  String get configureReminders;

  /// No description provided for @logWeight.
  ///
  /// In en, this message translates to:
  /// **'Log Today\'s Weight'**
  String get logWeight;

  /// No description provided for @weeklyCalories.
  ///
  /// In en, this message translates to:
  /// **'Weekly Calories'**
  String get weeklyCalories;

  /// No description provided for @weeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get weeklySummary;

  /// No description provided for @avgDailyCalories.
  ///
  /// In en, this message translates to:
  /// **'Average Daily Calories'**
  String get avgDailyCalories;

  /// No description provided for @totalMealsLogged.
  ///
  /// In en, this message translates to:
  /// **'Total Meals Logged'**
  String get totalMealsLogged;

  /// No description provided for @weightChange.
  ///
  /// In en, this message translates to:
  /// **'Weight Change'**
  String get weightChange;

  /// No description provided for @weightHistory.
  ///
  /// In en, this message translates to:
  /// **'Weight History'**
  String get weightHistory;

  /// No description provided for @addTo.
  ///
  /// In en, this message translates to:
  /// **'Add to'**
  String get addTo;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid Email'**
  String get invalidEmail;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmail;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset Link Sent'**
  String get resetLinkSent;

  /// No description provided for @resetFailed.
  ///
  /// In en, this message translates to:
  /// **'Reset Failed'**
  String get resetFailed;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @pleaseSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Please select a language'**
  String get pleaseSelectLanguage;

  /// No description provided for @reminderInterval.
  ///
  /// In en, this message translates to:
  /// **'Reminder Interval'**
  String get reminderInterval;

  /// No description provided for @activeHours.
  ///
  /// In en, this message translates to:
  /// **'Active Hours'**
  String get activeHours;

  /// No description provided for @startTimeError.
  ///
  /// In en, this message translates to:
  /// **'Start time must be before end time'**
  String get startTimeError;

  /// No description provided for @endTimeError.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time'**
  String get endTimeError;

  /// No description provided for @emailUpdate.
  ///
  /// In en, this message translates to:
  /// **'Email Update'**
  String get emailUpdate;

  /// No description provided for @updateEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Update your email address'**
  String get updateEmailAddress;

  /// No description provided for @faqsContactUs.
  ///
  /// In en, this message translates to:
  /// **'FAQs, contact us'**
  String get faqsContactUs;

  /// No description provided for @dataPermissionsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data, permissions, privacy policy'**
  String get dataPermissionsPrivacy;

  /// No description provided for @waterReminders.
  ///
  /// In en, this message translates to:
  /// **'Water Reminders'**
  String get waterReminders;

  /// No description provided for @remindToDrinkWater.
  ///
  /// In en, this message translates to:
  /// **'Remind me to drink water'**
  String get remindToDrinkWater;

  /// No description provided for @newEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'New Email Address'**
  String get newEmailAddress;

  /// No description provided for @sendConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Send Confirmation'**
  String get sendConfirmation;

  /// No description provided for @premiumComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Premium subscription coming soon!'**
  String get premiumComingSoon;

  /// No description provided for @liveChat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get liveChat;

  /// No description provided for @chatWithUs.
  ///
  /// In en, this message translates to:
  /// **'Chat with us'**
  String get chatWithUs;

  /// No description provided for @emailUs.
  ///
  /// In en, this message translates to:
  /// **'Email Us'**
  String get emailUs;

  /// No description provided for @dataStorage.
  ///
  /// In en, this message translates to:
  /// **'Data Storage'**
  String get dataStorage;

  /// No description provided for @dataSync.
  ///
  /// In en, this message translates to:
  /// **'Data Sync'**
  String get dataSync;

  /// No description provided for @clearLocalCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Local Cache'**
  String get clearLocalCache;

  /// No description provided for @clearCacheSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove cached food data and images'**
  String get clearCacheSubtitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'How we collect and use your data'**
  String get privacyPolicySubtitle;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @termsOfServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read our terms and conditions'**
  String get termsOfServiceSubtitle;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and all data'**
  String get deleteAccountSubtitle;

  /// No description provided for @clearCacheQuestion.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache?'**
  String get clearCacheQuestion;

  /// No description provided for @clearCacheBody.
  ///
  /// In en, this message translates to:
  /// **'This will remove cached food data. Your personal data and meal logs will not be affected.'**
  String get clearCacheBody;

  /// No description provided for @cacheClearedMsg.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheClearedMsg;

  /// No description provided for @deleteAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountQuestion;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all associated data. This action cannot be undone.'**
  String get deleteAccountBody;

  /// No description provided for @resetAllDataQuestion.
  ///
  /// In en, this message translates to:
  /// **'Reset All Data?'**
  String get resetAllDataQuestion;

  /// No description provided for @resetAllDataBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete all your data including meals, weight history, and profile. This cannot be undone.'**
  String get resetAllDataBody;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @logAtLeast2Weights.
  ///
  /// In en, this message translates to:
  /// **'Log at least 2 weights to see your chart'**
  String get logAtLeast2Weights;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @enterCurrentWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter your current weight'**
  String get enterCurrentWeight;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @planReady.
  ///
  /// In en, this message translates to:
  /// **'Your Plan is Ready! 🎉'**
  String get planReady;

  /// No description provided for @basedOnProfile.
  ///
  /// In en, this message translates to:
  /// **'Based on your profile, here are your daily targets'**
  String get basedOnProfile;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @eatingStyle.
  ///
  /// In en, this message translates to:
  /// **'Eating Style'**
  String get eatingStyle;

  /// No description provided for @eatingStyleMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ll tailor food suggestions to your preferences'**
  String get eatingStyleMessage;

  /// No description provided for @balanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get balanced;

  /// No description provided for @balancedDesc.
  ///
  /// In en, this message translates to:
  /// **'Well-rounded nutrition with all food groups'**
  String get balancedDesc;

  /// No description provided for @highProtein.
  ///
  /// In en, this message translates to:
  /// **'High-Protein'**
  String get highProtein;

  /// No description provided for @highProteinDesc.
  ///
  /// In en, this message translates to:
  /// **'Prioritises protein for muscle growth & recovery'**
  String get highProteinDesc;

  /// No description provided for @lowCarbKeto.
  ///
  /// In en, this message translates to:
  /// **'Low-Carb / Keto'**
  String get lowCarbKeto;

  /// No description provided for @lowCarbKetoDesc.
  ///
  /// In en, this message translates to:
  /// **'Reduced carbohydrates with higher healthy fats'**
  String get lowCarbKetoDesc;

  /// No description provided for @vegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get vegetarian;

  /// No description provided for @vegetarianDesc.
  ///
  /// In en, this message translates to:
  /// **'Plant-based foods with dairy & eggs allowed'**
  String get vegetarianDesc;

  /// No description provided for @vegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get vegan;

  /// No description provided for @veganDesc.
  ///
  /// In en, this message translates to:
  /// **'100% plant-based — no animal products'**
  String get veganDesc;

  /// No description provided for @dailyWaterGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Water Goal'**
  String get dailyWaterGoal;

  /// No description provided for @stayHydratedMessage.
  ///
  /// In en, this message translates to:
  /// **'Staying hydrated boosts metabolism and energy'**
  String get stayHydratedMessage;

  /// No description provided for @quickSelect.
  ///
  /// In en, this message translates to:
  /// **'Quick select'**
  String get quickSelect;

  /// No description provided for @fineTune.
  ///
  /// In en, this message translates to:
  /// **'Fine-tune'**
  String get fineTune;

  /// No description provided for @swipeToContinue.
  ///
  /// In en, this message translates to:
  /// **'Swipe or tap Continue to begin'**
  String get swipeToContinue;

  /// No description provided for @calorieTracking.
  ///
  /// In en, this message translates to:
  /// **'Calorie Tracking'**
  String get calorieTracking;

  /// No description provided for @calorieTrackingDesc.
  ///
  /// In en, this message translates to:
  /// **'Log meals and stay on target every day'**
  String get calorieTrackingDesc;

  /// No description provided for @macroAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Macro Analysis'**
  String get macroAnalysis;

  /// No description provided for @macroAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Balance protein, carbs & fats perfectly'**
  String get macroAnalysisDesc;

  /// No description provided for @progressInsights.
  ///
  /// In en, this message translates to:
  /// **'Progress Insights'**
  String get progressInsights;

  /// No description provided for @progressInsightsDesc.
  ///
  /// In en, this message translates to:
  /// **'Track your transformation over time'**
  String get progressInsightsDesc;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Your personal nutrition &\nfitness companion'**
  String get welcomeTagline;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get chooseYourLanguage;

  /// No description provided for @selectPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language to get started'**
  String get selectPreferredLanguage;

  /// No description provided for @detectingLocation.
  ///
  /// In en, this message translates to:
  /// **'Detecting your location...'**
  String get detectingLocation;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location: {country}'**
  String locationLabel(String country);

  /// No description provided for @languageSuggested.
  ///
  /// In en, this message translates to:
  /// **'{language} suggested'**
  String languageSuggested(String language);

  /// No description provided for @suggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get suggested;

  /// No description provided for @failedToLoadFoods.
  ///
  /// In en, this message translates to:
  /// **'Failed to load foods: {error}'**
  String failedToLoadFoods(String error);

  /// No description provided for @foodDatabaseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Food database updated!'**
  String get foodDatabaseUpdated;

  /// No description provided for @failedToUpdate.
  ///
  /// In en, this message translates to:
  /// **'Failed to update: {error}'**
  String failedToUpdate(String error);

  /// No description provided for @refreshFoodDatabase.
  ///
  /// In en, this message translates to:
  /// **'Refresh food database'**
  String get refreshFoodDatabase;

  /// No description provided for @foodAddedToMeal.
  ///
  /// In en, this message translates to:
  /// **'{food} added to {meal}'**
  String foodAddedToMeal(String food, String meal);

  /// No description provided for @logoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed: {error}'**
  String logoutFailed(String error);

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @supportEmail.
  ///
  /// In en, this message translates to:
  /// **'support@lilyfit.app'**
  String get supportEmail;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'{title} coming soon!'**
  String comingSoon(String title);

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String lastUpdated(String date);

  /// No description provided for @dataWeCollect.
  ///
  /// In en, this message translates to:
  /// **'Data We Collect'**
  String get dataWeCollect;

  /// No description provided for @dataWeCollectBody.
  ///
  /// In en, this message translates to:
  /// **'We collect information you provide directly to us, including your profile details (name, age, gender, weight, height), dietary preferences, and meal logs. We also collect data about your app usage to improve your experience.'**
  String get dataWeCollectBody;

  /// No description provided for @howWeUseData.
  ///
  /// In en, this message translates to:
  /// **'How We Use Your Data'**
  String get howWeUseData;

  /// No description provided for @howWeUseDataBody.
  ///
  /// In en, this message translates to:
  /// **'Your data is used to calculate personalized calorie targets, track your progress, and provide nutritional insights. We do not sell your personal information to third parties.'**
  String get howWeUseDataBody;

  /// No description provided for @dataStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Storage'**
  String get dataStorageTitle;

  /// No description provided for @dataStorageBody.
  ///
  /// In en, this message translates to:
  /// **'Your data is securely stored using Supabase cloud infrastructure with encryption. You can export or delete your data at any time from the app settings.'**
  String get dataStorageBody;

  /// No description provided for @yourRights.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get yourRights;

  /// No description provided for @yourRightsBody.
  ///
  /// In en, this message translates to:
  /// **'You have the right to access, modify, or delete your personal data. You can manage your data directly within the app or contact us for assistance.'**
  String get yourRightsBody;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @contactUsBody.
  ///
  /// In en, this message translates to:
  /// **'If you have questions about our privacy practices, please contact us at support@lilyfit.app.'**
  String get contactUsBody;

  /// No description provided for @acceptanceOfTerms.
  ///
  /// In en, this message translates to:
  /// **'Acceptance of Terms'**
  String get acceptanceOfTerms;

  /// No description provided for @acceptanceOfTermsBody.
  ///
  /// In en, this message translates to:
  /// **'By using LilyFit, you agree to these terms of service. If you do not agree, please do not use the app.'**
  String get acceptanceOfTermsBody;

  /// No description provided for @useOfApp.
  ///
  /// In en, this message translates to:
  /// **'Use of the App'**
  String get useOfApp;

  /// No description provided for @useOfAppBody.
  ///
  /// In en, this message translates to:
  /// **'LilyFit is provided for personal, non-commercial use. You agree not to misuse the app or interfere with its operation.'**
  String get useOfAppBody;

  /// No description provided for @healthDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Health Disclaimer'**
  String get healthDisclaimer;

  /// No description provided for @healthDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'LilyFit provides general nutritional information and is not a substitute for professional medical advice. Consult a healthcare provider before making significant dietary changes.'**
  String get healthDisclaimerBody;

  /// No description provided for @accountResponsibility.
  ///
  /// In en, this message translates to:
  /// **'Account Responsibility'**
  String get accountResponsibility;

  /// No description provided for @accountResponsibilityBody.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.'**
  String get accountResponsibilityBody;

  /// No description provided for @contactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactLabel;

  /// No description provided for @contactLabelBody.
  ///
  /// In en, this message translates to:
  /// **'For questions about these terms, contact us at support@lilyfit.app.'**
  String get contactLabelBody;

  /// No description provided for @waterRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Water Reminders'**
  String get waterRemindersTitle;

  /// No description provided for @waterRemindersEnabled.
  ///
  /// In en, this message translates to:
  /// **'Water reminders enabled ({count} reminders/day)'**
  String waterRemindersEnabled(int count);

  /// No description provided for @waterRemindersDisabled.
  ///
  /// In en, this message translates to:
  /// **'Water reminders disabled'**
  String get waterRemindersDisabled;

  /// No description provided for @failedToCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to create account'**
  String get failedToCreateAccount;

  /// No description provided for @resetPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get resetPasswordInstructions;

  /// No description provided for @noUserLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'No user logged in. Please login first.'**
  String get noUserLoggedIn;

  /// No description provided for @waterReminderNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to Hydrate! 💧'**
  String get waterReminderNotificationTitle;

  /// No description provided for @waterReminderNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Stay on track – drink a glass of water now.'**
  String get waterReminderNotificationBody;

  /// No description provided for @settingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Language, notifications, privacy & more'**
  String get settingsDescription;

  /// No description provided for @logoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get logoutDescription;

  /// No description provided for @resetDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Start fresh'**
  String get resetDataDescription;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'per day'**
  String get perDay;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;
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
      <String>['de', 'en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
