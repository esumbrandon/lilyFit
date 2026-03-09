import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/user_profile.dart';
import '../../providers/app_provider.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 6;

  // Form data
  final _nameController = TextEditingController();
  String _gender = 'male';
  int _age = 25;
  double _weight = 70;
  double _height = 170;
  String _activityLevel = 'moderate';
  String _goal = 'maintenance';

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final profile = UserProfile(
      name: _nameController.text.trim().isEmpty ? 'User' : _nameController.text.trim(),
      gender: _gender,
      age: _age,
      weight: _weight,
      height: _height,
      activityLevel: _activityLevel,
      goal: _goal,
    );

    await context.read<AppProvider>().completeOnboarding(profile);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
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
                        color: i > _currentPage
                            ? AppColors.cardLight
                            : null,
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
                  _buildWelcomePage(),
                  _buildNameGenderPage(),
                  _buildBodyMetricsPage(),
                  _buildActivityPage(),
                  _buildGoalPage(),
                  _buildResultsPage(),
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
                        _currentPage == 0
                            ? 'Get Started'
                            : _currentPage == _totalPages - 1
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
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated logo area
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(60),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              size: 56,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'LilyFit',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.primaryGradient.createShader(bounds),
            child: const Text(
              'Your Global Nutrition Companion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Track calories, monitor macros, and reach your\nfitness goals with foods from around the world.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withAlpha(150),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          // Feature highlights
          _featureHighlight(Icons.restaurant_menu_rounded, 'Global food database with African cuisines'),
          _featureHighlight(Icons.track_changes_rounded, 'Smart calorie & macro tracking'),
          _featureHighlight(Icons.trending_up_rounded, 'Progress analytics & insights'),
        ],
      ),
    );
  }

  Widget _featureHighlight(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withAlpha(200),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page 2: Name & Gender ─────────────────────────────────────
  Widget _buildNameGenderPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
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
            'Let\'s personalize your experience',
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
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter your name',
              prefixIcon: Icon(Icons.person_outline, color: AppColors.textTertiary),
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
            ],
          ),
        ],
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

          // Weight
          _metricSlider(
            label: 'Weight',
            value: _weight,
            min: 30,
            max: 200,
            unit: 'kg',
            decimals: 1,
            onChanged: (v) => setState(() => _weight = double.parse(v.toStringAsFixed(1))),
          ),
          const SizedBox(height: 24),

          // Height
          _metricSlider(
            label: 'Height',
            value: _height,
            min: 100,
            max: 220,
            unit: 'cm',
            onChanged: (v) => setState(() => _height = double.parse(v.toStringAsFixed(0))),
          ),
        ],
      ),
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
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
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
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withAlpha(150),
            ),
          ),
          const SizedBox(height: 28),
          _activityOption('sedentary', 'Sedentary', 'Little or no exercise', '🪑'),
          _activityOption('light', 'Lightly Active', 'Light exercise 1-3 days/week', '🚶'),
          _activityOption('moderate', 'Moderately Active', 'Moderate exercise 3-5 days/week', '🏃'),
          _activityOption('active', 'Very Active', 'Hard exercise 6-7 days/week', '💪'),
          _activityOption('veryActive', 'Extremely Active', 'Very hard exercise & physical job', '🏋️'),
        ],
      ),
    );
  }

  Widget _activityOption(String value, String label, String description, String emoji) {
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
              const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
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
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withAlpha(150),
            ),
          ),
          const SizedBox(height: 32),
          _goalCard(
            'fatLoss',
            'Lose Fat',
            'Calorie deficit to burn fat while maintaining muscle',
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
            'Build Muscle',
            'Calorie surplus to support muscle growth',
            Icons.trending_up_rounded,
            const Color(0xFF60A5FA),
          ),
        ],
      ),
    );
  }

  Widget _goalCard(String value, String label, String description, IconData icon, Color color) {
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

  // ─── Page 6: Results ───────────────────────────────────────────
  Widget _buildResultsPage() {
    final profile = UserProfile(
      name: _nameController.text.trim(),
      gender: _gender,
      age: _age,
      weight: _weight,
      height: _height,
      activityLevel: _activityLevel,
      goal: _goal,
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withAlpha(150),
            ),
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
              _macroResultCard('Protein', profile.targetProtein, 'g', AppColors.protein),
              const SizedBox(width: 10),
              _macroResultCard('Carbs', profile.targetCarbs, 'g', AppColors.carbs),
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

  Widget _macroResultCard(String label, double value, String unit, Color color) {
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
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String get _goalLabel => switch (_goal) {
    'fatLoss' => 'Fat Loss',
    'muscleGain' => 'Muscle Gain',
    _ => 'Maintain',
  };
}
