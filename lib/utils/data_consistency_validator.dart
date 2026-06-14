import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';

class DataConsistencyValidator {
  final SupabaseService _supabaseService;

  DataConsistencyValidator(this._supabaseService);

  Future<ValidationReport> validateMealLogs({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final report = ValidationReport();

    try {
      final meals = await _supabaseService.getMealLogsInRange(
        startDate:
            startDate ?? DateTime.now().subtract(const Duration(days: 90)),
        endDate: endDate ?? DateTime.now(),
      );

      for (var meal in meals) {
        final servings = (meal['servings'] as num?)?.toDouble() ?? 1.0;
        final calories = (meal['calories'] as num?)?.toDouble() ?? 0.0;
        final protein = (meal['protein'] as num?)?.toDouble() ?? 0.0;

        final caloriesPerServing = servings > 0
            ? calories / servings
            : calories;
        final proteinPerServing = servings > 0 ? protein / servings : protein;

        final suspiciousCalories =
            caloriesPerServing < 5 || caloriesPerServing > 2000;
        final suspiciousProtein =
            proteinPerServing < 0 || proteinPerServing > 200;

        if (suspiciousCalories || suspiciousProtein) {
          report.suspiciousEntries.add({
            'id': meal['id'],
            'food_name': meal['food_name'],
            'servings': servings,
            'calories': calories,
            'protein': protein,
            'calories_per_serving': caloriesPerServing.toStringAsFixed(1),
            'protein_per_serving': proteinPerServing.toStringAsFixed(1),
            'date': meal['date'],
            'issues': [
              if (suspiciousCalories) 'Unusual calories per serving',
              if (suspiciousProtein) 'Unusual protein per serving',
            ],
          });
        }

        report.totalEntriesChecked++;
      }
    } catch (e) {
      report.error = e.toString();
      debugPrint('Error validating meal logs: $e');
    }

    return report;
  }

  Future<DataStatistics> getDataStatistics() async {
    final stats = DataStatistics();

    try {
      final meals = await _supabaseService.getMealLogsInRange(
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now(),
      );

      stats.totalMealLogs = meals.length;

      double totalCalories = 0;
      double totalProtein = 0;
      int multiServingCount = 0;

      for (var meal in meals) {
        final servings = (meal['servings'] as num?)?.toDouble() ?? 1.0;
        final calories = (meal['calories'] as num?)?.toDouble() ?? 0.0;
        final protein = (meal['protein'] as num?)?.toDouble() ?? 0.0;

        totalCalories += calories;
        totalProtein += protein;

        if (servings > 1) {
          multiServingCount++;
        }
      }

      stats.averageCalories = totalCalories / meals.length;
      stats.averageProtein = totalProtein / meals.length;
      stats.multiServingEntries = multiServingCount;
    } catch (e) {
      stats.error = e.toString();
      debugPrint('Error getting data statistics: $e');
    }

    return stats;
  }

  Future<bool> isLikelyAffected() async {
    try {
      final meals = await _supabaseService.getMealLogsInRange(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 5, 21),
      );

      int suspiciousCount = 0;
      int multiServingCount = 0;

      for (var meal in meals) {
        final servings = (meal['servings'] as num?)?.toDouble() ?? 1.0;

        if (servings > 1) {
          multiServingCount++;

          final calories = (meal['calories'] as num?)?.toDouble() ?? 0.0;
          final caloriesPerServing = calories / servings;

          if (caloriesPerServing > 800) {
            suspiciousCount++;
          }
        }
      }

      if (multiServingCount > 0 && suspiciousCount / multiServingCount > 0.3) {
        return true;
      }
    } catch (e) {
      debugPrint('Error checking if user is affected: $e');
    }

    return false;
  }
}

class ValidationReport {
  int totalEntriesChecked = 0;
  List<Map<String, dynamic>> suspiciousEntries = [];
  String? error;

  bool get hasIssues => suspiciousEntries.isNotEmpty;

  int get suspiciousCount => suspiciousEntries.length;

  String get summary {
    if (error != null) {
      return 'Error: $error';
    }

    if (!hasIssues) {
      return 'No issues found in $totalEntriesChecked entries ✓';
    }

    return 'Found $suspiciousCount suspicious entries out of $totalEntriesChecked checked';
  }
}

class DataStatistics {
  int totalMealLogs = 0;
  double averageCalories = 0;
  double averageProtein = 0;
  int multiServingEntries = 0;
  String? error;

  String get summary {
    if (error != null) {
      return 'Error: $error';
    }

    return '''
Total meal logs: $totalMealLogs
Average calories per entry: ${averageCalories.toStringAsFixed(0)}
Average protein per entry: ${averageProtein.toStringAsFixed(1)}g
Entries with multiple servings: $multiServingEntries
''';
  }
}
