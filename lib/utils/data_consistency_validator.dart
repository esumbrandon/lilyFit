import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';

/// Utility class to validate and fix data consistency issues
/// that may have occurred from the iOS/Android sync bug
class DataConsistencyValidator {
  final SupabaseService _supabaseService;

  DataConsistencyValidator(this._supabaseService);

  /// Validate meal logs for potential double-multiplication issues
  /// Returns a report of suspicious entries
  Future<ValidationReport> validateMealLogs({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final report = ValidationReport();

    try {
      // Get all meal logs in range
      final meals = await _supabaseService.getMealLogsInRange(
        startDate: startDate ?? DateTime.now().subtract(const Duration(days: 90)),
        endDate: endDate ?? DateTime.now(),
      );

      for (var meal in meals) {
        final servings = (meal['servings'] as num?)?.toDouble() ?? 1.0;
        final calories = (meal['calories'] as num?)?.toDouble() ?? 0.0;
        final protein = (meal['protein'] as num?)?.toDouble() ?? 0.0;

        // Calculate per-serving values
        final caloriesPerServing = servings > 0 ? calories / servings : calories;
        final proteinPerServing = servings > 0 ? protein / servings : protein;

        // Flag suspicious entries
        // Most foods have 20-2000 calories per serving
        // Protein is usually 0-100g per serving
        final suspiciousCalories = caloriesPerServing < 5 || caloriesPerServing > 2000;
        final suspiciousProtein = proteinPerServing < 0 || proteinPerServing > 200;

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

  /// Get statistics about user's meal logs
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

  /// Check if user's data might be affected by the double-multiplication bug
  /// Returns true if there are signs of the bug
  Future<bool> isLikelyAffected() async {
    try {
      // Get recent meals with multiple servings
      final meals = await _supabaseService.getMealLogsInRange(
        startDate: DateTime(2026, 1, 1), // Start of year
        endDate: DateTime(2026, 5, 21),  // Before fix was deployed
      );

      int suspiciousCount = 0;
      int multiServingCount = 0;

      for (var meal in meals) {
        final servings = (meal['servings'] as num?)?.toDouble() ?? 1.0;

        if (servings > 1) {
          multiServingCount++;

          final calories = (meal['calories'] as num?)?.toDouble() ?? 0.0;
          final caloriesPerServing = calories / servings;

          // If calories per serving is very high, it might be doubled
          // Most single servings don't exceed 800 calories
          if (caloriesPerServing > 800) {
            suspiciousCount++;
          }
        }
      }

      // If more than 30% of multi-serving entries look suspicious, user is likely affected
      if (multiServingCount > 0 && suspiciousCount / multiServingCount > 0.3) {
        return true;
      }

    } catch (e) {
      debugPrint('Error checking if user is affected: $e');
    }

    return false;
  }
}

/// Report from validation check
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

/// Statistics about user's data
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

