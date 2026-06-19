import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../models/meal_log.dart';
import '../../providers/app_provider.dart';
import '../../widgets/calorie_ring_painter.dart';
import '../../widgets/macro_progress_bar.dart';
import '../../widgets/meal_section_card.dart';
import '../../widgets/water_tracker_card.dart';
import '../food_search/food_search_screen.dart';
import 'quick_stat_card.dart';
import 'streak_card.dart';
import 'sync_banner.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimations = List.generate(5, (index) {
      final start = index * 0.1;
      final end = start + 0.4;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnimations = List.generate(5, (index) {
      final start = index * 0.1;
      final end = start + 0.4;
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(position: _slideAnimations[index], child: child),
    );
  }

  /// Refresh data from Supabase
  Future<void> _refreshData(BuildContext context) async {
    final provider = context.read<AppProvider>();
    try {
      await provider.syncFromSupabase();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.refreshFailed}: ${e.toString()}',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<Widget> _buildContentSlivers(
    BuildContext context,
    AppProvider provider,
  ) {
    final profile = provider.userProfile;
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return [
      if (!provider.isOnline ||
          provider.syncStatus == SyncStatus.syncing ||
          provider.syncStatus == SyncStatus.done)
        SliverToBoxAdapter(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.5),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: const SyncBanner(),
          ),
        ),

      // Header
      SliverToBoxAdapter(
        child: _buildAnimatedSection(
          0,
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and Streak Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE').format(now),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MMMM d, y').format(now),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.textTertiary,
                              ),
                        ),
                      ],
                    ),
                    if (provider.currentStreak > 0)
                      StreakCard(currentStreak: provider.currentStreak),
                  ],
                ),
                const SizedBox(height: 20),
                // Quick Stats Row - Enhanced
                Row(
                  children: [
                    Expanded(
                      child: QuickStatCard(
                        icon: Icons.local_fire_department_rounded,
                        value: '${provider.consumedCalories.toInt()}',
                        label: 'Consumed',
                        color: AppColors.carbs,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: QuickStatCard(
                        icon: Icons.flag_rounded,
                        value: '${profile.targetCalories.toInt()}',
                        label: 'Target',
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: QuickStatCard(
                        icon: Icons.restaurant_rounded,
                        value: '${provider.allMealLogs.length}',
                        label: 'Meals',
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // Calorie Ring
      SliverToBoxAdapter(
        child: _buildAnimatedSection(
          1,
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CalorieRingWidget(
                consumed: provider.consumedCalories,
                target: profile.targetCalories,
                size: 220,
              ),
            ),
          ),
        ),
      ),

      SliverToBoxAdapter(
        child: _buildAnimatedSection(
          2,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: MacroProgressBar(
                    label: AppLocalizations.of(context)!.protein.toUpperCase(),
                    current: provider.consumedProtein,
                    target: profile.targetProtein,
                    color: AppColors.protein,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MacroProgressBar(
                    label: AppLocalizations.of(context)!.carbs.toUpperCase(),
                    current: provider.consumedCarbs,
                    target: profile.targetCarbs,
                    color: AppColors.carbs,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MacroProgressBar(
                    label: AppLocalizations.of(context)!.fat.toUpperCase(),
                    current: provider.consumedFat,
                    target: profile.targetFat,
                    color: AppColors.fat,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      SliverToBoxAdapter(
        child: _buildAnimatedSection(
          3,
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
            child: Text(
              AppLocalizations.of(context)!.todaysMeals,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      ),

      // Meal sections
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            _buildAnimatedSection(
              3,
              Column(
                children: [
                  ...MealType.values.map(
                    (type) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MealSectionCard(
                        mealType: type,
                        meals: provider.getMealsByType(type),
                        onAddFood: () => _navigateToFoodSearch(context, type),
                        onRemoveFood: (id) => provider.removeMeal(id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),

      // Section title: Hydration
      SliverToBoxAdapter(
        child: _buildAnimatedSection(
          4,
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Text(
              AppLocalizations.of(context)!.hydration,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      ),

      // Water tracker
      SliverToBoxAdapter(
        child: _buildAnimatedSection(
          4,
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: WaterTrackerCard(
              currentGlasses: provider.waterGlasses,
              goalGlasses: provider.waterGoalGlasses,
              progress: provider.waterProgress,
              currentMl: provider.waterIntake,
              goalMl: provider.waterGoal,
              onAdd: () => provider.addWater(),
              onRemove: () => provider.removeWater(),
            ),
          ),
        ),
      ),

      // Bottom padding for navbar
      const SliverToBoxAdapter(child: SizedBox(height: 80)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentSlivers = _buildContentSlivers(context, provider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Platform.isIOS
            ? CustomScrollView(
                slivers: [
                  // iOS native refresh control
                  CupertinoSliverRefreshControl(
                    onRefresh: () => _refreshData(context),
                  ),
                  ...contentSlivers,
                ],
              )
            : RefreshIndicator(
                onRefresh: () => _refreshData(context),
                color: AppColors.primary,
                backgroundColor: isDark
                    ? AppColors.darkSurface
                    : AppColors.surface,
                child: CustomScrollView(slivers: contentSlivers),
              ),
      ),
    );
  }

  void _navigateToFoodSearch(BuildContext context, MealType mealType) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FoodSearchScreen(mealType: mealType)),
    );
  }
}
