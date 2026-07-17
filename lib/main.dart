import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'providers/subscription_provider.dart';
import 'services/supabase_service.dart';
import 'services/language_service.dart';
import 'services/notification_service.dart';
import 'config/supabase_config.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/language_selection/language_selection_screen.dart';
import 'screens/subscription/subscription_screen.dart';
import 'l10n/app_localizations.dart';
import 'widgets/adaptive_loading_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
  }

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  await NotificationService.initialize();

  final appProvider = AppProvider();
  await appProvider.initialize();

  final subscriptionProvider = SubscriptionProvider();
  await subscriptionProvider.initialize();

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
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appProvider),
        ChangeNotifierProvider.value(value: subscriptionProvider),
      ],
      child: const LilyFitApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class LilyFitApp extends StatelessWidget {
  const LilyFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppProvider>().themeMode;
    final isDarkMode =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDarkMode
            ? AppColors.darkBackground
            : AppColors.background,
        systemNavigationBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'LilyFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: context.watch<AppProvider>().currentLocale,
      home: const AppInitializer(),
      routes: {
        '/auth': (context) => const AuthWrapper(),
        '/language': (context) => const LanguageSelectionScreen(),
        '/subscription': (context) => const SubscriptionScreen(),
      },
    );
  }
}

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
    final provider = context.read<AppProvider>();

    final isFirstLaunch = await LanguageService.isFirstLaunch();

    if (isFirstLaunch) {
      setState(() {
        _initialScreen = const LanguageSelectionScreen();
        _isChecking = false;
      });
      return;
    }

    final supabaseService = SupabaseService();
    final user = supabaseService.getCurrentUser();

    if (user == null) {
      if (provider.isOnboarded) {
        debugPrint('User has local data - proceeding offline');
        setState(() {
          _initialScreen = const HomeScreen();
          _isChecking = false;
        });
      } else {
        setState(() {
          _initialScreen = const AuthWrapper();
          _isChecking = false;
        });
      }
      return;
    }

    if (provider.isOnboarded) {
      setState(() {
        _initialScreen = const HomeScreen();
        _isChecking = false;
      });

      if (provider.isOnline) {
        provider.syncFromSupabase().catchError((e) {
          debugPrint('Background sync failed on startup: $e');
        });
      }
      return;
    }

    if (!provider.isOnline) {
      debugPrint('Offline with no local data - showing auth screen');
      setState(() {
        _initialScreen = const AuthWrapper();
        _isChecking = false;
      });
      return;
    }

    try {
      final profile = await supabaseService.getUserProfile();

      if (!mounted) return;

      if (profile == null) {
        setState(() {
          _initialScreen = const OnboardingScreen();
          _isChecking = false;
        });
      } else {
        if (!provider.isOnboarded) {
          await provider.completeOnboarding(profile);
        }

        provider.syncFromSupabase().catchError((e) {
          debugPrint('Sync failed during first load: $e');
        });

        setState(() {
          _initialScreen = const HomeScreen();
          _isChecking = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile during init: $e');

      if (!mounted) return;

      if (provider.isOnboarded) {
        setState(() {
          _initialScreen = const HomeScreen();
          _isChecking = false;
        });
      } else {
        setState(() {
          _initialScreen = const AuthWrapper();
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      final provider = context.watch<AppProvider>();
      final isOnline = provider.isOnline;

      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or icon
                const Icon(
                  Icons.restaurant_menu_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                const AdaptiveLoadingIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                const Text(
                  'LilyFit',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 32),
                // Connectivity status indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isOnline
                          ? Icons.cloud_done_rounded
                          : Icons.cloud_off_rounded,
                      size: 16,
                      color: isOnline ? Colors.green : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOnline ? 'Online' : 'Offline Mode',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOnline ? Colors.green : AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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

    final provider = context.read<AppProvider>();

    try {
      final user = _supabaseService.getCurrentUser();

      if (user == null) {
        setState(() {
          _currentScreen = const AuthScreen();
          _isLoading = false;
        });
        return;
      }

      if (provider.isOnboarded) {
        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );

        if (provider.isOnline) {
          provider.syncFromSupabase().catchError((e) {
            debugPrint('Background sync failed after auth: $e');
          });
        }
        return;
      }

      if (!provider.isOnline) {
        debugPrint(
          'Offline after auth with no local data - showing onboarding',
        );
        setState(() {
          _currentScreen = const OnboardingScreen();
          _isLoading = false;
        });
        return;
      }

      final profile = await _supabaseService.getUserProfile();

      if (!mounted) return;

      if (profile == null) {
        setState(() {
          _currentScreen = const OnboardingScreen();
          _isLoading = false;
        });
      } else {
        if (!provider.isOnboarded) {
          await provider.completeOnboarding(profile);
        }

        provider.syncFromSupabase().catchError((e) {
          debugPrint('Sync failed after login: $e');
        });

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
        return;
      }
    } catch (e) {
      debugPrint('Error in auth state check: $e');

      if (!mounted) return;

      if (provider.isOnboarded && _supabaseService.getCurrentUser() != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        setState(() {
          _currentScreen = const AuthScreen();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
          child: const CenteredAdaptiveLoadingIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return _currentScreen;
  }
}
