import 'food_item.dart';

enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeExtension on MealType {
  String get label => switch (this) {
    MealType.breakfast => 'Breakfast',
    MealType.lunch => 'Lunch',
    MealType.dinner => 'Dinner',
    MealType.snack => 'Snack',
  };

  String get emoji => switch (this) {
    MealType.breakfast => '🌅',
    MealType.lunch => '☀️',
    MealType.dinner => '🌙',
    MealType.snack => '🍎',
  };
}

class MealLog {
  final String id;
  final FoodItem food;
  final MealType mealType;
  final double servings;
  final DateTime dateTime;

  MealLog({
    required this.id,
    required this.food,
    required this.mealType,
    this.servings = 1.0,
    required this.dateTime,
  });

  double get totalCalories => food.calories * servings;
  double get totalProtein => food.protein * servings;
  double get totalCarbs => food.carbs * servings;
  double get totalFat => food.fat * servings;

  Map<String, dynamic> toJson() => {
    'id': id,
    'food': food.toJson(),
    'mealType': mealType.index,
    'servings': servings,
    'dateTime': dateTime.toIso8601String(),
  };

  factory MealLog.fromJson(Map<String, dynamic> json) => MealLog(
    id: json['id'],
    food: FoodItem.fromJson(json['food']),
    mealType: MealType.values[json['mealType']],
    servings: (json['servings']).toDouble(),
    dateTime: DateTime.parse(json['dateTime']),
  );
}

class WeightEntry {
  final DateTime date;
  final double weight;

  WeightEntry({required this.date, required this.weight});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'weight': weight,
  };

  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
    date: DateTime.parse(json['date']),
    weight: (json['weight']).toDouble(),
  );
}
