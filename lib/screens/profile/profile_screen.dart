import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../models/user_profile.dart';
import '../../providers/app_provider.dart';
import '../../utils/unit_converter.dart';
import 'settings_screen.dart';

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
            // Header with Avatar & Name - Redesigned
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(40),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withAlpha(80),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          profile.name.isNotEmpty
                              ? profile.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name
                    Text(
                      profile.name.isNotEmpty
                          ? profile.name
                          : AppLocalizations.of(context)!.user,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (profile.email.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        profile.email,
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 14,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    // Goal & Activity chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _infoChip(
                          _goalLabel(context, profile.goal),
                          Icons.flag_rounded,
                        ),
                        const SizedBox(width: 8),
                        _infoChip(
                          _activityLabel(context, profile.activityLevel),
                          Icons.directions_run_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Quick Stats Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        context,
                        Icons.speed_rounded,
                        'BMI',
                        profile.bmi.toStringAsFixed(1),
                        profile.bmiCategory,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        context,
                        Icons.local_fire_department_rounded,
                        AppLocalizations.of(context)!.calories,
                        profile.targetCalories.toInt().toString(),
                        'kcal/day',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Body Info - Redesigned
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.cardLight.withAlpha(50),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)!.bodyInformation,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _infoRow(
                        Icons.cake_outlined,
                        AppLocalizations.of(context)!.age,
                        '${profile.age} ${AppLocalizations.of(context)!.years}',
                      ),
                      _infoRow(
                        Icons.monitor_weight_outlined,
                        AppLocalizations.of(context)!.weight,
                        UnitConverter.formatWeight(
                          profile.weight,
                          profile.weightUnit,
                        ),
                      ),
                      _infoRow(
                        Icons.height_rounded,
                        AppLocalizations.of(context)!.height,
                        UnitConverter.formatHeight(
                          profile.height,
                          profile.heightUnit,
                        ),
                      ),
                      _infoRow(
                        Icons.wc_rounded,
                        AppLocalizations.of(context)!.gender,
                        profile.gender == 'male'
                            ? AppLocalizations.of(context)!.male
                            : (profile.gender == 'female'
                                  ? AppLocalizations.of(context)!.female
                                  : AppLocalizations.of(context)!.other),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Daily Targets - Redesigned
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.cardLight.withAlpha(50),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.track_changes_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)!.dailyTargets,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _targetRow(
                        AppLocalizations.of(context)!.calories,
                        '${profile.targetCalories.toInt()} kcal',
                        AppColors.primary,
                      ),
                      _targetRow(
                        AppLocalizations.of(context)!.protein,
                        '${profile.targetProtein.toInt()} g',
                        AppColors.protein,
                      ),
                      _targetRow(
                        AppLocalizations.of(context)!.carbs,
                        '${profile.targetCarbs.toInt()} g',
                        AppColors.carbs,
                      ),
                      _targetRow(
                        AppLocalizations.of(context)!.fat,
                        '${profile.targetFat.toInt()} g',
                        AppColors.fat,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Settings section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.cardLight.withAlpha(50),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _settingsTile(
                        Icons.water_drop_outlined,
                        AppLocalizations.of(context)!.waterGoal,
                        '${provider.waterGoal.toInt()} ml/day',
                        () {
                          HapticFeedback.lightImpact();
                          _showWaterGoalDialog(context, provider);
                        },
                      ),
                      _divider(),
                      _settingsTile(
                        Icons.settings_outlined,
                        AppLocalizations.of(context)!.settings,
                        'Notifications, privacy, account and more',
                        () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Edit Profile button - Moved to bottom
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(60),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showEditProfileDialog(context, provider);
                    },
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    label: Text(
                      AppLocalizations.of(context)!.editProfile,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withAlpha(40), Colors.white.withAlpha(20)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(80), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.card, AppColors.card.withAlpha(200)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardLight.withAlpha(50), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withAlpha(40),
                  AppColors.primary.withAlpha(15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
          ),
        ],
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
              color: AppColors.textPrimary,
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

  Widget _settingsTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
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
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDestructive
              ? AppColors.error.withAlpha(150)
              : AppColors.textTertiary,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDestructive
            ? AppColors.error.withAlpha(100)
            : AppColors.textTertiary,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 56),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.cardLight.withAlpha(100),
            AppColors.cardLight.withAlpha(20),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  String _goalLabel(BuildContext context, String goal) => switch (goal) {
    'fatLoss' => AppLocalizations.of(context)!.loseWeight,
    'muscleGain' => AppLocalizations.of(context)!.gainWeight,
    _ => AppLocalizations.of(context)!.maintainWeight,
  };

  String _activityLabel(BuildContext context, String level) => switch (level) {
    'sedentary' => AppLocalizations.of(context)!.sedentary,
    'light' => AppLocalizations.of(context)!.light,
    'moderate' => AppLocalizations.of(context)!.moderate,
    'active' => AppLocalizations.of(context)!.active,
    'veryActive' => AppLocalizations.of(context)!.veryActive,
    _ => AppLocalizations.of(context)!.moderate,
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
                24,
                24,
                24,
                MediaQuery.of(ctx).padding.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.cardLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(ctx)!.editProfile,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Age
                    _editSlider(
                      label: AppLocalizations.of(context)!.age,
                      value: age.toDouble(),
                      min: 14,
                      max: 80,
                      unit: 'years',
                      onChanged: (v) => setSheetState(() => age = v.round()),
                    ),
                    const SizedBox(height: 16),

                    // Weight
                    _editSlider(
                      label: AppLocalizations.of(context)!.weight,
                      value: weight,
                      min: 30,
                      max: 200,
                      unit: 'kg',
                      decimals: 1,
                      onChanged: (v) => setSheetState(
                        () => weight = double.parse(v.toStringAsFixed(1)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Height
                    _editSlider(
                      label: AppLocalizations.of(context)!.height,
                      value: height,
                      min: 100,
                      max: 220,
                      unit: 'cm',
                      onChanged: (v) => setSheetState(
                        () => height = double.parse(v.toStringAsFixed(0)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Goal
                    Text(
                      AppLocalizations.of(context)!.goal,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _goalChip(
                          ctx,
                          'fatLoss',
                          'Lose Fat',
                          goal,
                          (v) => setSheetState(() => goal = v),
                        ),
                        const SizedBox(width: 8),
                        _goalChip(
                          ctx,
                          'maintenance',
                          'Maintain',
                          goal,
                          (v) => setSheetState(() => goal = v),
                        ),
                        const SizedBox(width: 8),
                        _goalChip(
                          ctx,
                          'muscleGain',
                          'Build Muscle',
                          goal,
                          (v) => setSheetState(() => goal = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final updated = UserProfile(
                            name: profile.name,
                            email: profile.email,
                            gender: profile.gender,
                            age: age,
                            weight: weight,
                            height: height,
                            activityLevel: activityLevel,
                            goal: goal,
                            weightUnit: profile.weightUnit,
                            heightUnit: profile.heightUnit,
                          );
                          HapticFeedback.mediumImpact();
                          provider.updateProfile(updated);
                          Navigator.pop(ctx);
                        },
                        child: Text(AppLocalizations.of(ctx)!.updateProfile),
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
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }

  Widget _goalChip(
    BuildContext context,
    String value,
    String label,
    String current,
    ValueChanged<String> onChanged,
  ) {
    final selected = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(value);
        },
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
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            suffixText: 'ml',
            filled: true,
            fillColor: AppColors.surfaceMuted,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final ml = double.tryParse(controller.text);
              if (ml != null && ml > 0) {
                HapticFeedback.mediumImpact();
                provider.setWaterGoal(ml);
                Navigator.pop(ctx);
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }
}
