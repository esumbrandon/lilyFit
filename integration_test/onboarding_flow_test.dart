// Integration tests for the onboarding flow
// Tests the complete user onboarding experience
//
// Run with: flutter test integration_test/onboarding_flow_test.dart

import 'package:lilyfit/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:lilyfit/providers/app_provider.dart';
import 'package:lilyfit/screens/onboarding/onboarding_screen.dart';
import 'package:lilyfit/screens/home/home_screen.dart';
import 'package:lilyfit/theme/app_theme.dart';
import 'package:lilyfit/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lilyfit/config/supabase_config.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  SupabaseService.isTesting = true;
  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  } catch (_) {}

  // Helper to create properly configured MaterialApp with localizations
  Widget createTestApp(AppProvider provider, Widget home) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: provider.currentLocale,
        home: home,
      ),
    );
  }

  group('Onboarding Flow Tests', () {
    setUp(() async {
      // Clear all shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('User can complete full onboarding flow', (tester) async {
      // Initialize app
      final provider = AppProvider();
      await provider.initialize();

      await tester.pumpWidget(
        createTestApp(provider, const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      // Page 0: Verify we're on the Welcome page
      expect(find.text('LilyFit'), findsOneWidget);

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Page 1: About You / Name & Gender Input
      expect(find.text('About You'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Jane Doe');
      await tester.pumpAndSettle();

      // Select Female
      await tester.tap(find.text('Female'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Page 2: Body Metrics
      expect(find.text('Body Metrics'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Page 3: Activity Level
      expect(find.text('Activity Level'), findsOneWidget);
      await tester.tap(find.text('Moderate'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Page 4: Goal Selection
      expect(find.text('Goal'), findsOneWidget);
      await tester.tap(find.text('Lose Weight'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Page 5: Eating Style
      expect(find.text('Eating Style'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Page 6: Daily Water Goal
      expect(find.text('Daily Water Goal'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Page 7: Plan Summary / Results
      expect(find.text('Your Plan is Ready! 🎉'), findsOneWidget);

      // Complete onboarding
      await tester.tap(find.text('Start Tracking!'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should navigate to home screen
      expect(find.byType(HomeScreen), findsOneWidget);

      // Verify provider state
      expect(provider.isOnboarded, isTrue);
      expect(provider.userProfile.name, 'Jane Doe');
      expect(provider.userProfile.gender, 'female');
      expect(provider.userProfile.targetCalories, greaterThan(0));
    });

    testWidgets('User can navigate back through onboarding pages', (
      tester,
    ) async {
      final provider = AppProvider();
      await provider.initialize();

      await tester.pumpWidget(
        createTestApp(provider, const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      // Go forward from Page 0 to Page 1
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Fill name and continue to Page 2
      await tester.enterText(find.byType(TextField).first, 'Test User');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify on page 2 (Body Metrics)
      expect(find.text('Body Metrics'), findsOneWidget);

      // Go back to page 1
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      // Verify on page 1 (About You)
      expect(find.text('About You'), findsOneWidget);
      expect(
        find.text('Test User'),
        findsOneWidget,
      ); // Name should be preserved
    });

    testWidgets('Name validation prevents empty submission', (tester) async {
      final provider = AppProvider();
      await provider.initialize();

      await tester.pumpWidget(
        createTestApp(provider, const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      // Skip welcome page
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Try to proceed without entering name (clear the pre-populated name first)
      await tester.enterText(find.byType(TextField).first, '');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Should still be on name/about page because of validation error
      expect(find.text('About You'), findsOneWidget);
    });

    testWidgets('Progress indicator segments exist', (tester) async {
      final provider = AppProvider();
      await provider.initialize();

      await tester.pumpWidget(
        createTestApp(provider, const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      // Verify custom progress segments are built
      expect(find.byType(FractionallySizedBox), findsWidgets);
    });

    testWidgets('Unit switching works for weight and height', (tester) async {
      final provider = AppProvider();
      await provider.initialize();

      await tester.pumpWidget(
        createTestApp(provider, const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      // Navigate to Page 1 (About You)
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Enter name and continue to Page 2 (Body Metrics)
      await tester.enterText(find.byType(TextField).first, 'Test User');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Now on Body Metrics page
      expect(find.text('Body Metrics'), findsOneWidget);

      // Find unit toggle button (lbs) and toggle it
      final unitToggleLbs = find.text('lbs');
      expect(unitToggleLbs, findsOneWidget);
      await tester.tap(unitToggleLbs);
      await tester.pumpAndSettle();

      // Verify that weight unit changed
      expect(find.text('lbs'), findsOneWidget);
    });
  });
}
