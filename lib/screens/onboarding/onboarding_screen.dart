import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/user_profile.dart';
import '../../providers/app_provider.dart';
import '../../services/supabase_service.dart';
import '../../utils/validators.dart';
import '../../utils/unit_converter.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5; // Reduced from 6 (removed info page)
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form data
  String _name = '';
  String? _nameError;
  String _gender = 'male';
  int _age = 25;
  double _weight = 70; // Always stored in kg
  double _height = 170; // Always stored in cm
  String _weightUnit = 'kg';
  String _heightUnit = 'cm';
  String _activityLevel = 'moderate';
  String _goal = 'maintenance';

  @override
  void initState() {
    super.initState();
    // Get user's name from auth metadata
    final user = SupabaseService().getCurrentUser();
    if (user != null && user.userMetadata?['name'] != null) {
      _name = user.userMetadata!['name'] as String;
    }

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    // Validate page 0 (name) before proceeding
    if (_currentPage == 0) {
      final nameValidation = Validators.validateName(_name);

      setState(() {
        _nameError = nameValidation;
      });

      if (nameValidation != null) {
        return;
      }
    }

    if (_currentPage < _totalPages - 1) {
      // Reset and replay animation
      _animationController.reset();
      _animationController.forward();

      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      // Reset and replay animation
      _animationController.reset();
      _animationController.forward();

      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    // Final validation
    final nameValidation = Validators.validateName(_name);

    if (nameValidation != null) {
      _pageController.jumpToPage(0);
      setState(() {
        _nameError = nameValidation;
      });
      return;
    }

    // Show loading dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final supabaseService = SupabaseService();
      final user = supabaseService.getCurrentUser();

      if (user == null) {
        throw Exception('No user logged in. Please login first.');
      }

      // Create user profile with calculated targets
      final profile = UserProfile(
        name: _name.trim(),
        email: user.email ?? '',
        gender: _gender,
        age: _age,
        weight: _weight,
        height: _height,
        activityLevel: _activityLevel,
        goal: _goal,
        weightUnit: _weightUnit,
        heightUnit: _heightUnit,
      );
      profile.calculateTargets();

      // Save profile to Supabase database
      await supabaseService.saveUserProfile(profile);

      // Save locally and complete onboarding
      if (!mounted) return;
      await context.read<AppProvider>().completeOnboarding(profile);

      // Close loading dialog
      if (!mounted) return;
      Navigator.of(context).pop();

      // Navigate to home
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      // Close loading dialog
      if (!mounted) return;
      Navigator.of(context).pop();

      // Show error message
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text(
            'Sign Up Failed',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildAnimatedPage(Widget child) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: List.generate(_totalPages, (i) {
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: i <= _currentPage
                            ? AppColors.primaryGradient
                            : null,
                        color: i > _currentPage ? AppColors.cardLight : null,
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildAnimatedPage(_buildNameGenderPage()),
                  _buildAnimatedPage(_buildBodyMetricsPage()),
                  _buildAnimatedPage(_buildActivityPage()),
                  _buildAnimatedPage(_buildGoalPage()),
                  _buildAnimatedPage(_buildResultsPage()),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: _prevPage,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _currentPage == _totalPages - 1
                          ? _completeOnboarding
                          : _nextPage,
                      child: Text(
                        _currentPage == _totalPages - 1
                            ? 'Start Tracking!'
                            : 'Continue',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Page 1: Welcome ───────────────────────────────────────────
  // ─── Page 2: Name & Gender ─────────────────────────────────────
  Widget _buildNameGenderPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              'About You',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Let\'s personalize your calorie management plan',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withAlpha(150),
              ),
            ),
            const SizedBox(height: 40),

            // Name
            const Text(
              'Your Name',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  _name = value;
                  if (_nameError != null) {
                    _nameError = Validators.validateName(value);
                  }
                });
              },
              controller: TextEditingController(text: _name)
                ..selection = TextSelection.collapsed(offset: _name.length),
              decoration: InputDecoration(
                hintText: 'Enter your name',
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: AppColors.textTertiary,
                ),
                errorText: _nameError,
                errorStyle: const TextStyle(color: Colors.redAccent),
              ),
            ),
            const SizedBox(height: 32),

            // Gender
            const Text(
              'Gender',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _genderCard('male', 'Male', Icons.male_rounded),
                const SizedBox(width: 12),
                _genderCard('female', 'Female', Icons.female_rounded),
                const SizedBox(width: 12),
                _genderCard('other', 'Other', Icons.person_rounded),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _genderCard(String value, String label, IconData icon) {
    final selected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _gender = value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withAlpha(25) : AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: selected ? AppColors.primary : AppColors.textTertiary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Page 3: Body Metrics ──────────────────────────────────────
  Widget _buildBodyMetricsPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Body Metrics',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ll use this to calculate your targets',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withAlpha(150),
              ),
            ),
            const SizedBox(height: 40),

            // Age
            _metricSlider(
              label: 'Age',
              value: _age.toDouble(),
              min: 14,
              max: 80,
              unit: 'years',
              onChanged: (v) => setState(() => _age = v.round()),
            ),
            const SizedBox(height: 24),

            // Weight with unit toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weight',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    _unitToggle('kg', _weightUnit == 'kg', () {
                      setState(() {
                        if (_weightUnit == 'lbs') {
                          // Keep same weight, just change display unit
                          _weightUnit = 'kg';
                        }
                      });
                    }),
                    const SizedBox(width: 8),
                    _unitToggle('lbs', _weightUnit == 'lbs', () {
                      setState(() {
                        if (_weightUnit == 'kg') {
                          // Keep same weight, just change display unit
                          _weightUnit = 'lbs';
                        }
                      });
                    }),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _weightSlider(),
            const SizedBox(height: 24),

            // Height with unit toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Height',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    _unitToggle('cm', _heightUnit == 'cm', () {
                      setState(() {
                        if (_heightUnit == 'ft') {
                          // Keep same height, just change display unit
                          _heightUnit = 'cm';
                        }
                      });
                    }),
                    const SizedBox(width: 8),
                    _unitToggle('ft', _heightUnit == 'ft', () {
                      setState(() {
                        if (_heightUnit == 'cm') {
                          // Keep same height, just change display unit
                          _heightUnit = 'ft';
                        }
                      });
                    }),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _heightSlider(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _unitToggle(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(25) : AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _weightSlider() {
    // Display value in selected unit
    double displayValue;
    double minValue;
    double maxValue;
    String displayText;

    if (_weightUnit == 'lbs') {
      displayValue = UnitConverter.kgToLbs(_weight);
      minValue = UnitConverter.kgToLbs(30);
      maxValue = UnitConverter.kgToLbs(200);
      displayText = '${displayValue.toStringAsFixed(1)} lbs';
    } else {
      displayValue = _weight;
      minValue = 30;
      maxValue = 200;
      displayText = '${displayValue.toStringAsFixed(1)} kg';
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            displayText,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.cardLight,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withAlpha(30),
          ),
          child: Slider(
            value: displayValue,
            min: minValue,
            max: maxValue,
            onChanged: (v) {
              setState(() {
                if (_weightUnit == 'lbs') {
                  // Convert back to kg for storage
                  _weight = UnitConverter.lbsToKg(v);
                } else {
                  _weight = v;
                }
                _weight = double.parse(_weight.toStringAsFixed(1));
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _heightSlider() {
    // Display value in selected unit
    double displayValue;
    double minValue;
    double maxValue;
    String displayText;

    if (_heightUnit == 'ft') {
      displayValue = UnitConverter.cmToFeet(_height);
      minValue = UnitConverter.cmToFeet(100);
      maxValue = UnitConverter.cmToFeet(220);
      final (feet, inches) = UnitConverter.cmToFeetInches(_height);
      displayText = '$feet\' ${inches.toStringAsFixed(1)}"';
    } else {
      displayValue = _height;
      minValue = 100;
      maxValue = 220;
      displayText = '${displayValue.toInt()} cm';
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            displayText,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.cardLight,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withAlpha(30),
          ),
          child: Slider(
            value: displayValue,
            min: minValue,
            max: maxValue,
            onChanged: (v) {
              setState(() {
                if (_heightUnit == 'ft') {
                  // Convert back to cm for storage
                  _height = UnitConverter.feetToCm(v);
                } else {
                  _height = v;
                }
                _height = double.parse(_height.toStringAsFixed(0));
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _metricSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    int decimals = 0,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${value.toStringAsFixed(decimals)} $unit',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.cardLight,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withAlpha(30),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  // ─── Page 4: Activity Level ────────────────────────────────────
  Widget _buildActivityPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Activity Level',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How active are you on a typical day?',
            style: TextStyle(fontSize: 15, color: Colors.white.withAlpha(150)),
          ),
          const SizedBox(height: 28),
          _activityOption(
            'sedentary',
            'Sedentary',
            'Little or no exercise',
            '🪑',
          ),
          _activityOption(
            'light',
            'Lightly Active',
            'Light exercise 1-3 days/week',
            '🚶',
          ),
          _activityOption(
            'moderate',
            'Moderately Active',
            'Moderate exercise 3-5 days/week',
            '🏃',
          ),
          _activityOption(
            'active',
            'Very Active',
            'Hard exercise 6-7 days/week',
            '💪',
          ),
          _activityOption(
            'veryActive',
            'Extremely Active',
            'Very hard exercise & physical job',
            '🏋️',
          ),
        ],
      ),
    );
  }

  Widget _activityOption(
    String value,
    String label,
    String description,
    String emoji,
  ) {
    final selected = _activityLevel == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activityLevel = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withAlpha(20) : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? AppColors.primary : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  // ─── Page 5: Goal ──────────────────────────────────────────────
  Widget _buildGoalPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Your Goal',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What would you like to achieve?',
            style: TextStyle(fontSize: 15, color: Colors.white.withAlpha(150)),
          ),
          const SizedBox(height: 32),
          _goalCard(
            'fatLoss',
            'Lose Weight',
            'Calorie deficit to help you lose weight safely',
            Icons.trending_down_rounded,
            const Color(0xFFEF4444),
          ),
          _goalCard(
            'maintenance',
            'Maintain Weight',
            'Stay at your current weight with balanced nutrition',
            Icons.balance_rounded,
            const Color(0xFF4ADE80),
          ),
          _goalCard(
            'muscleGain',
            'Gain Weight',
            'Calorie surplus to help you gain weight healthily',
            Icons.trending_up_rounded,
            const Color(0xFF60A5FA),
          ),
        ],
      ),
    );
  }

  Widget _goalCard(
    String value,
    String label,
    String description,
    IconData icon,
    Color color,
  ) {
    final selected = _goal == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _goal = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(20) : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? color : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  // ─── Page 5: Results ───────────────────────────────────────────
  Widget _buildResultsPage() {
    final user = SupabaseService().getCurrentUser();
    final profile = UserProfile(
      name: _name.trim(),
      email: user?.email ?? '',
      gender: _gender,
      age: _age,
      weight: _weight,
      height: _height,
      activityLevel: _activityLevel,
      goal: _goal,
      weightUnit: _weightUnit,
      heightUnit: _heightUnit,
    );
    profile.calculateTargets();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 40),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.primaryGradient.createShader(bounds),
            child: const Text(
              'Your Plan is Ready! 🎉',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Based on your profile, here are your daily targets',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.white.withAlpha(150)),
          ),
          const SizedBox(height: 36),

          // Calorie target
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(60),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Daily Calorie Target',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${profile.targetCalories.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const Text(
                  'kcal',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Macro targets
          Row(
            children: [
              _macroResultCard(
                'Protein',
                profile.targetProtein,
                'g',
                AppColors.protein,
              ),
              const SizedBox(width: 10),
              _macroResultCard(
                'Carbs',
                profile.targetCarbs,
                'g',
                AppColors.carbs,
              ),
              const SizedBox(width: 10),
              _macroResultCard('Fat', profile.targetFat, 'g', AppColors.fat),
            ],
          ),
          const SizedBox(height: 24),

          // BMI
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem('BMI', profile.bmi.toStringAsFixed(1)),
                Container(width: 1, height: 30, color: AppColors.cardLight),
                _statItem('Status', profile.bmiCategory),
                Container(width: 1, height: 30, color: AppColors.cardLight),
                _statItem('Goal', _goalLabel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _macroResultCard(
    String label,
    double value,
    String unit,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${value.toInt()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
        ),
      ],
    );
  }

  String get _goalLabel => switch (_goal) {
    'fatLoss' => 'Lose Weight',
    'muscleGain' => 'Gain Weight',
    _ => 'Maintain',
  };
}
