import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilyfit/screens/profile/water_reminder_screen.dart';
import 'package:lilyfit/providers/app_provider.dart';
import 'package:lilyfit/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('WaterReminderScreen', () {
    late AppProvider appProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      appProvider = AppProvider();
      await appProvider.initialize();
    });

    testWidgets('should render water reminder screen', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appProvider,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const WaterReminderScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify hero card is present
      expect(find.text('Stay Hydrated'), findsOneWidget);

      // Verify enable reminders toggle is present
      expect(find.text('Enable Reminders'), findsOneWidget);

      // Verify switch widget is present
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('should show interval options', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appProvider,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const WaterReminderScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify interval options are displayed
      expect(find.text('Every 30 min'), findsOneWidget);
      expect(find.text('Every 45 min'), findsOneWidget);
      expect(find.text('Every hour'), findsOneWidget);
    });

    testWidgets('should display save button', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appProvider,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const WaterReminderScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to the bottom to find the save button
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Save Settings'), findsOneWidget);
    });

    testWidgets('switch should be initially off', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appProvider,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const WaterReminderScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      final switchWidget = tester.widget<Switch>(switchFinder);

      expect(switchWidget.value, isFalse);
    });
  });
}
