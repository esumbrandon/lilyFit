import 'package:flutter_test/flutter_test.dart';
import 'package:lilyfit/utils/unit_converter.dart';

void main() {
  group('UnitConverter', () {
    group('kgToLbs', () {
      test('converts 1 kg to ~2.20462 lbs', () {
        expect(UnitConverter.kgToLbs(1.0), closeTo(2.20462, 0.00001));
      });

      test('converts 70 kg to ~154.32 lbs', () {
        expect(UnitConverter.kgToLbs(70.0), closeTo(154.323, 0.001));
      });

      test('converts 0 kg to 0 lbs', () {
        expect(UnitConverter.kgToLbs(0.0), 0.0);
      });

      test('converts 100 kg correctly', () {
        expect(UnitConverter.kgToLbs(100.0), closeTo(220.462, 0.001));
      });
    });

    group('lbsToKg', () {
      test('converts 1 lbs to ~0.4536 kg', () {
        expect(UnitConverter.lbsToKg(1.0), closeTo(0.4536, 0.0001));
      });

      test('is inverse of kgToLbs', () {
        expect(
          UnitConverter.lbsToKg(UnitConverter.kgToLbs(75.0)),
          closeTo(75.0, 0.0001),
        );
      });

      test('converts 0 lbs to 0 kg', () {
        expect(UnitConverter.lbsToKg(0.0), 0.0);
      });
    });

    group('cmToFeet', () {
      test('converts 30.48 cm to 1.0 foot', () {
        expect(UnitConverter.cmToFeet(30.48), closeTo(1.0, 0.0001));
      });

      test('converts 170 cm to ~5.577 feet', () {
        expect(UnitConverter.cmToFeet(170.0), closeTo(5.577, 0.001));
      });

      test('converts 0 cm to 0 feet', () {
        expect(UnitConverter.cmToFeet(0.0), 0.0);
      });
    });

    group('feetToCm', () {
      test('converts 1 foot to 30.48 cm', () {
        expect(UnitConverter.feetToCm(1.0), closeTo(30.48, 0.0001));
      });

      test('is inverse of cmToFeet', () {
        expect(
          UnitConverter.feetToCm(UnitConverter.cmToFeet(180.0)),
          closeTo(180.0, 0.0001),
        );
      });
    });

    group('cmToFeetInches', () {
      test('converts 180 cm to 5 feet and ~11.0 inches', () {
        final (feet, inches) = UnitConverter.cmToFeetInches(180.0);
        // 180 / 2.54 = 70.866 inches → 5 feet, 10.866 inches
        expect(feet, 5);
        expect(inches, closeTo(10.866, 0.01));
      });

      test('converts 152.4 cm to exactly 5 feet 0 inches', () {
        // 152.4 / 2.54 = 60 inches = 5 feet exactly
        final (feet, inches) = UnitConverter.cmToFeetInches(152.4);
        expect(feet, 5);
        expect(inches, closeTo(0.0, 0.001));
      });

      test('converts 30.48 cm to 1 foot 0 inches', () {
        final (feet, inches) = UnitConverter.cmToFeetInches(30.48);
        expect(feet, 1);
        expect(inches, closeTo(0.0, 0.001));
      });
    });

    group('feetInchesToCm', () {
      test('converts 5 feet 0 inches to 152.4 cm', () {
        expect(UnitConverter.feetInchesToCm(5, 0), closeTo(152.4, 0.001));
      });

      test('converts 6 feet 0 inches to 182.88 cm', () {
        expect(UnitConverter.feetInchesToCm(6, 0), closeTo(182.88, 0.001));
      });

      test('is inverse of cmToFeetInches', () {
        final (feet, inches) = UnitConverter.cmToFeetInches(175.0);
        expect(
          UnitConverter.feetInchesToCm(feet, inches),
          closeTo(175.0, 0.001),
        );
      });

      test('converts 0 feet 0 inches to 0 cm', () {
        expect(UnitConverter.feetInchesToCm(0, 0.0), 0.0);
      });
    });

    group('formatWeight', () {
      test('formats kg weight with one decimal', () {
        expect(UnitConverter.formatWeight(70.0, 'kg'), '70.0 kg');
      });

      test('formats lbs weight by converting from kg', () {
        // 70 kg → 154.3234 lbs → '154.3 lbs'
        expect(UnitConverter.formatWeight(70.0, 'lbs'), '154.3 lbs');
      });

      test('defaults to kg format for other unit strings', () {
        expect(UnitConverter.formatWeight(65.5, 'metric'), '65.5 kg');
      });
    });

    group('formatHeight', () {
      test('formats cm height as integer with cm label', () {
        expect(UnitConverter.formatHeight(170.0, 'cm'), '170 cm');
      });

      test('formats ft height as feet and inches', () {
        // 170 cm: 170/2.54 = 66.929 inches → 5 feet, 6.929 inches
        final result = UnitConverter.formatHeight(170.0, 'ft');
        expect(result, contains("5'"));
        expect(result, contains('"'));
      });

      test('defaults to cm format for other unit strings', () {
        expect(UnitConverter.formatHeight(160.0, 'metric'), '160 cm');
      });
    });
  });
}
