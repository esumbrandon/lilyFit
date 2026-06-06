import '../models/food_item.dart';
import '../services/food_cache_service.dart';

/// Food database that fetches from Supabase and caches locally
/// This improves performance and reduces network calls
class FoodDatabase {
  static final FoodDatabase _instance = FoodDatabase._internal();
  factory FoodDatabase() => _instance;
  FoodDatabase._internal();

  final FoodCacheService _cacheService = FoodCacheService();

  // Cache foods in memory for quick access during the session
  List<FoodItem>? _sessionCache;
  DateTime? _sessionCacheTime;
  static const _sessionCacheDuration = Duration(minutes: 30);

  /// Get all foods (cached)
  Future<List<FoodItem>> get foods async {
    // Check if session cache is still valid
    if (_sessionCache != null && _sessionCacheTime != null) {
      final timeSinceCache = DateTime.now().difference(_sessionCacheTime!);
      if (timeSinceCache < _sessionCacheDuration) {
        return _sessionCache!;
      }
    }

    // Fetch from cache service (which handles local storage + database)
    _sessionCache = await _cacheService.getFoods();
    _sessionCacheTime = DateTime.now();
    return _sessionCache!;
  }

  /// Search foods by name or region
  Future<List<FoodItem>> search(String query) async {
    return await _cacheService.searchFoods(query);
  }

  /// Get foods filtered by region
  Future<List<FoodItem>> byRegion(String region) async {
    return await _cacheService.getFoodsByRegion(region);
  }

  /// Force refresh foods from database
  Future<List<FoodItem>> refresh() async {
    _sessionCache = null;
    _sessionCacheTime = null;
    return await _cacheService.refreshFoods();
  }

  /// Clear all caches
  Future<void> clearCache() async {
    _sessionCache = null;
    _sessionCacheTime = null;
    await _cacheService.clearCache();
  }

  /// Check if cache needs updating
  Future<bool> needsUpdate() async {
    return await _cacheService.needsUpdate();
  }

  /// Get cache information
  Future<Map<String, dynamic>> getCacheInfo() async {
    return await _cacheService.getCacheInfo();
  }

  // Static helper methods for regions
  static List<String> get regions => [
    'all',
    'african',
    'western',
    'asian',
    'european',
  ];

  // static String regionEmoji(String region) => switch (region) {
  //   'all' => '',
  //   'african' => '',
  //   'western' => '',
  //   'asian' => '',
  //   'european' => '',
  //   _ => '',
  // };

  static String regionLabel(String region) => switch (region) {
    'all' => 'All',
    'african' => 'African',
    'western' => 'Western',
    'asian' => 'Asian',
    'european' => 'European',
    _ => 'Other',
  };
}
