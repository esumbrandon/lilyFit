# LilyFit Integration Tests

Comprehensive integration tests for the LilyFit mobile application, covering all key user flows and features.

## Overview

This test suite validates the complete user experience of LilyFit, from onboarding to daily nutrition tracking. The tests are organized by feature/flow and can be run individually or as a complete suite.

## Test Files

### 1. **onboarding_flow_test.dart**
Tests the complete user onboarding experience:
- Welcome screens and navigation
- Name, gender, age, weight, height input
- Activity level selection
- Goal selection (Fat Loss, Muscle Gain, Maintenance)
- Water goal configuration
- Profile validation and data persistence
- Unit switching (kg/lbs, cm/ft)

### 2. **nutrition_tracking_flow_test.dart**
Tests food search and meal logging:
- Food database search functionality
- Regional food filtering
- Meal logging for all meal types (Breakfast, Lunch, Dinner, Snack)
- Serving size adjustments
- Meal removal/deletion
- Real-time calorie and macro updates
- Calorie ring visualization
- Macro progress bars

### 3. **water_tracking_flow_test.dart**
Tests water intake tracking:
- Adding water intake
- Removing water intake
- Water progress indicators
- Daily goal completion
- Custom water goal settings
- Visual progress updates
- Water intake persistence
- Boundary conditions (cannot go below zero)

### 4. **progress_flow_test.dart**
Tests weight tracking and progress visualization:
- Weight entry adding/editing/deleting
- Weight chart displays
- Time period filtering (7D, 1M, All)
- Progress statistics calculation
- Weight loss/gain trends
- BMI calculations
- Unit conversion (kg/lbs)
- Empty state handling

### 5. **profile_flow_test.dart**
Tests profile management and settings:
- Profile information display
- Profile editing
- Activity level changes
- Goal changes (recalculates targets)
- Theme mode toggling
- Language selection
- Water reminder settings
- Macro target display
- Data export functionality
- Data reset/clearing

### 6. **complete_user_journey_test.dart**
End-to-end tests simulating real user scenarios:
- **New User Journey**: Complete onboarding → Log meals throughout the day → Track water → View progress
- **Returning User**: Quick daily logging workflow
- **Error Correction**: Remove incorrect meal and re-log
- **Multi-day Usage**: Track progress over multiple days

### 7. **app_test.dart** (Existing)
Unit-level integration tests for provider logic:
- Onboarding completion
- Nutrition tracking
- Water tracking
- Weight tracking
- Data reset
- Locale management

## Running the Tests

### Prerequisites

1. **Flutter SDK** installed and configured
2. **Device or Emulator** running (iOS Simulator, Android Emulator, or physical device)
3. **Dependencies** installed: `flutter pub get`

### Quick Start

#### Using the Test Runner Script (Recommended)

```bash
# Make the script executable (first time only)
chmod +x run_integration_tests.sh

# Run the interactive test runner
./run_integration_tests.sh
```

The script provides an interactive menu to run:
1. All tests
2. Individual test suites
3. Quick smoke test

#### Manual Execution

Run individual test files:

```bash
# Onboarding flow
flutter test integration_test/onboarding_flow_test.dart

# Nutrition tracking
flutter test integration_test/nutrition_tracking_flow_test.dart

# Water tracking
flutter test integration_test/water_tracking_flow_test.dart

# Progress tracking
flutter test integration_test/progress_flow_test.dart

# Profile management
flutter test integration_test/profile_flow_test.dart

# Complete user journey
flutter test integration_test/complete_user_journey_test.dart

# Existing unit tests
flutter test integration_test/app_test.dart
```

Run all integration tests:

```bash
flutter test integration_test/
```

### Running on Specific Devices

```bash
# List available devices
flutter devices

# Run on specific device
flutter test integration_test/onboarding_flow_test.dart -d <device_id>

# Examples:
flutter test integration_test/ -d iPhone            # iOS Simulator
flutter test integration_test/ -d emulator-5554     # Android Emulator
flutter test integration_test/ -d 00008030-001234567890001E  # Physical iPhone
```

### Running with Different Configurations

```bash
# Run in release mode for performance testing
flutter test integration_test/ --release

# Run with specific timeout
flutter test integration_test/ --timeout=5m

# Run with verbose output
flutter test integration_test/ --verbose

# Generate coverage report
flutter test integration_test/ --coverage
```

## Test Structure

Each test file follows this structure:

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Feature Name Tests', () {
    late AppProvider provider;

    setUp(() async {
      // Setup test environment
      SharedPreferences.setMockInitialValues({});
      provider = AppProvider();
      await provider.initialize();
    });

    testWidgets('Test case description', (tester) async {
      // Test implementation
    });
  });
}
```

## Best Practices

### 1. **Isolated Tests**
Each test starts with a clean state using `SharedPreferences.setMockInitialValues({})`.

### 2. **Proper Pumping**
- Use `pumpAndSettle()` after navigation or major state changes
- Use `pump()` with duration for animations
- Use `pumpAndSettle(Duration)` for long-running operations

### 3. **Realistic User Interactions**
Tests simulate real user behavior:
- Tapping buttons
- Entering text
- Scrolling
- Navigation

### 4. **Assertions**
Multiple assertion types:
- Widget presence: `expect(find.text('Hello'), findsOneWidget)`
- State validation: `expect(provider.isOnboarded, isTrue)`
- Numeric comparisons: `expect(calories, greaterThan(0))`
- Approximate values: `expect(value, closeTo(expected, delta))`

### 5. **Error Handling**
Tests handle widgets that may not exist:
```dart
if (button.evaluate().isNotEmpty) {
  await tester.tap(button);
}
```

## Continuous Integration

### GitHub Actions

Create `.github/workflows/integration_tests.yml`:

```yaml
name: Integration Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test integration_test/
```

### Local CI

```bash
# Run all tests with coverage
flutter test integration_test/ --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html

# Open coverage report
open coverage/html/index.html
```

## Debugging Failed Tests

### Enable Screenshots on Failure

Add to test files:

```dart
setUp(() {
  tester.binding.addPostFrameCallback((_) {
    if (tester.testFailed) {
      // Take screenshot
    }
  });
});
```

### Verbose Output

```bash
flutter test integration_test/ --verbose
```

### Run Single Test

```bash
flutter test integration_test/onboarding_flow_test.dart --name "User can complete full onboarding flow"
```

### Debug Mode

Run with debugger attached:
```bash
flutter run integration_test/onboarding_flow_test.dart
```

## Performance Considerations

### Test Execution Time

- **Full Suite**: ~15-25 minutes
- **Individual Flow**: ~2-5 minutes
- **Quick Smoke Test**: ~30 seconds

### Optimization Tips

1. **Run in Release Mode**: `--release` flag for faster execution
2. **Parallel Execution**: Run different test files on different devices
3. **Selective Testing**: Run only changed features during development

## Troubleshooting

### Common Issues

#### 1. No Device Available
```bash
# Start iOS Simulator
open -a Simulator

# Start Android Emulator
emulator -avd <emulator_name>
```

#### 2. Test Timeout
Increase timeout:
```bash
flutter test integration_test/ --timeout=10m
```

#### 3. Flaky Tests
- Increase pump durations: `await tester.pumpAndSettle(Duration(seconds: 2))`
- Add explicit waits before assertions
- Check for race conditions in async operations

#### 4. Widget Not Found
- Verify widget exists: `expect(find.byType(Widget), findsOneWidget)`
- Use `findRichText: true` for text in rich text widgets
- Check if widget is visible: scroll to widget before tapping

## Contributing

When adding new features to LilyFit, please:

1. **Add Integration Tests**: Cover the new feature in appropriate test file
2. **Update Documentation**: Add new test cases to this README
3. **Maintain Coverage**: Aim for >80% coverage of user flows
4. **Run Full Suite**: Ensure all tests pass before submitting PR

## Test Coverage Goals

- **UI Flows**: >90% of user-facing features
- **Business Logic**: >85% of provider methods
- **Edge Cases**: All error states and boundary conditions
- **Happy Paths**: 100% of primary user journeys

## Resources

- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Integration Test Package](https://pub.dev/packages/integration_test)
- [Flutter Testing Best Practices](https://docs.flutter.dev/testing/best-practices)

## Questions or Issues?

If you encounter issues with the tests or need help:
1. Check this README for solutions
2. Review test output for error messages
3. Run tests with `--verbose` flag
4. Check device logs for additional context

---

**Happy Testing! 🧪✨**

