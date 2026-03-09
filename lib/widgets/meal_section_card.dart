import 'package:flutter/material.dart';
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
    final totalCalories = meals.fold(0.0, (sum, m) => sum + m.totalCalories);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(8)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                Text(
                  mealType.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealType.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (meals.isNotEmpty)
                        Text(
                          '${totalCalories.toInt()} kcal · ${meals.length} item${meals.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                // Add button
                Material(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onAddFood,
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
            const Divider(color: AppColors.cardLight, height: 1, indent: 20, endIndent: 20),
            ...meals.map((meal) => _FoodItemTile(
              meal: meal,
              onRemove: () => onRemoveFood(meal.id),
            )),
          ] else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Text(
                'Tap + to add food',
                style: TextStyle(
                  color: AppColors.textTertiary.withAlpha(120),
                  fontSize: 13,
                ),
              ),
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
    return Dismissible(
      key: Key(meal.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
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
            Text(
              meal.food.emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.food.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${meal.servings > 1 ? '${meal.servings}x ' : ''}${meal.food.servingSize}',
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
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
