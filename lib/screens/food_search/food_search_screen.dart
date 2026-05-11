import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
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
  final _scrollController = ScrollController();
  final _foodDatabase = FoodDatabase();
  String _selectedRegion = 'all';
  bool _isForwardSwitch = true;
  String _searchQuery = '';
  List<FoodItem> _allFoods = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    setState(() => _isLoading = true);
    try {
      final foods = await _foodDatabase.foods;
      setState(() {
        _allFoods = foods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load foods: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _refreshFoods() async {
    setState(() => _isRefreshing = true);
    try {
      final foods = await _foodDatabase.refresh();
      setState(() {
        _allFoods = foods;
        _isRefreshing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food database updated!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isRefreshing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<FoodItem> get _filteredFoods {
    List<FoodItem> foods = _selectedRegion == 'all'
        ? _allFoods
        : _allFoods.where((f) => f.region == _selectedRegion).toList();

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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mealType != null
              ? '${AppLocalizations.of(context)!.addTo} ${widget.mealType!.label}'
              : AppLocalizations.of(context)!.foodDatabase,
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
            onPressed: _isRefreshing
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    _refreshFoods();
                  },
            tooltip: 'Refresh food database',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.searchHint,
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
                                HapticFeedback.lightImpact();
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),

                // Region filter cards
                SizedBox(
                  height: 72,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: FoodDatabase.regions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final region = FoodDatabase.regions[index];
                      final selected = _selectedRegion == region;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          if (region == _selectedRegion) return;
                          final regions = FoodDatabase.regions;
                          setState(() {
                            _isForwardSwitch =
                                regions.indexOf(region) >
                                regions.indexOf(_selectedRegion);
                            _selectedRegion = region;
                          });
                          // Scroll list back to top
                          if (_scrollController.hasClients) {
                            _scrollController.jumpTo(0);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: selected
                                ? AppColors.primaryGradient
                                : null,
                            color: selected ? null : AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? Colors.transparent
                                  : AppColors.cardLight,
                              width: 1.5,
                            ),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withAlpha(60),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                FoodDatabase.regionEmoji(region),
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 7),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutCubic,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 13,
                                ),
                                child: Text(FoodDatabase.regionLabel(region)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Results count
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Row(
                    children: [
                      Text(
                        '${_filteredFoods.length} food${_filteredFoods.length == 1 ? '' : 's'} found',
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 380),
                    transitionBuilder: (child, animation) {
                      // Detect incoming vs outgoing by matching the current key
                      final currentKey = ValueKey('list_$_selectedRegion');
                      final currentEmptyKey = ValueKey(
                        'empty_$_selectedRegion',
                      );
                      final isIncoming =
                          child.key == currentKey ||
                          child.key == currentEmptyKey;
                      // Incoming slides in from the side; outgoing exits the opposite way
                      final inOffset = _isForwardSwitch
                          ? const Offset(1.0, 0)
                          : const Offset(-1.0, 0);
                      final outOffset = _isForwardSwitch
                          ? const Offset(-0.3, 0)
                          : const Offset(0.3, 0);
                      final position =
                          Tween<Offset>(
                            begin: isIncoming ? inOffset : outOffset,
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: isIncoming
                                  ? Curves.easeOutCubic
                                  : Curves.easeInCubic,
                            ),
                          );
                      return FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: isIncoming
                              ? Curves.easeOut
                              : const Interval(0.0, 0.5),
                        ),
                        child: SlideTransition(
                          position: position,
                          child: child,
                        ),
                      );
                    },
                    child: _filteredFoods.isEmpty
                        ? Center(
                            key: ValueKey('empty_$_selectedRegion'),
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
                                  AppLocalizations.of(context)!.noFoodsFound,
                                  style: TextStyle(
                                    color: AppColors.textTertiary.withAlpha(
                                      150,
                                    ),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            key: ValueKey('list_$_selectedRegion'),
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: _filteredFoods.length,
                            itemBuilder: (context, index) {
                              final food = _filteredFoods[index];
                              return _FoodItemCard(
                                key: ValueKey(food.name),
                                food: food,
                                index: index,
                                onTap: () => _showFoodDetail(context, food),
                              );
                            },
                          ),
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

class _FoodItemCard extends StatefulWidget {
  final FoodItem food;
  final VoidCallback onTap;
  final int index;

  const _FoodItemCard({
    super.key,
    required this.food,
    required this.onTap,
    required this.index,
  });

  @override
  State<_FoodItemCard> createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<_FoodItemCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    // Stagger first ~9 items; beyond that animate immediately
    final delay = (widget.index * 45).clamp(0, 360);
    if (delay == 0) {
      _entrance.forward();
    } else {
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) _entrance.forward();
      });
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opacity = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));

    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(
        position: slide,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOut,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onTap();
                },
                onTapDown: (_) => setState(() => _pressed = true),
                onTapUp: (_) => setState(() => _pressed = false),
                onTapCancel: () => setState(() => _pressed = false),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
                        child: Text(
                          widget.food.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.food.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${widget.food.servingSize} · ${FoodDatabase.regionLabel(widget.food.region)}',
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
                          '${widget.food.calories.toInt()} kcal',
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
              Text(
                AppLocalizations.of(context)!.servings,
                style: const TextStyle(
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
            onChangeEnd: (_) => HapticFeedback.selectionClick(),
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
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedMealType = type);
                    },
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
                '${AppLocalizations.of(context)!.add} ${cals.toInt()} kcal',
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
