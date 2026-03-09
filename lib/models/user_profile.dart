import 'dart:convert';

class UserProfile {
  String name;
  String gender;
  int age;
  double weight; // kg
  double height; // cm
  String activityLevel;
  String goal;
  double targetCalories;
  double targetProtein;
  double targetCarbs;
  double targetFat;

  UserProfile({
    this.name = '',
    this.gender = 'male',
    this.age = 25,
    this.weight = 70,
    this.height = 170,
    this.activityLevel = 'moderate',
    this.goal = 'maintenance',
    this.targetCalories = 2000,
    this.targetProtein = 150,
    this.targetCarbs = 200,
    this.targetFat = 67,
  });

  void calculateTargets() {
    // Mifflin-St Jeor Equation
    double bmr;
    if (gender == 'male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    // Activity multiplier
    final double activityMultiplier = switch (activityLevel) {
      'sedentary' => 1.2,
      'light' => 1.375,
      'moderate' => 1.55,
      'active' => 1.725,
      'veryActive' => 1.9,
      _ => 1.55,
    };

    double tdee = bmr * activityMultiplier;

    // Goal adjustment
    targetCalories = switch (goal) {
      'fatLoss' => (tdee - 500).roundToDouble(),
      'muscleGain' => (tdee + 300).roundToDouble(),
      _ => tdee.roundToDouble(),
    };

    // Macro splits based on goal
    final (double proteinPct, double carbsPct, double fatPct) = switch (goal) {
      'fatLoss' => (0.40, 0.30, 0.30),
      'muscleGain' => (0.30, 0.45, 0.25),
      _ => (0.30, 0.40, 0.30),
    };

    // Protein: 4 cal/g, Carbs: 4 cal/g, Fat: 9 cal/g
    targetProtein = (targetCalories * proteinPct / 4).roundToDouble();
    targetCarbs = (targetCalories * carbsPct / 4).roundToDouble();
    targetFat = (targetCalories * fatPct / 9).roundToDouble();
  }

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiCategory {
    final b = bmi;
    if (b < 18.5) return 'Underweight';
    if (b < 25) return 'Normal';
    if (b < 30) return 'Overweight';
    return 'Obese';
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'gender': gender,
    'age': age,
    'weight': weight,
    'height': height,
    'activityLevel': activityLevel,
    'goal': goal,
    'targetCalories': targetCalories,
    'targetProtein': targetProtein,
    'targetCarbs': targetCarbs,
    'targetFat': targetFat,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? '',
    gender: json['gender'] ?? 'male',
    age: json['age'] ?? 25,
    weight: (json['weight'] ?? 70).toDouble(),
    height: (json['height'] ?? 170).toDouble(),
    activityLevel: json['activityLevel'] ?? 'moderate',
    goal: json['goal'] ?? 'maintenance',
    targetCalories: (json['targetCalories'] ?? 2000).toDouble(),
    targetProtein: (json['targetProtein'] ?? 150).toDouble(),
    targetCarbs: (json['targetCarbs'] ?? 200).toDouble(),
    targetFat: (json['targetFat'] ?? 67).toDouble(),
  );

  String encode() => jsonEncode(toJson());

  static UserProfile decode(String json) =>
      UserProfile.fromJson(jsonDecode(json));
}
