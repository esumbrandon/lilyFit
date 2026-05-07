import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/meal_log.dart';
import '../../providers/app_provider.dart';
import '../../widgets/calorie_ring_painter.dart';
import '../../widgets/macro_progress_bar.dart';
import '../../widgets/meal_section_card.dart';
import '../../widgets/water_tracker_card.dart';
import '../../l10n/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final profile = provider.userProfile;
    final now = DateTime.now();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildAnimatedSection(
                0,
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top meta row — date · streak
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('EEEE, MMMM d').format(now),
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                          ),
                          if (provider.currentStreak > 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '🔥',
                                  style: TextStyle(fontSize: 13),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${provider.currentStreak} day streak',
                                  style: const TextStyle(
                                    color: AppColors.carbs,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      // Greeting label
                      Text(
                        _greetingLabel(now, l10n),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Name — gradient shimmer
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.primaryGradient.createShader(bounds),
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          profile.name.isNotEmpty ? profile.name : l10n.user,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                            height: 1.05,
                          ),
                        ),
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
                          label: l10n.protein.toUpperCase(),
                          current: provider.consumedProtein,
                          target: profile.targetProtein,
                          color: AppColors.protein,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MacroProgressBar(
                          label: l10n.carbs.toUpperCase(),
                          current: provider.consumedCarbs,
                          target: profile.targetCarbs,
                          color: AppColors.carbs,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MacroProgressBar(
                          label: l10n.fat.toUpperCase(),
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
                    l10n.todaysMeals,
                    style: const TextStyle(
                      color: Colors.white,
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
                    l10n.hydration,
                    style: const TextStyle(
                      color: Colors.white,
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
                    onAdd: () => provider.addWater(),
                    onRemove: () => provider.removeWater(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greetingLabel(DateTime now, AppLocalizations l10n) {
    final hour = now.hour;
    if (hour < 12) return '${l10n.goodMorning},';
    if (hour < 17) return '${l10n.goodAfternoon},';
    return '${l10n.goodEvening},';
  }

  void _navigateToFoodSearch(BuildContext context, MealType mealType) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FoodSearchScreen(mealType: mealType)),
    );
  }
}
