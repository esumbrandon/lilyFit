import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lilyfit/widgets/water_tracker_card.dart';
import 'package:lilyfit/theme/app_theme.dart';
import 'package:lilyfit/l10n/app_localizations.dart';

Widget _buildCard({
  int currentGlasses = 3,
  int goalGlasses = 8,
  double progress = 0.375,
  VoidCallback? onAdd,
  VoidCallback? onRemove,
}) {
  final currentMl = currentGlasses * 250.0;
  final goalMl = goalGlasses * 250.0;

  return MaterialApp(
    theme: AppTheme.darkTheme,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: WaterTrackerCard(
          currentGlasses: currentGlasses,
          goalGlasses: goalGlasses,
          progress: progress,
          currentMl: currentMl,
          goalMl: goalMl,
          onAdd: onAdd ?? () {},
          onRemove: onRemove ?? () {},
        ),
      ),
    ),
  );
}

void main() {
  group('WaterTrackerCard', () {
    testWidgets('renders Water Intake title', (tester) async {
      await tester.pumpWidget(_buildCard());
      await tester.pumpAndSettle();
      expect(find.text('Water Intake'), findsOneWidget);
    });

    testWidgets('shows correct ml summary text', (tester) async {
      // 3 glasses = 750 ml, goal 8 glasses = 2000 ml
      await tester.pumpWidget(_buildCard(currentGlasses: 3, goalGlasses: 8));
      await tester.pumpAndSettle();
      expect(find.text('750 / 2000 ml'), findsOneWidget);
    });

    testWidgets('shows 0 / goal ml when no water consumed', (tester) async {
      await tester.pumpWidget(_buildCard(currentGlasses: 0, goalGlasses: 10));
      await tester.pumpAndSettle();
      expect(find.text('0 / 2500 ml'), findsOneWidget);
    });

    testWidgets(
      'renders the correct number of glass tiles equal to goalGlasses',
      (tester) async {
        const goal = 6;
        await tester.pumpWidget(
          _buildCard(currentGlasses: 2, goalGlasses: goal),
        );
        await tester.pumpAndSettle();
        // The card generates goalGlasses AnimatedContainers
        final animatedContainers = tester.widgetList<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        expect(animatedContainers.length, goal);
      },
    );

    testWidgets('calls onAdd callback when add button is tapped', (
      tester,
    ) async {
      bool addCalled = false;
      await tester.pumpWidget(_buildCard(onAdd: () => addCalled = true));
      await tester.pumpAndSettle();

      // Find the + button (last IconButton with add icon)
      final addButton = find.byIcon(Icons.add);
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pump();
      expect(addCalled, isTrue);
    });

    testWidgets('calls onRemove callback when remove button is tapped', (
      tester,
    ) async {
      bool removeCalled = false;
      await tester.pumpWidget(
        _buildCard(currentGlasses: 3, onRemove: () => removeCalled = true),
      );
      await tester.pumpAndSettle();

      final removeButton = find.byIcon(Icons.remove);
      expect(removeButton, findsOneWidget);
      await tester.tap(removeButton);
      await tester.pump();
      expect(removeCalled, isTrue);
    });

    testWidgets('renders without crashing when all glasses are full', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildCard(currentGlasses: 8, goalGlasses: 8, progress: 1.0),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('renders without crashing when goal is 0', (tester) async {
      await tester.pumpWidget(
        _buildCard(currentGlasses: 0, goalGlasses: 0, progress: 0.0),
      );
      await tester.pumpAndSettle();
    });
  });
}
