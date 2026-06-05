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
import '../../widgets/adaptive_loading_indicator.dart';
import '../food_search/food_search_screen.dart';

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

    // Create staggered animations for 5 sections
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
      // Sync data from Supabase
      await provider.syncFromSupabase();
      // Success - no message shown to avoid clutter
    } catch (e) {
      // Show error message only if refresh fails
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

  /// Build the list of slivers for the scrollview (excluding refresh control)
  List<Widget> _buildContentSlivers(BuildContext context, AppProvider provider) {
    final profile = provider.userProfile;
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return [
      // Offline / Syncing / Sync-Done Banner
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
            child: _buildSyncBanner(provider),
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
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MMMM d, y').format(now),
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.textTertiary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (provider.currentStreak > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.carbs.withAlpha(25),
                              AppColors.carbs.withAlpha(15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.carbs.withAlpha(60),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '🔥',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${provider.currentStreak} ${provider.currentStreak == 1 ? "Day" : "Days"}',
                                  style: const TextStyle(
                                    color: AppColors.carbs,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Streak',
                                  style: TextStyle(
                                    color: AppColors.carbs.withAlpha(
                                      180,
                                    ),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                // Quick Stats Row - Enhanced
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickStat(
                        context,
                        Icons.local_fire_department_rounded,
                        '${provider.consumedCalories.toInt()}',
                        'Consumed',
                        AppColors.carbs,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildQuickStat(
                        context,
                        Icons.flag_rounded,
                        '${profile.targetCalories.toInt()}',
                        'Target',
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildQuickStat(
                        context,
                        Icons.restaurant_rounded,
                        '${provider.allMealLogs.length}',
                        'Meals',
                        AppColors.secondary,
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

      // Macro bars
      SliverToBoxAdapter(
        child: _buildAnimatedSection(
          2,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: MacroProgressBar(
                    label: AppLocalizations.of(
                      context,
                    )!.protein.toUpperCase(),
                    current: provider.consumedProtein,
                    target: profile.targetProtein,
                    color: AppColors.protein,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MacroProgressBar(
                    label: AppLocalizations.of(
                      context,
                    )!.carbs.toUpperCase(),
                    current: provider.consumedCarbs,
                    target: profile.targetCarbs,
                    color: AppColors.carbs,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MacroProgressBar(
                    label: AppLocalizations.of(
                      context,
                    )!.fat.toUpperCase(),
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

      // Section title: Today's Meals
      SliverToBoxAdapter(
        child: _buildAnimatedSection(
          3,
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
            child: Text(
              AppLocalizations.of(context)!.todaysMeals,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
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
                        onAddFood: () =>
                            _navigateToFoodSearch(context, type),
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
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentSlivers = _buildContentSlivers(context, provider);

    return Scaffold(
      body: SafeArea(
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
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
                child: CustomScrollView(
                  slivers: contentSlivers,
                ),
              ),
      ),
    );
  }

  Widget _buildSyncBanner(AppProvider provider) {
    final isDone = provider.syncStatus == SyncStatus.done;
    final isSyncing = provider.syncStatus == SyncStatus.syncing;
    final hasPendingItems = provider.pendingOperationsCount > 0;
    final isOffline = !provider.isOnline;

    late Color bgColor;
    late Color borderColor;
    late Color iconColor;
    late IconData icon;
    late String message;

    if (isDone) {
      bgColor = Colors.green.withAlpha(20);
      borderColor = Colors.green.withAlpha(50);
      iconColor = Colors.green;
      icon = Icons.check_circle_rounded;
      message = 'All changes synced';
    } else if (isSyncing) {
      bgColor = AppColors.primary.withAlpha(20);
      borderColor = AppColors.primary.withAlpha(40);
      iconColor = AppColors.primary;
      icon = Icons.sync_rounded;
      final count = provider.pendingOperationsCount;
      message = count > 0
          ? 'Syncing $count ${count == 1 ? "item" : "items"}...'
          : 'Syncing...';
    } else if (isOffline && hasPendingItems) {
      // Offline with pending items
      bgColor = AppColors.accent.withAlpha(15);
      borderColor = AppColors.accent.withAlpha(45);
      iconColor = AppColors.accent;
      icon = Icons.cloud_off_rounded;
      final count = provider.pendingOperationsCount;
      message = 'Offline – $count ${count == 1 ? "change" : "changes"} pending';
    } else if (isOffline) {
      // Just offline, no pending items
      bgColor = AppColors.accent.withAlpha(15);
      borderColor = AppColors.accent.withAlpha(45);
      iconColor = AppColors.accent;
      icon = Icons.cloud_off_rounded;
      message = 'Offline mode';
    } else {
      // This shouldn't happen but handle it gracefully
      // Online with pending items but not syncing (shouldn't display)
      return const SizedBox.shrink();
    }

    return Container(
      key: ValueKey(
        isDone
            ? 'done'
            : isSyncing
            ? 'syncing'
            : 'offline',
      ),
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          isSyncing && !isDone
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: AdaptiveLoadingIndicator(
                    color: iconColor,
                    strokeWidth: 2,
                    size: 18,
                  ),
                )
              : Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: iconColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(30), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.textTertiary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToFoodSearch(BuildContext context, MealType mealType) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FoodSearchScreen(mealType: mealType)),
    );
  }
}

