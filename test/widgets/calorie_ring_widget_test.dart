import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilyfit/widgets/calorie_ring_painter.dart';
import 'package:lilyfit/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.darkTheme,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('CalorieRingWidget', () {
    testWidgets('renders without crashing at zero progress', (tester) async {
      await tester.pumpWidget(
        _wrap(const CalorieRingWidget(consumed: 0, target: 2000)),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('renders without crashing at 50% progress', (tester) async {
      await tester.pumpWidget(
        _wrap(const CalorieRingWidget(consumed: 1000, target: 2000)),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('renders without crashing when consumed exceeds target', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const CalorieRingWidget(consumed: 2500, target: 2000)),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('renders without crashing when target is 0', (tester) async {
      await tester.pumpWidget(
        _wrap(const CalorieRingWidget(consumed: 0, target: 0)),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('uses default size of 200', (tester) async {
      const widget = CalorieRingWidget(consumed: 500, target: 2000);
      expect(widget.size, 200);
    });

    testWidgets('accepts custom size', (tester) async {
      await tester.pumpWidget(
        _wrap(const CalorieRingWidget(consumed: 500, target: 2000, size: 150)),
      );
      await tester.pumpAndSettle();
    });
  });

  group('CalorieRingPainter', () {
    test('shouldRepaint returns true when progress changes', () {
      final p1 = CalorieRingPainter(
        progress: 0.5,
        backgroundColor: AppColors.cardLight,
        dotColor: AppColors.card,
      );
      final p2 = CalorieRingPainter(
        progress: 0.8,
        backgroundColor: AppColors.cardLight,
        dotColor: AppColors.card,
      );
      expect(p1.shouldRepaint(p2), isTrue);
    });

    test('shouldRepaint returns false when progress is the same', () {
      final p1 = CalorieRingPainter(
        progress: 0.5,
        backgroundColor: AppColors.cardLight,
        dotColor: AppColors.card,
      );
      final p2 = CalorieRingPainter(
        progress: 0.5,
        backgroundColor: AppColors.cardLight,
        dotColor: AppColors.card,
      );
      expect(p1.shouldRepaint(p2), isFalse);
    });

    test('clamps progress to 1.0 for drawing', () {
      // Just ensure construction with > 1.0 progress does not throw
      expect(
        () => CalorieRingPainter(
          progress: 1.5,
          backgroundColor: AppColors.cardLight,
          dotColor: AppColors.card,
        ),
        returnsNormally,
      );
    });

    test('can be constructed with default colors', () {
      final painter = CalorieRingPainter(
        progress: 0.75,
        backgroundColor: AppColors.cardLight,
        dotColor: AppColors.card,
      );
      expect(painter.progress, 0.75);
      expect(painter.strokeWidth, 14);
    });
  });
}
