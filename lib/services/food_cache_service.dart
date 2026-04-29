import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_item.dart';
import 'supabase_service.dart';

/// Service to manage local caching of food data
/// Improves performance by reducing network calls
class FoodCacheService {
  static const String _foodsCacheKey = 'cached_foods';
  static const String _lastSyncKey = 'foods_last_sync';
  static const Duration _cacheValidityDuration = Duration(days: 7);

  final SupabaseService _supabaseService = SupabaseService();

  /// Get foods from cache or fetch from database
  Future<List<FoodItem>> getFoods({bool forceRefresh = false}) async {
    // Check if cache is valid
    if (!forceRefresh && await _isCacheValid()) {
      final cachedFoods = await _getFoodsFromCache();
      if (cachedFoods.isNotEmpty) {
        return cachedFoods;
      }
    }

    // Cache is invalid or empty, fetch from database
    return await _fetchAndCacheFoods();
  }

  /// Get foods filtered by region
  Future<List<FoodItem>> getFoodsByRegion(
    String region, {
    bool forceRefresh = false,
  }) async {
    final allFoods = await getFoods(forceRefresh: forceRefresh);

    if (region == 'all') {
      return allFoods;
    }

    return allFoods.where((food) => food.region == region).toList();
  }

  /// Search foods by name
  Future<List<FoodItem>> searchFoods(
    String query, {
    bool forceRefresh = false,
  }) async {
    final allFoods = await getFoods(forceRefresh: forceRefresh);

    if (query.isEmpty) {
      return allFoods;
    }

    final lowerQuery = query.toLowerCase();
    return allFoods.where((food) {
      return food.name.toLowerCase().contains(lowerQuery) ||
          food.region.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Force refresh foods from database
  Future<List<FoodItem>> refreshFoods() async {
    return await _fetchAndCacheFoods();
  }

  /// Check if cache needs updating
  Future<bool> needsUpdate() async {
    return !(await _isCacheValid());
  }

  /// Clear food cache
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_foodsCacheKey);
    await prefs.remove(_lastSyncKey);
  }

  /// Fetch foods from database and cache them locally
  Future<List<FoodItem>> _fetchAndCacheFoods() async {
    try {
      final foodsData = await _supabaseService.getAllFoods();

      final foods = foodsData.map((data) {
        return FoodItem(
          id: data['id'],
          name: data['name'],
          calories: (data['calories'] as num).toDouble(),
          protein: (data['protein'] as num).toDouble(),
          carbs: (data['carbs'] as num).toDouble(),
          fat: (data['fat'] as num).toDouble(),
          servingSize: data['serving_size'],
          region: data['region'],
          emoji: data['emoji'],
        );
      }).toList();

      // Cache the foods
      await _cacheFoods(foods);

      return foods;
    } catch (e) {
      // If fetch fails, try to return cached data as fallback
      final cachedFoods = await _getFoodsFromCache();
      if (cachedFoods.isNotEmpty) {
        return cachedFoods;
      }
      rethrow;
    }
  }

  /// Save foods to local cache
  Future<void> _cacheFoods(List<FoodItem> foods) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert foods to JSON
    final foodsJson = foods.map((food) => food.toJson()).toList();
    final jsonString = jsonEncode(foodsJson);

    // Save to cache
    await prefs.setString(_foodsCacheKey, jsonString);
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get foods from local cache
  Future<List<FoodItem>> _getFoodsFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_foodsCacheKey);

    if (jsonString == null) {
      return [];
    }

    try {
      final List<dynamic> foodsJson = jsonDecode(jsonString);
      return foodsJson.map((json) => FoodItem.fromJson(json)).toList();
    } catch (e) {
      // If parsing fails, clear cache and return empty
      await clearCache();
      return [];
    }
  }

  /// Check if cached data is still valid
  Future<bool> _isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getInt(_lastSyncKey);

    if (lastSync == null) {
      return false;
    }

    final lastSyncDate = DateTime.fromMillisecondsSinceEpoch(lastSync);
    final now = DateTime.now();
    final difference = now.difference(lastSyncDate);

    return difference < _cacheValidityDuration;
  }

  /// Get cache information (for debugging/settings)
  Future<Map<String, dynamic>> getCacheInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getInt(_lastSyncKey);
    final cachedFoods = await _getFoodsFromCache();

    return {
      'foodCount': cachedFoods.length,
      'lastSync': lastSync != null
          ? DateTime.fromMillisecondsSinceEpoch(lastSync)
          : null,
      'isValid': await _isCacheValid(),
    };
  }
}
