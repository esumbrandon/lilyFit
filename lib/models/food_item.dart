class FoodItem {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String servingSize;
  final String region;
  final String emoji;

  const FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
    required this.region,
    this.emoji = '🍽️',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'servingSize': servingSize,
    'region': region,
    'emoji': emoji,
  };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
    id: json['id'],
    name: json['name'],
    calories: (json['calories']).toDouble(),
    protein: (json['protein']).toDouble(),
    carbs: (json['carbs']).toDouble(),
    fat: (json['fat']).toDouble(),
    servingSize: json['servingSize'],
    region: json['region'],
    emoji: json['emoji'] ?? '🍽️',
  );
}
