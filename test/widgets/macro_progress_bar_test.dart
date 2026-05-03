import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilyfit/widgets/macro_progress_bar.dart';
import 'package:lilyfit/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.darkTheme,
  home: Scaffold(body: SizedBox(width: 400, child: child)),
);

void main() {
  group('MacroProgressBar', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MacroProgressBar(
            label: 'PROTEIN',
            current: 80,
            target: 150,
            color: AppColors.protein,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('PROTEIN'), findsOneWidget);
    });

    testWidgets('renders current value with default unit g', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MacroProgressBar(
            label: 'CARBS',
            current: 120,
            target: 250,
            color: AppColors.carbs,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('120g'), findsOneWidget);
    });

    testWidgets('renders current value with custom unit', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MacroProgressBar(
            label: 'WATER',
            current: 500,
            target: 2500,
            color: AppColors.secondary,
            unit: 'ml',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('500ml'), findsOneWidget);
    });

    testWidgets('renders at 0 current without crashing', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MacroProgressBar(
            label: 'FAT',
            current: 0,
            target: 80,
            color: AppColors.fat,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('0g'), findsOneWidget);
    });

    testWidgets('renders when target is 0 without crash', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MacroProgressBar(
            label: 'FAT',
            current: 0,
            target: 0,
            color: AppColors.fat,
          ),
        ),
      );
      await tester.pumpAndSettle();
      // No crash = pass
    });

    testWidgets('renders when current exceeds target', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MacroProgressBar(
            label: 'PROTEIN',
            current: 200,
            target: 100,
            color: AppColors.protein,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('200g'), findsOneWidget);
    });
  });
}
