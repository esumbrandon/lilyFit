import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/food_item.dart';
import '../../models/meal_log.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../data/food_database.dart';

class FoodDetailSheet extends StatefulWidget {
  final FoodItem food;
  final MealType? mealType;

  const FoodDetailSheet({super.key, required this.food, this.mealType});

  @override
  State<FoodDetailSheet> createState() => _FoodDetailSheetState();
}

class _FoodDetailSheetState extends State<FoodDetailSheet> {
  double _servings = 1.0;
  MealType? _selectedMealType;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.mealType;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final food = widget.food;
    final cals = food.calories * _servings;
    final protein = food.protein * _servings;
    final carbs = food.carbs * _servings;
    final fat = food.fat * _servings;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.cardLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Food header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: Text(food.emoji, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      '${food.servingSize} · ${FoodDatabase.regionLabel(food.region)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Nutrition info
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _nutritionItem(
                  AppLocalizations.of(context)!.calories,
                  '${cals.toInt()}',
                  'kcal',
                  AppColors.primary,
                ),
                _divider(),
                _nutritionItem(
                  AppLocalizations.of(context)!.protein,
                  protein.toStringAsFixed(1),
                  'g',
                  AppColors.protein,
                ),
                _divider(),
                _nutritionItem(
                  AppLocalizations.of(context)!.carbs,
                  carbs.toStringAsFixed(1),
                  'g',
                  AppColors.carbs,
                ),
                _divider(),
                _nutritionItem(
                  AppLocalizations.of(context)!.fat,
                  fat.toStringAsFixed(1),
                  'g',
                  AppColors.fat,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Servings slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.servings,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _servings == _servings.roundToDouble()
                      ? '${_servings.toInt()}x'
                      : '${_servings.toStringAsFixed(1)}x',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          Slider(
            value: _servings,
            min: 0.5,
            max: 5.0,
            divisions: 9,
            onChanged: (v) => setState(() => _servings = v),
            onChangeEnd: (_) => HapticFeedback.selectionClick(),
          ),

          // Meal type selector (if not pre-selected)
          if (widget.mealType == null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.addTo,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: MealType.values.map((type) {
                final selected = _selectedMealType == type;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedMealType = type);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withOpacity(0.25)
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            type.label,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.textTertiary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 20),

          // Add button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedMealType != null
                  ? () {
                      HapticFeedback.mediumImpact();
                      context.read<AppProvider>().addMeal(
                        food,
                        _selectedMealType!,
                        servings: _servings,
                      );
                      Navigator.pop(context);
                      if (widget.mealType != null) {
                        Navigator.pop(context);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.foodAddedToMeal(
                              food.name,
                              _selectedMealType!.label,
                            ),
                          ),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                '${AppLocalizations.of(context)!.add} ${cals.toInt()} kcal',
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _nutritionItem(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          unit,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: color.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 35, color: AppColors.cardLight);
  }
}
