import 'package:flutter_test/flutter_test.dart';
import 'package:lilyfit/models/food_item.dart';
import 'package:lilyfit/models/meal_log.dart';

void main() {
  const chicken = FoodItem(
    id: 'chicken_001',
    name: 'Grilled Chicken',
    calories: 165.0,
    protein: 31.0,
    carbs: 0.0,
    fat: 3.6,
    servingSize: '100g',
    region: 'Global',
  );

  group('MealLog', () {
    final dateTime = DateTime(2024, 6, 15, 12, 30);

    group('nutritional totals', () {
      test('totals with 1.0 servings equal food macros', () {
        final log = MealLog(
          id: 'log_1',
          food: chicken,
          mealType: MealType.lunch,
          servings: 1.0,
          dateTime: dateTime,
        );
        expect(log.totalCalories, 165.0);
        expect(log.totalProtein, 31.0);
        expect(log.totalCarbs, 0.0);
        expect(log.totalFat, closeTo(3.6, 0.001));
      });

      test('totals scale correctly with 2.5 servings', () {
        final log = MealLog(
          id: 'log_2',
          food: chicken,
          mealType: MealType.dinner,
          servings: 2.5,
          dateTime: dateTime,
        );
        expect(log.totalCalories, closeTo(412.5, 0.001));
        expect(log.totalProtein, closeTo(77.5, 0.001));
        expect(log.totalCarbs, 0.0);
        expect(log.totalFat, closeTo(9.0, 0.001));
      });

      test('totals are 0 with 0.0 servings', () {
        final log = MealLog(
          id: 'log_3',
          food: chicken,
          mealType: MealType.snack,
          servings: 0.0,
          dateTime: dateTime,
        );
        expect(log.totalCalories, 0.0);
        expect(log.totalProtein, 0.0);
      });
    });

    test('default servings is 1.0', () {
      final log = MealLog(
        id: 'log_default',
        food: chicken,
        mealType: MealType.breakfast,
        dateTime: dateTime,
      );
      expect(log.servings, 1.0);
    });

    group('JSON serialization', () {
      final log = MealLog(
        id: 'log_json',
        food: chicken,
        mealType: MealType.dinner,
        servings: 1.5,
        dateTime: DateTime(2024, 6, 15, 19, 0),
      );

      test('toJson includes all required fields', () {
        final json = log.toJson();
        expect(json.containsKey('id'), isTrue);
        expect(json.containsKey('food'), isTrue);
        expect(json.containsKey('mealType'), isTrue);
        expect(json.containsKey('servings'), isTrue);
        expect(json.containsKey('dateTime'), isTrue);
      });

      test('mealType is stored as index', () {
        final json = log.toJson();
        expect(json['mealType'], MealType.dinner.index);
      });

      test('round-trip preserves all data', () {
        final json = log.toJson();
        final restored = MealLog.fromJson(json);
        expect(restored.id, log.id);
        expect(restored.food.id, log.food.id);
        expect(restored.mealType, log.mealType);
        expect(restored.servings, log.servings);
        expect(restored.dateTime, log.dateTime);
      });
    });
  });

  group('WeightEntry', () {
    test('stores date and weight', () {
      final entry = WeightEntry(date: DateTime(2024, 3, 15), weight: 75.5);
      expect(entry.weight, 75.5);
      expect(entry.date, DateTime(2024, 3, 15));
    });

    test('toJson/fromJson round-trip preserves data', () {
      final entry = WeightEntry(
        date: DateTime(2024, 3, 15, 9, 0),
        weight: 82.3,
      );
      final json = entry.toJson();
      final restored = WeightEntry.fromJson(json);
      expect(restored.date, entry.date);
      expect(restored.weight, entry.weight);
    });

    test('fromJson casts integer weight to double', () {
      final json = {
        'date': DateTime(2024, 1, 1).toIso8601String(),
        'weight': 80,
      };
      final entry = WeightEntry.fromJson(json);
      expect(entry.weight, isA<double>());
      expect(entry.weight, 80.0);
    });
  });
}
