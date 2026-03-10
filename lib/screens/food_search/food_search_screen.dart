import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/food_item.dart';
import '../../models/meal_log.dart';
import '../../data/food_database.dart';
import '../../providers/app_provider.dart';

class FoodSearchScreen extends StatefulWidget {
  final MealType? mealType;

  const FoodSearchScreen({super.key, this.mealType});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final _searchController = TextEditingController();
  String _selectedRegion = 'all';
  String _searchQuery = '';

  List<FoodItem> get _filteredFoods {
    List<FoodItem> foods = FoodDatabase.byRegion(_selectedRegion);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      foods = foods
          .where(
            (f) =>
                f.name.toLowerCase().contains(q) ||
                f.region.toLowerCase().contains(q),
          )
          .toList();
    }
    return foods;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foods = _filteredFoods;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mealType != null
              ? 'Add to ${widget.mealType!.label}'
              : 'Food Database',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search foods...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textTertiary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: AppColors.textTertiary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // Region filter chips
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: FoodDatabase.regions.map((region) {
                final selected = _selectedRegion == region;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      '${FoodDatabase.regionEmoji(region)} ${FoodDatabase.regionLabel(region)}',
                    ),
                    selected: selected,
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedRegion = region);
                    },
                    selectedColor: AppColors.primary.withAlpha(30),
                    labelStyle: TextStyle(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 13,
                    ),
                    checkmarkColor: AppColors.primary,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: selected
                            ? AppColors.primary.withAlpha(80)
                            : Colors.transparent,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Row(
              children: [
                Text(
                  '${foods.length} food${foods.length == 1 ? '' : 's'} found',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Food list
          Expanded(
            child: foods.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 56,
                          color: AppColors.textTertiary.withAlpha(100),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No foods found',
                          style: TextStyle(
                            color: AppColors.textTertiary.withAlpha(150),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: foods.length,
                    itemBuilder: (context, index) {
                      final food = foods[index];
                      return _FoodItemCard(
                        food: food,
                        onTap: () => _showFoodDetail(context, food),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFoodDetail(BuildContext context, FoodItem food) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _FoodDetailSheet(food: food, mealType: widget.mealType),
    );
  }
}

class _FoodItemCard extends StatelessWidget {
  final FoodItem food;
  final VoidCallback onTap;

  const _FoodItemCard({required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Emoji
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.cardLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(food.emoji, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${food.servingSize} · ${FoodDatabase.regionLabel(food.region)}',
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Calories badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${food.calories.toInt()} kcal',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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
}

class _FoodDetailSheet extends StatefulWidget {
  final FoodItem food;
  final MealType? mealType;

  const _FoodDetailSheet({required this.food, this.mealType});

  @override
  State<_FoodDetailSheet> createState() => _FoodDetailSheetState();
}

class _FoodDetailSheetState extends State<_FoodDetailSheet> {
  double _servings = 1.0;
  MealType? _selectedMealType;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.mealType;
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final cals = food.calories * _servings;
    final protein = food.protein * _servings;
    final carbs = food.carbs * _servings;
    final fat = food.fat * _servings;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${food.servingSize} · ${FoodDatabase.regionLabel(food.region)}',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 13,
                      ),
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
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _nutritionItem(
                  'Calories',
                  '${cals.toInt()}',
                  'kcal',
                  AppColors.primary,
                ),
                _divider(),
                _nutritionItem(
                  'Protein',
                  protein.toStringAsFixed(1),
                  'g',
                  AppColors.protein,
                ),
                _divider(),
                _nutritionItem(
                  'Carbs',
                  carbs.toStringAsFixed(1),
                  'g',
                  AppColors.carbs,
                ),
                _divider(),
                _nutritionItem(
                  'Fat',
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
              const Text(
                'Servings',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _servings == _servings.roundToDouble()
                      ? '${_servings.toInt()}x'
                      : '${_servings.toStringAsFixed(1)}x',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
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
          ),

          // Meal type selector (if not pre-selected)
          if (widget.mealType == null) ...[
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add to',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: MealType.values.map((type) {
                final selected = _selectedMealType == type;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMealType = type),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withAlpha(25)
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
                          Text(
                            type.emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            type.label,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
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
                            '${food.name} added to ${_selectedMealType!.label}',
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
                'Add ${cals.toInt()} kcal',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
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
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(unit, style: TextStyle(color: color.withAlpha(150), fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 35, color: AppColors.cardLight);
  }
}
