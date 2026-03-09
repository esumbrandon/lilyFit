import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  final appProvider = AppProvider();
  await appProvider.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: appProvider,
      child: const LilyFitApp(),
    ),
  );
}

class LilyFitApp extends StatelessWidget {
  const LilyFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return MaterialApp(
      title: 'LilyFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: provider.isOnboarded ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
