import 'package:flutter_test/flutter_test.dart';
import 'package:lilyfit/models/food_item.dart';

void main() {
  group('FoodItem', () {
    const food = FoodItem(
      id: 'rice_001',
      name: 'Steamed Rice',
      calories: 200.0,
      protein: 4.0,
      carbs: 44.0,
      fat: 0.4,
      servingSize: '100g',
      region: 'Asian',
      emoji: '🍚',
    );

    test('default emoji is 🍽️ when not specified', () {
      const noEmoji = FoodItem(
        id: 'egg_001',
        name: 'Boiled Egg',
        calories: 70.0,
        protein: 6.0,
        carbs: 0.5,
        fat: 5.0,
        servingSize: '1 large',
        region: 'Global',
      );
      expect(noEmoji.emoji, '🍽️');
    });

    test('all fields are stored correctly', () {
      expect(food.id, 'rice_001');
      expect(food.name, 'Steamed Rice');
      expect(food.calories, 200.0);
      expect(food.protein, 4.0);
      expect(food.carbs, 44.0);
      expect(food.fat, 0.4);
      expect(food.servingSize, '100g');
      expect(food.region, 'Asian');
      expect(food.emoji, '🍚');
    });

    group('toJson', () {
      test('includes all fields', () {
        final json = food.toJson();
        expect(json['id'], 'rice_001');
        expect(json['name'], 'Steamed Rice');
        expect(json['calories'], 200.0);
        expect(json['protein'], 4.0);
        expect(json['carbs'], 44.0);
        expect(json['fat'], 0.4);
        expect(json['servingSize'], '100g');
        expect(json['region'], 'Asian');
        expect(json['emoji'], '🍚');
      });
    });

    group('fromJson', () {
      test('round-trip preserves all fields', () {
        final json = food.toJson();
        final restored = FoodItem.fromJson(json);

        expect(restored.id, food.id);
        expect(restored.name, food.name);
        expect(restored.calories, food.calories);
        expect(restored.protein, food.protein);
        expect(restored.carbs, food.carbs);
        expect(restored.fat, food.fat);
        expect(restored.servingSize, food.servingSize);
        expect(restored.region, food.region);
        expect(restored.emoji, food.emoji);
      });

      test('uses default emoji when emoji key is missing', () {
        final json = food.toJson()..remove('emoji');
        final restored = FoodItem.fromJson(json);
        expect(restored.emoji, '🍽️');
      });

      test('casts integer calories to double', () {
        final json = food.toJson();
        json['calories'] = 200;
        json['protein'] = 4;
        json['carbs'] = 44;
        json['fat'] = 0;
        final restored = FoodItem.fromJson(json);
        expect(restored.calories, isA<double>());
        expect(restored.protein, isA<double>());
        expect(restored.carbs, isA<double>());
        expect(restored.fat, isA<double>());
      });
    });
  });
}
