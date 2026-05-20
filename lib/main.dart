import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'services/supabase_service.dart';
import 'services/language_service.dart';
import 'services/notification_service.dart';
import 'config/supabase_config.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/language_selection/language_selection_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Initialize notification service (must come after ensureInitialized).
  await NotificationService.initialize();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final appProvider = AppProvider();
  await appProvider.initialize();

  // Re-schedule water reminders if the user had them enabled before.
  if (appProvider.waterRemindersEnabled) {
    final localizations = lookupAppLocalizations(appProvider.currentLocale);
    await NotificationService.scheduleWaterReminders(
      intervalMinutes: appProvider.waterReminderIntervalMinutes,
      startHour: appProvider.waterReminderStartHour,
      startMinute: appProvider.waterReminderStartMinute,
      endHour: appProvider.waterReminderEndHour,
      endMinute: appProvider.waterReminderEndMinute,
      notificationTitle: localizations.waterReminderNotificationTitle,
      notificationBody: localizations.waterReminderNotificationBody,
    );
  }

  runApp(
    ChangeNotifierProvider.value(value: appProvider, child: const LilyFitApp()),
  );
}

// Global Supabase client instance
final supabase = Supabase.instance.client;

class LilyFitApp extends StatelessWidget {
  const LilyFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LilyFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Localization configuration
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Use locale from AppProvider
      locale: context.watch<AppProvider>().currentLocale,
      home: const AppInitializer(),
      routes: {
        '/auth': (context) => const AuthWrapper(),
        '/language': (context) => const LanguageSelectionScreen(),
      },
    );
  }
}

/// Handles app initialization and navigation to language selection or auth
/// Flow:
/// - First time users: Language Selection → Auth Screen → Signup → Onboarding
/// - Returning users (logged in): Skip to Home with their progress
/// - Returning users (not logged in): Auth Screen → Login → Home/Onboarding
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isChecking = true;
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    _determineInitialRoute();
  }

  Future<void> _determineInitialRoute() async {
    // Check if this is the first launch (new user)
    final isFirstLaunch = await LanguageService.isFirstLaunch();

    if (isFirstLaunch) {
      // First time user - must select language before anything else
      setState(() {
        _initialScreen = const LanguageSelectionScreen();
        _isChecking = false;
      });
      return;
    }

    // Not first launch - check authentication state
    final supabaseService = SupabaseService();
    final user = supabaseService.getCurrentUser();

    if (user == null) {
      // Returning user but not logged in - show auth screen
      setState(() {
        _initialScreen = const AuthWrapper();
        _isChecking = false;
      });
      return;
    }

    // User is logged in - check if they have completed onboarding
    try {
      final profile = await supabaseService.getUserProfile();

      if (!mounted) return;

      if (profile == null) {
        // Logged in but no profile - complete onboarding
        setState(() {
          _initialScreen = const OnboardingScreen();
          _isChecking = false;
        });
      } else {
        // Logged in with profile - load data and go to home
        final provider = context.read<AppProvider>();
        if (!provider.isOnboarded) {
          await provider.completeOnboarding(profile);
        }

        setState(() {
          _initialScreen = const HomeScreen();
          _isChecking = false;
        });
      }
    } catch (e) {
      // Error loading profile - show auth screen
      if (!mounted) return;
      setState(() {
        _initialScreen = const AuthWrapper();
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.background, AppColors.surface, AppColors.card],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or icon
                Icon(
                  Icons.restaurant_menu_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
                SizedBox(height: 24),
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'LilyFit',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _initialScreen ?? const AuthWrapper();
  }
}

/// Handles authentication state and navigation for unauthenticated users
/// This wrapper is shown when user needs to login/signup
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _supabaseService = SupabaseService();
  bool _isLoading = true;
  Widget _currentScreen = const AuthScreen();

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _supabaseService.authStateChanges.listen((authState) {
      if (mounted) {
        _checkAuthState();
      }
    });
  }

  Future<void> _checkAuthState() async {
    setState(() => _isLoading = true);

    try {
      final user = _supabaseService.getCurrentUser();

      if (user == null) {
        // Not logged in -> show auth screen for login/signup
        setState(() {
          _currentScreen = const AuthScreen();
          _isLoading = false;
        });
        return;
      }

      // User just logged in/signed up - check if they have a profile
      final profile = await _supabaseService.getUserProfile();

      if (!mounted) return;

      if (profile == null) {
        // Just signed up, no profile yet -> show onboarding to create profile
        setState(() {
          _currentScreen = const OnboardingScreen();
          _isLoading = false;
        });
      } else {
        // Just logged in with existing profile -> load data and go to home
        final provider = context.read<AppProvider>();
        if (!provider.isOnboarded) {
          await provider.completeOnboarding(profile);
        }

        // Navigate to home (replace entire stack)
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
        return;
      }
    } catch (e) {
      // Error checking state -> show auth screen
      if (!mounted) return;
      setState(() {
        _currentScreen = const AuthScreen();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.background, AppColors.surface, AppColors.card],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }

    return _currentScreen;
  }
}
