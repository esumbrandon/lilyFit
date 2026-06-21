import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user_profile.dart';
import '../../providers/app_provider.dart';
import '../../services/language_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/unit_converter.dart';
import '../../widgets/adaptive_loading_indicator.dart';
import '../auth/auth_screen.dart';
import 'water_reminder_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          // Background Color
          Positioned.fill(
            child: Container(
              color: isDark ? AppColors.darkBackground : AppColors.background,
            ),
          ),
          // Glowing top gradient aura
          Positioned(
            top: -100,
            right: -100,
            width: 320,
            height: 320,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.2),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Glowing bottom gradient aura
          Positioned(
            bottom: -50,
            left: -50,
            width: 250,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: isDark ? 0.08 : 0.10),
                    AppColors.secondary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Main Scrollable Area
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Header with Avatar & Name - Glassmorphic Asymmetric Redesign
                SliverToBoxAdapter(
                  child: Consumer<AppProvider>(
                    builder: (context, provider, child) {
                      final profile = provider.userProfile;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.darkCard : AppColors.card)
                              .withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: (isDark ? Colors.white : Colors.black)
                                .withValues(alpha: 0.08),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.25 : 0.06,
                              ),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Avatar with glowing ring
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          gradient: AppColors.primaryGradient,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.6,
                                            ),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            profile.name.isNotEmpty
                                                ? profile.name[0].toUpperCase()
                                                : 'U',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 18),
                                      // User info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              profile.name.isNotEmpty
                                                  ? profile.name
                                                  : AppLocalizations.of(
                                                      context,
                                                    )!.user,
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white
                                                    : AppColors.textPrimary,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            if (profile.email.isNotEmpty)
                                              Text(
                                                profile.email,
                                                style: TextStyle(
                                                  color:
                                                      (isDark
                                                              ? AppColors
                                                                    .darkTextSecondary
                                                              : AppColors
                                                                    .textSecondary)
                                                          .withValues(
                                                            alpha: 0.8,
                                                          ),
                                                  fontSize: 13,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                      // Sleek edit button
                                      GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          _showEditProfileDialog(
                                            context,
                                            provider,
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.25),
                                              width: 1,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.edit_rounded,
                                            color: AppColors.primary,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  // Goal & Activity chips
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _infoChip(
                                          context,
                                          _goalLabel(context, profile.goal),
                                          Icons.flag_rounded,
                                          isDark,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _infoChip(
                                          context,
                                          _activityLabel(
                                            context,
                                            profile.activityLevel,
                                          ),
                                          Icons.directions_run_rounded,
                                          isDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 2x2 Grid of Metrics
                SliverToBoxAdapter(
                  child: Consumer<AppProvider>(
                    builder: (context, provider, child) {
                      final profile = provider.userProfile;
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _metricGridCard(
                                    context: context,
                                    icon: Icons.cake_outlined,
                                    iconColor: const Color(0xFFF97316),
                                    label: AppLocalizations.of(context)!.age,
                                    value: '${profile.age}',
                                    unit: AppLocalizations.of(context)!.years,
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _metricGridCard(
                                    context: context,
                                    icon: Icons.monitor_weight_outlined,
                                    iconColor: AppColors.primary,
                                    label: AppLocalizations.of(context)!.weight,
                                    value: UnitConverter.formatWeight(
                                      profile.weight,
                                      profile.weightUnit,
                                    ),
                                    unit: '',
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _metricGridCard(
                                    context: context,
                                    icon: Icons.straighten_rounded,
                                    iconColor: const Color(0xFF3B82F6),
                                    label: AppLocalizations.of(context)!.height,
                                    value: UnitConverter.formatHeight(
                                      profile.height,
                                      profile.heightUnit,
                                    ),
                                    unit: '',
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _metricGridCard(
                                    context: context,
                                    icon: Icons.wc_rounded,
                                    iconColor: const Color(0xFF8B5CF6),
                                    label: AppLocalizations.of(context)!.gender,
                                    value: profile.gender == 'male'
                                        ? AppLocalizations.of(context)!.male
                                        : (profile.gender == 'female'
                                              ? AppLocalizations.of(
                                                  context,
                                                )!.female
                                              : AppLocalizations.of(
                                                  context,
                                                )!.other),
                                    unit: '',
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── Preferences section ───────────────────────────────────
                _sectionHeader(
                  context,
                  AppLocalizations.of(context)!.preferences,
                ),
                _sectionCard([
                  Consumer<AppProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        children: [
                          _settingsListTile(
                            icon: Icons.language_rounded,
                            iconColor: AppColors.primary,
                            title: AppLocalizations.of(context)!.language,
                            subtitle: _currentLanguageName(provider),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _showLanguagePicker(context, provider);
                            },
                          ),
                          _divider(),
                          _settingsListTile(
                            icon: Icons.palette_rounded,
                            iconColor: const Color(0xFF8B5CF6),
                            title: 'Theme',
                            subtitle: _currentThemeName(provider),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _showThemePicker(context, provider);
                            },
                          ),
                          _divider(),
                          _settingsListTile(
                            icon: Icons.notifications_rounded,
                            iconColor: const Color(0xFFFBBF24),
                            title: AppLocalizations.of(context)!.notifications,
                            subtitle: provider.waterRemindersEnabled
                                ? AppLocalizations.of(
                                    context,
                                  )!.waterRemindersActive
                                : AppLocalizations.of(
                                    context,
                                  )!.configureReminders,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WaterReminderScreen(),
                                ),
                              );
                            },
                          ),
                          _divider(),
                          _settingsListTile(
                            icon: Icons.email_rounded,
                            iconColor: AppColors.secondary,
                            title: AppLocalizations.of(context)!.emailUpdate,
                            subtitle: provider.userProfile.emailUpdated
                                ? '${provider.userProfile.email} (Updated)'
                                : (provider.userProfile.email.isNotEmpty
                                      ? provider.userProfile.email
                                      : AppLocalizations.of(
                                          context,
                                        )!.updateEmailAddress),
                            onTap: provider.userProfile.emailUpdated
                                ? null
                                : () {
                                    HapticFeedback.lightImpact();
                                    _showEmailUpdateSheet(context, provider);
                                  },
                          ),
                        ],
                      );
                    },
                  ),
                ]),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── Subscription section ──────────────────────────────────
                _sectionHeader(
                  context,
                  AppLocalizations.of(context)!.membership,
                ),
                _sectionCard([_premiumTile(context)]),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── Support & About section ───────────────────────────────
                _sectionHeader(
                  context,
                  '${AppLocalizations.of(context)!.support} & ${AppLocalizations.of(context)!.about}',
                ),
                _sectionCard([
                  _settingsListTile(
                    icon: Icons.help_rounded,
                    iconColor: const Color(0xFF818CF8),
                    title: AppLocalizations.of(context)!.helpAndSupport,
                    subtitle: AppLocalizations.of(context)!.faqsContactUs,
                    onTap: () async {
                      HapticFeedback.lightImpact();

                      final Uri emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'esumbrandon074@gmail.com',
                        queryParameters: {
                          'subject': 'Lilyfit bug reports and help.',
                        },
                      );
                      try {
                        if (!await launchUrl(emailLaunchUri)) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not open email client.'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'An error occurred while trying to open email client. $e',
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  _divider(),
                  _settingsListTile(
                    icon: Icons.security_rounded,
                    iconColor: AppColors.primary,
                    title: AppLocalizations.of(context)!.privacyAndSecurity,
                    subtitle: AppLocalizations.of(
                      context,
                    )!.dataPermissionsPrivacy,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showComingSoonSnackBar(context, 'Privacy & Security');
                    },
                  ),
                  _divider(),
                  _settingsListTile(
                    icon: Icons.logout_rounded,
                    iconColor: AppColors.warning,
                    title: AppLocalizations.of(context)!.logout,
                    subtitle: 'Sign out of your account',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showLogoutDialog(context);
                    },
                  ),
                  _divider(),
                  _settingsListTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: const Color(0xFF818CF8),
                    title: AppLocalizations.of(context)!.about,
                    subtitle: 'Version 1.0',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showAboutDialog(context);
                    },
                  ),
                ]),

                // Bottom spacer to ensure scrolling above floating bottom navigation bar
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(
    BuildContext context,
    String label,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricGridCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkCard : AppColors.card).withValues(
          alpha: 0.65,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: (isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
              children: [
                TextSpan(text: value),
                if (unit.isNotEmpty) ...[
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: unit,
                    style: TextStyle(
                      fontSize: 12,
                      color: (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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
            AppColors.cardLight.withValues(alpha: 0.4),
            AppColors.cardLight.withValues(alpha: 0.08),
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
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
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
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
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
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
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
                            emailUpdated: profile.emailUpdated,
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
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
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
      },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withAlpha(25)
                : (isDark ? AppColors.darkCard : AppColors.card),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? AppColors.primary
                  : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ── Settings Helper Methods ───────────────────────────────────────

  String _currentLanguageName(AppProvider provider) {
    final code = provider.currentLocale.languageCode;
    final langs = LanguageService.getAvailableLanguages();
    final match = langs.firstWhere(
      (l) => l['code'] == code,
      orElse: () => {'name': 'English', 'flag': '🇬🇧'},
    );
    return '${match['flag']} ${match['name']}';
  }

  String _currentThemeName(AppProvider provider) {
    switch (provider.themeMode) {
      case ThemeMode.light:
        return '☀️ Light';
      case ThemeMode.dark:
        return '⚫️ Dark';
      case ThemeMode.system:
        return '⚙️ System Default';
    }
  }

  SliverToBoxAdapter _sectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _sectionCard(List<Widget> children) {
    return SliverToBoxAdapter(
      child: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkCard : AppColors.card)
                    .withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withValues(
                    alpha: 0.05,
                  ),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(children: children),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _settingsListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 4,
          ),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isDestructive
                  ? AppColors.error
                  : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: isDestructive
                  ? AppColors.error.withValues(alpha: 0.6)
                  : (isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary),
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
            size: 20,
          ),
          onTap: onTap,
        );
      },
    );
  }

  Widget _premiumTile(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            _showComingSoonSnackBar(context, 'Premium Subscription');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Premium Subscription',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Coming soon — unlock all features',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Soon',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoonSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Language Picker ───────────────────────────────────────────────

  void _showLanguagePicker(BuildContext context, AppProvider provider) {
    final languages = LanguageService.getAvailableLanguages();
    final currentCode = provider.currentLocale.languageCode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        String selected = currentCode;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(ctx).viewInsets.bottom +
                    MediaQuery.of(ctx).padding.bottom +
                    24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCardLight
                            : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(ctx)!.chooseLanguage,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(ctx).size.height * 0.45,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: languages.length,
                      separatorBuilder: (_, _) => Divider(
                        color: isDark
                            ? AppColors.darkCardLight
                            : AppColors.cardLight,
                        height: 1,
                      ),
                      itemBuilder: (_, i) {
                        final lang = languages[i];
                        final code = lang['code']!;
                        final isSelected = selected == code;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Text(
                            lang['flag']!,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            lang['name']!,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          subtitle: Text(
                            lang['native']!,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () => setSheetState(() => selected = code),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        HapticFeedback.mediumImpact();

                        final newLocalizations = lookupAppLocalizations(
                          Locale(selected),
                        );

                        await provider.setLocale(
                          Locale(selected),
                          notificationTitle:
                              newLocalizations.waterReminderNotificationTitle,
                          notificationBody:
                              newLocalizations.waterReminderNotificationBody,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(AppLocalizations.of(ctx)!.applyLanguage),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showThemePicker(BuildContext context, AppProvider provider) {
    final themes = [
      {
        'mode': ThemeMode.light,
        'name': 'Light Mode',
        'icon': '☀️',
        'desc': 'Always use light theme',
      },
      {
        'mode': ThemeMode.dark,
        'name': 'Dark Mode',
        'icon': '⚫️',
        'desc': 'Always use dark theme',
      },
      {
        'mode': ThemeMode.system,
        'name': 'System Default',
        'icon': '⚙️',
        'desc': 'Match device settings',
      },
    ];
    final currentMode = provider.themeMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        ThemeMode selected = currentMode;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(ctx).viewInsets.bottom +
                    MediaQuery.of(ctx).padding.bottom +
                    24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCardLight
                            : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Choose Theme',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: themes.length,
                    separatorBuilder: (_, _) => Divider(
                      color: isDark
                          ? AppColors.darkCardLight
                          : AppColors.cardLight,
                      height: 1,
                    ),
                    itemBuilder: (_, i) {
                      final theme = themes[i];
                      final mode = theme['mode'] as ThemeMode;
                      final isSelected = selected == mode;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Text(
                          theme['icon'] as String,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          theme['name'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        subtitle: Text(
                          theme['desc'] as String,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                              )
                            : null,
                        onTap: () => setSheetState(() => selected = mode),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        await provider.setThemeMode(selected);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Apply Theme'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEmailUpdateSheet(BuildContext context, AppProvider provider) {
    final controller = TextEditingController(text: provider.userProfile.email);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        bool isSaving = false;
        String? errorMsg;
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  MediaQuery.of(ctx).padding.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCardLight
                              : AppColors.cardLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Update Email',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A confirmation link will be sent to your new email address.',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        )!.newEmailAddress,
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                        errorText: errorMsg,
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkSurfaceMuted
                            : AppColors.surfaceMuted,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.border,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                final newEmail = controller.text.trim();
                                if (newEmail.isEmpty ||
                                    !newEmail.contains('@')) {
                                  setSheetState(
                                    () => errorMsg = AppLocalizations.of(
                                      context,
                                    )!.pleaseEnterValidEmail,
                                  );
                                  return;
                                }
                                setSheetState(() => isSaving = true);
                                try {
                                  await Supabase.instance.client.auth
                                      .updateUser(
                                        UserAttributes(email: newEmail),
                                      );

                                  // Mark email as updated
                                  final updatedProfile = provider.userProfile;
                                  updatedProfile.email = newEmail;
                                  updatedProfile.emailUpdated = true;
                                  await provider.updateProfile(updatedProfile);

                                  if (ctx.mounted) {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Confirmation email sent. Please check your inbox.',
                                        ),
                                        backgroundColor: AppColors.success,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                } on AuthException catch (e) {
                                  setSheetState(() {
                                    isSaving = false;
                                    errorMsg = e.message;
                                  });
                                } catch (_) {
                                  setSheetState(() {
                                    isSaving = false;
                                    errorMsg =
                                        'An error occurred. Please try again.';
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: AdaptiveLoadingIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  size: 20,
                                ),
                              )
                            : Text(
                                AppLocalizations.of(context)!.sendConfirmation,
                              ),
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

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.restaurant_menu_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'LilyFit',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A smart calorie and nutrition management app that helps you reach your health goals. Features global food database with strong support for African cuisines.',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Version 1.0',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.close),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            AppLocalizations.of(context)!.logout,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.logoutConfirm,
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                Navigator.pop(ctx);

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const CenteredAdaptiveLoadingIndicator(
                    color: AppColors.primary,
                  ),
                );

                try {
                  final provider = context.read<AppProvider>();

                  // Call provider.logout() which clears all data and signs out
                  await provider.logout();

                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (route) => false,
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(
                          context,
                        )!.logoutFailed(e.toString()),
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: Text(AppLocalizations.of(context)!.logout),
            ),
          ],
        );
      },
    );
  }
}
