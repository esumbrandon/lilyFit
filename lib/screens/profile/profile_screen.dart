import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/user_profile.dart';
import '../../providers/app_provider.dart';
import '../onboarding/onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final profile = provider.userProfile;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // Avatar & Name
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            profile.name.isNotEmpty
                                ? profile.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name.isNotEmpty ? profile.name : 'User',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_goalLabel(profile.goal)} · ${_activityLabel(profile.activityLevel)}',
                              style: TextStyle(
                                color: Colors.white.withAlpha(200),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Body Info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Body Information',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _infoRow(Icons.cake_outlined, 'Age', '${profile.age} years'),
                      _infoRow(Icons.monitor_weight_outlined, 'Weight', '${profile.weight.toStringAsFixed(1)} kg'),
                      _infoRow(Icons.height_rounded, 'Height', '${profile.height.toInt()} cm'),
                      _infoRow(Icons.wc_rounded, 'Gender', profile.gender == 'male' ? 'Male' : 'Female'),
                      _infoRow(Icons.speed_rounded, 'BMI', '${profile.bmi.toStringAsFixed(1)} (${profile.bmiCategory})'),
                    ],
                  ),
                ),
              ),
            ),

            // Daily Targets
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Targets',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _targetRow('Calories', '${profile.targetCalories.toInt()} kcal', AppColors.primary),
                      _targetRow('Protein', '${profile.targetProtein.toInt()} g', AppColors.protein),
                      _targetRow('Carbs', '${profile.targetCarbs.toInt()} g', AppColors.carbs),
                      _targetRow('Fat', '${profile.targetFat.toInt()} g', AppColors.fat),
                    ],
                  ),
                ),
              ),
            ),

            // Edit Profile button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: ElevatedButton.icon(
                  onPressed: () => _showEditProfileDialog(context, provider),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),

            // Settings section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _settingsTile(
                        Icons.water_drop_outlined,
                        'Water Goal',
                        '${provider.waterGoal.toInt()} ml/day',
                        () => _showWaterGoalDialog(context, provider),
                      ),
                      _divider(),
                      _settingsTile(
                        Icons.info_outline_rounded,
                        'About LilyFit',
                        'Version 1.0.0',
                        () => _showAboutDialog(context),
                      ),
                      _divider(),
                      _settingsTile(
                        Icons.restart_alt_rounded,
                        'Reset All Data',
                        'Start fresh',
                        () => _showResetDialog(context, provider),
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 20),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _targetRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDestructive ? AppColors.error.withAlpha(150) : AppColors.textTertiary,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDestructive ? AppColors.error.withAlpha(100) : AppColors.textTertiary,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _divider() {
    return const Divider(color: AppColors.cardLight, height: 1, indent: 56);
  }

  String _goalLabel(String goal) => switch (goal) {
    'fatLoss' => 'Fat Loss',
    'muscleGain' => 'Muscle Gain',
    _ => 'Maintenance',
  };

  String _activityLabel(String level) => switch (level) {
    'sedentary' => 'Sedentary',
    'light' => 'Light Activity',
    'moderate' => 'Moderate Activity',
    'active' => 'Very Active',
    'veryActive' => 'Extremely Active',
    _ => 'Moderate',
  };

  void _showEditProfileDialog(BuildContext context, AppProvider provider) {
    final profile = provider.userProfile;
    int age = profile.age;
    double weight = profile.weight;
    double height = profile.height;
    String goal = profile.goal;
    String activityLevel = profile.activityLevel;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(
                24, 24, 24,
                MediaQuery.of(ctx).padding.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.cardLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Age
                    _editSlider(
                      label: 'Age',
                      value: age.toDouble(),
                      min: 14, max: 80,
                      unit: 'years',
                      onChanged: (v) => setSheetState(() => age = v.round()),
                    ),
                    const SizedBox(height: 16),

                    // Weight
                    _editSlider(
                      label: 'Weight',
                      value: weight,
                      min: 30, max: 200,
                      unit: 'kg',
                      decimals: 1,
                      onChanged: (v) => setSheetState(() => weight = double.parse(v.toStringAsFixed(1))),
                    ),
                    const SizedBox(height: 16),

                    // Height
                    _editSlider(
                      label: 'Height',
                      value: height,
                      min: 100, max: 220,
                      unit: 'cm',
                      onChanged: (v) => setSheetState(() => height = double.parse(v.toStringAsFixed(0))),
                    ),
                    const SizedBox(height: 20),

                    // Goal
                    const Text(
                      'Goal',
                      style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _goalChip(ctx, 'fatLoss', 'Lose Fat', goal, (v) => setSheetState(() => goal = v)),
                        const SizedBox(width: 8),
                        _goalChip(ctx, 'maintenance', 'Maintain', goal, (v) => setSheetState(() => goal = v)),
                        const SizedBox(width: 8),
                        _goalChip(ctx, 'muscleGain', 'Build Muscle', goal, (v) => setSheetState(() => goal = v)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final updated = UserProfile(
                            name: profile.name,
                            gender: profile.gender,
                            age: age,
                            weight: weight,
                            height: height,
                            activityLevel: activityLevel,
                            goal: goal,
                          );
                          provider.updateProfile(updated);
                          Navigator.pop(ctx);
                        },
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _editSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    int decimals = 0,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.toStringAsFixed(decimals)} $unit',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _goalChip(BuildContext context, String value, String label, String current, ValueChanged<String> onChanged) {
    final selected = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withAlpha(25) : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _showWaterGoalDialog(BuildContext context, AppProvider provider) {
    final controller = TextEditingController(
      text: provider.waterGoal.toInt().toString(),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Water Goal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            suffixText: 'ml',
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              final ml = double.tryParse(controller.text);
              if (ml != null && ml > 0) {
                provider.setWaterGoal(ml);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.fitness_center_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text(
              'LilyFit',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A global nutrition and fitness tracking app with strong support for African cuisines.',
              style: TextStyle(color: Colors.white.withAlpha(180), height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Reset All Data?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will delete all your data including meals, weight history, and profile. This cannot be undone.',
          style: TextStyle(color: Colors.white.withAlpha(180)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.resetAllData();
              if (!context.mounted) return;
              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
