import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/app_localizations.dart';
import '../../services/gemini_service.dart';
import '../../services/image_service.dart';
import '../../theme/app_theme.dart';
import '../../models/food_item.dart';
import '../../models/meal_log.dart';
import '../../data/food_database.dart';
import '../../widgets/adaptive_loading_indicator.dart';
import 'search_bar_widget.dart';
import 'region_filter_widget.dart';
import 'food_item_card.dart';
import 'food_detail_sheet.dart';
import 'image_source_dialog.dart';

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
  final _imageService = ImageService();
  final _geminiService = GeminiService();
  String _selectedRegion = 'all';
  bool _isForwardSwitch = true;
  String _searchQuery = '';
  List<FoodItem> _allFoods = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isAnalyzing = false;

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
            content: Text(
              AppLocalizations.of(context)!.failedToLoadFoods(e.toString()),
            ),
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
          SnackBar(
            content: Text(AppLocalizations.of(context)!.foodDatabaseUpdated),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isRefreshing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToUpdate(e.toString()),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _analyzeWithAi(ImageSource source) async {
    setState(() => _isAnalyzing = true);
    try {
      final image = await _imageService.pickImage(source);
      if (image == null) {
        setState(() => _isAnalyzing = false);
        return;
      }
      final result = await _geminiService.analyzeImage(image);
      setState(() => _isAnalyzing = false);
      _showFoodDetail(context, FoodItem.fromJson(result));
    } catch (e) {
      setState(() => _isAnalyzing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing image: $e'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredFoods = _filteredFoods;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
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
                    child: AdaptiveLoadingIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                      size: 20,
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
            onPressed: _isRefreshing
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    _refreshFoods();
                  },
            tooltip: AppLocalizations.of(context)!.refreshFoodDatabase,
          ),
        ],
      ),
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
          // Content
          _isLoading
              ? const CenteredAdaptiveLoadingIndicator(color: AppColors.primary)
              : Column(
                  children: [
                    // Search bar
                    SearchBarWidget(
                      searchController: _searchController,
                      isAnalyzing: _isAnalyzing,
                      isRefreshing: _isRefreshing,
                      searchQuery: _searchQuery,
                      onSearchChanged: (v) => setState(() => _searchQuery = v),
                      onClearSearch: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      onRefresh: _refreshFoods,
                      onAnalyze: () {
                        HapticFeedback.lightImpact();
                        _showImageSourceDialog();
                      },
                    ),

                    // Region filter cards
                    RegionFilterWidget(
                      selectedRegion: _selectedRegion,
                      onRegionSelected: (region) {
                        final regions = FoodDatabase.regions;
                        setState(() {
                          _isForwardSwitch =
                              regions.indexOf(region) >
                              regions.indexOf(_selectedRegion);
                          _selectedRegion = region;
                        });
                      },
                      scrollController: _scrollController,
                    ),

                    // Results count
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                      child: Row(
                        children: [
                          Text(
                            '${filteredFoods.length} food${filteredFoods.length == 1 ? '' : 's'} found',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),

                    // Food list
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 100),
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
                        child: filteredFoods.isEmpty
                            ? Center(
                                key: ValueKey('empty_$_selectedRegion'),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 56,
                                      color: AppColors.textTertiary.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      AppLocalizations.of(context)!.noFoodsFound,
                                      style: Theme.of(context).textTheme.bodyLarge
                                          ?.copyWith(
                                            color: AppColors.textTertiary
                                                .withValues(alpha: 0.7),
                                          ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                key: ValueKey('list_$_selectedRegion'),
                                controller: _scrollController,
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                                itemCount: filteredFoods.length,
                                itemBuilder: (context, index) {
                                  if (index >= filteredFoods.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final food = filteredFoods[index];
                                  return FoodItemCard(
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
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ImageSourceDialog(
        onImageSourceSelected: (source) {
          _analyzeWithAi(source);
        },
      ),
    );
  }

  void _showFoodDetail(BuildContext context, FoodItem food) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => FoodDetailSheet(food: food, mealType: widget.mealType),
    );
  }
}
