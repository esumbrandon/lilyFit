import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'services/supabase_service.dart';
import 'config/supabase_config.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

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
      home: const AuthWrapper(),
    );
  }
}

/// Handles authentication state and navigation
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
      _checkAuthState();
    });
  }

  Future<void> _checkAuthState() async {
    setState(() => _isLoading = true);

    try {
      final user = _supabaseService.getCurrentUser();

      if (user == null) {
        // Not logged in -> show auth screen
        setState(() {
          _currentScreen = const AuthScreen();
          _isLoading = false;
        });
        return;
      }

      // User is logged in, check if they have a profile
      final profile = await _supabaseService.getUserProfile();

      if (!mounted) return;

      if (profile == null) {
        // Logged in but no profile -> show onboarding
        setState(() {
          _currentScreen = const OnboardingScreen();
          _isLoading = false;
        });
      } else {
        // Logged in and has profile -> load into app state and show home
        final provider = context.read<AppProvider>();
        if (!provider.isOnboarded) {
          await provider.completeOnboarding(profile);
        }

        setState(() {
          _currentScreen = const HomeScreen();
          _isLoading = false;
        });
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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return _currentScreen;
  }
}
