class UnitConverter {
  // Weight conversions
  static double kgToLbs(double kg) => kg * 2.20462;
  static double lbsToKg(double lbs) => lbs / 2.20462;

  // Height conversions
  static double cmToFeet(double cm) => cm / 30.48;
  static double feetToCm(double feet) => feet * 30.48;

  // Height to feet and inches
  static (int feet, double inches) cmToFeetInches(double cm) {
    final totalInches = cm / 2.54;
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return (feet, inches);
  }

  static double feetInchesToCm(int feet, double inches) {
    final totalInches = (feet * 12) + inches;
    return totalInches * 2.54;
  }

  // Format display values
  static String formatWeight(double weight, String unit) {
    if (unit == 'lbs') {
      return '${kgToLbs(weight).toStringAsFixed(1)} lbs';
    }
    return '${weight.toStringAsFixed(1)} kg';
  }

  static String formatHeight(double height, String unit) {
    if (unit == 'ft') {
      final (feet, inches) = cmToFeetInches(height);
      return '$feet\' ${inches.toStringAsFixed(1)}"';
    }
    return '${height.toInt()} cm';
  }
}
