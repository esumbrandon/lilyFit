import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../models/meal_log.dart';

class MealSectionCard extends StatelessWidget {
  final MealType mealType;
  final List<MealLog> meals;
  final VoidCallback onAddFood;
  final Function(String id) onRemoveFood;

  const MealSectionCard({
    super.key,
    required this.mealType,
    required this.meals,
    required this.onAddFood,
    required this.onRemoveFood,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalCalories = meals.fold(0.0, (sum, m) => sum + m.totalCalories);

    return Container(
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
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealType.label,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (meals.isNotEmpty)
                        Text(
                          '${totalCalories.toInt()} kcal · ${meals.length} item${meals.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                // Add button
                Material(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onAddFood();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.add_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Food items
          if (meals.isNotEmpty) ...[
            Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Divider(
                  color: isDark ? AppColors.darkCardLight : AppColors.cardLight,
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                );
              },
            ),
            ...meals.map(
              (meal) => _FoodItemTile(
                meal: meal,
                onRemove: () => onRemoveFood(meal.id),
              ),
            ),
          ] else
            Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Text(
                    AppLocalizations.of(context)!.tapToAddFood,
                    style: TextStyle(
                      color:
                          (isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.textTertiary)
                              .withAlpha(120),
                      fontSize: 13,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _FoodItemTile extends StatelessWidget {
  final MealLog meal;
  final VoidCallback onRemove;

  const _FoodItemTile({required this.meal, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dismissible(
      key: Key(meal.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        onRemove();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(40),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Text(meal.food.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.food.name,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${meal.servings > 1 ? '${meal.servings}x ' : ''}${meal.food.servingSize}',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${meal.totalCalories.toInt()} kcal',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
