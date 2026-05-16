// Top-level widget smoke tests.
// Screen-level tests that require Supabase are covered in integration_test/.
// Pure logic, provider, and widget component tests are in test/models/, test/utils/,
// test/services/, test/providers/, and test/widgets/.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lilyfit/widgets/macro_progress_bar.dart';
import 'package:lilyfit/widgets/calorie_ring_painter.dart';
import 'package:lilyfit/widgets/water_tracker_card.dart';
import 'package:lilyfit/theme/app_theme.dart';
import 'package:lilyfit/l10n/app_localizations.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.darkTheme,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );

  group('Smoke tests – key widgets render without crash', () {
    testWidgets('MacroProgressBar renders', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MacroProgressBar(
            label: 'PROTEIN',
            current: 80,
            target: 150,
            color: AppColors.protein,
          ),
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('CalorieRingWidget renders', (tester) async {
      await tester.pumpWidget(
        wrap(const CalorieRingWidget(consumed: 1200, target: 2000)),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('WaterTrackerCard renders', (tester) async {
      await tester.pumpWidget(
        wrap(
          WaterTrackerCard(
            currentGlasses: 4,
            goalGlasses: 8,
            progress: 0.5,
            onAdd: () {},
            onRemove: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
    });
  });

  group('Theme', () {
    test('AppTheme.darkTheme is a dark ThemeData', () {
      expect(AppTheme.darkTheme.brightness, Brightness.dark);
    });

    test('AppColors constants are distinct', () {
      expect(AppColors.primary, isNot(AppColors.secondary));
      expect(AppColors.protein, isNot(AppColors.carbs));
      expect(AppColors.background, isNot(AppColors.card));
    });
  });
}
