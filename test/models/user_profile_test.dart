import 'package:flutter_test/flutter_test.dart';
import 'package:lilyfit/models/user_profile.dart';

void main() {
  // Shared test profile: male, 70kg, 170cm, 25yo, moderate, maintenance
  // BMR (male) = 10*70 + 6.25*170 - 5*25 + 5 = 1642.5
  // TDEE (moderate, ×1.55) = 1642.5 * 1.55 = 2545.875 → 2546 kcal
  UserProfile maleModerateMaintenance() => UserProfile(
    gender: 'male',
    age: 25,
    weight: 70,
    height: 170,
    activityLevel: 'moderate',
    goal: 'maintenance',
  );

  group('UserProfile defaults', () {
    test('default profile has sensible values', () {
      final p = UserProfile();
      expect(p.name, '');
      expect(p.gender, 'male');
      expect(p.age, 25);
      expect(p.weight, 70);
      expect(p.height, 170);
      expect(p.activityLevel, 'moderate');
      expect(p.goal, 'maintenance');
      expect(p.weightUnit, 'kg');
      expect(p.heightUnit, 'cm');
    });
  });

  group('calculateTargets', () {
    group('male – maintenance – moderate', () {
      test('sets correct targetCalories', () {
        final p = maleModerateMaintenance()..calculateTargets();
        expect(p.targetCalories, 2546.0);
      });

      test('sets correct macro targets', () {
        final p = maleModerateMaintenance()..calculateTargets();
        expect(p.targetProtein, 191.0);
        expect(p.targetCarbs, 255.0);
        expect(p.targetFat, 85.0);
      });
    });

    group('female – maintenance – moderate', () {
      test('sets correct targetCalories', () {
        final p = UserProfile(
          gender: 'female',
          age: 25,
          weight: 70,
          height: 170,
          activityLevel: 'moderate',
          goal: 'maintenance',
        )..calculateTargets();
        expect(p.targetCalories, 2289.0);
      });

      test('sets correct macro targets', () {
        final p = UserProfile(
          gender: 'female',
          age: 25,
          weight: 70,
          height: 170,
          activityLevel: 'moderate',
          goal: 'maintenance',
        )..calculateTargets();
        expect(p.targetProtein, 172.0);
        expect(p.targetCarbs, 229.0);
        expect(p.targetFat, 76.0);
      });
    });

    group('other gender – uses average BMR', () {
      test('sets correct targetCalories', () {
        final p = UserProfile(
          gender: 'other',
          age: 25,
          weight: 70,
          height: 170,
          activityLevel: 'moderate',
          goal: 'maintenance',
        )..calculateTargets();
        expect(p.targetCalories, 2417.0);
      });
    });

    group('goal adjustments', () {
      test('fatLoss subtracts 500 kcal from TDEE', () {
        final p = UserProfile(
          gender: 'male',
          age: 25,
          weight: 70,
          height: 170,
          activityLevel: 'moderate',
          goal: 'fatLoss',
        )..calculateTargets();
        expect(p.targetCalories, 2046.0);

        expect(p.targetProtein, 205.0);
        expect(p.targetCarbs, 153.0);
        expect(p.targetFat, 68.0);
      });

      test('muscleGain adds 300 kcal to TDEE', () {
        final p = UserProfile(
          gender: 'male',
          age: 25,
          weight: 70,
          height: 170,
          activityLevel: 'moderate',
          goal: 'muscleGain',
        )..calculateTargets();
        expect(p.targetCalories, 2846.0);

        expect(p.targetProtein, 213.0);
        expect(p.targetCarbs, 320.0);
        expect(p.targetFat, 79.0);
      });
    });

    group('activity level multipliers', () {
      test('sedentary multiplier 1.2 → 1971 kcal', () {
        final p = UserProfile(
          gender: 'male',
          age: 25,
          weight: 70,
          height: 170,
          activityLevel: 'sedentary',
          goal: 'maintenance',
        )..calculateTargets();
        expect(p.targetCalories, 1971.0);
      });

      test('light multiplier 1.375 → 2258 kcal', () {
        final p = UserProfile(
          gender: 'male',
          age: 25,
          weight: 70,
          height: 170,
          activityLevel: 'light',
          goal: 'maintenance',
        )..calculateTargets();
        expect(p.targetCalories, 2258.0);
      });

      test('active multiplier 1.725 → 2833 kcal', () {
        final p = UserProfile(
          gender: 'male',
          age: 25,
          weight: 70,
          height: 170,
          activityLevel: 'active',
          goal: 'maintenance',
        )..calculateTargets();
        expect(p.targetCalories, 2833.0);
      });

      test('veryActive multiplier 1.9 → 3121 kcal', () {
        final p = UserProfile(
          gender: 'male',
          age: 25,
          weight: 70,
          height: 170,
          activityLevel: 'veryActive',
          goal: 'maintenance',
        )..calculateTargets();
        expect(p.targetCalories, 3121.0);
      });

      test('unknown activity level defaults to moderate (1.55)', () {
        final p = UserProfile(
          gender: 'male',
          age: 25,
          weight: 70,
          height: 170,
          activityLevel: 'unknown_value',
          goal: 'maintenance',
        )..calculateTargets();
        expect(p.targetCalories, 2546.0);
      });
    });
  });

  group('bmi', () {
    test('calculates correct BMI for normal weight', () {
      final p = UserProfile(weight: 70, height: 170);
      // 70 / (1.70^2) = 70 / 2.89 ≈ 24.22
      expect(p.bmi, closeTo(24.22, 0.01));
    });

    test('calculates correct BMI for higher weight', () {
      final p = UserProfile(weight: 90, height: 170);
      // 90 / (1.70^2) ≈ 31.14
      expect(p.bmi, closeTo(31.14, 0.01));
    });
  });

  group('bmiCategory', () {
    test('returns Underweight for BMI < 18.5', () {
      final p = UserProfile(weight: 50, height: 180);
      expect(p.bmiCategory, 'Underweight');
    });

    test('returns Normal for BMI 18.5–24.9', () {
      final p = UserProfile(weight: 70, height: 170);
      expect(p.bmiCategory, 'Normal');
    });

    test('returns Overweight for BMI 25–29.9', () {
      final p = UserProfile(weight: 80, height: 170);
      expect(p.bmiCategory, 'Overweight');
    });

    test('returns Obese for BMI ≥ 30', () {
      final p = UserProfile(weight: 100, height: 170);
      expect(p.bmiCategory, 'Obese');
    });
  });

  group('JSON serialization', () {
    test('toJson/fromJson round-trip preserves all fields', () {
      final original = UserProfile(
        name: 'Alice',
        email: 'alice@example.com',
        gender: 'female',
        age: 30,
        weight: 65.0,
        height: 165.0,
        activityLevel: 'active',
        goal: 'fatLoss',
        targetCalories: 1800.0,
        targetProtein: 180.0,
        targetCarbs: 135.0,
        targetFat: 60.0,
        weightUnit: 'lbs',
        heightUnit: 'ft',
      );

      final restored = UserProfile.fromJson(original.toJson());

      expect(restored.name, original.name);
      expect(restored.email, original.email);
      expect(restored.gender, original.gender);
      expect(restored.age, original.age);
      expect(restored.weight, original.weight);
      expect(restored.height, original.height);
      expect(restored.activityLevel, original.activityLevel);
      expect(restored.goal, original.goal);
      expect(restored.targetCalories, original.targetCalories);
      expect(restored.targetProtein, original.targetProtein);
      expect(restored.targetCarbs, original.targetCarbs);
      expect(restored.targetFat, original.targetFat);
      expect(restored.weightUnit, original.weightUnit);
      expect(restored.heightUnit, original.heightUnit);
    });

    test('encode/decode round-trip via JSON string', () {
      final original = UserProfile(
        name: 'Bob',
        age: 35,
        weight: 85.0,
        height: 180.0,
      );
      final decoded = UserProfile.decode(original.encode());
      expect(decoded.name, original.name);
      expect(decoded.age, original.age);
      expect(decoded.weight, original.weight);
      expect(decoded.height, original.height);
    });

    test('fromJson uses defaults for missing keys', () {
      final p = UserProfile.fromJson({});
      expect(p.name, '');
      expect(p.email, '');
      expect(p.gender, 'male');
      expect(p.age, 25);
      expect(p.weight, 70.0);
      expect(p.height, 170.0);
      expect(p.activityLevel, 'moderate');
      expect(p.goal, 'maintenance');
      expect(p.weightUnit, 'kg');
      expect(p.heightUnit, 'cm');
    });
  });
}
