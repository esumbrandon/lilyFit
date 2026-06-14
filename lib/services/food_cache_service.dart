import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_item.dart';
import 'supabase_service.dart';

class FoodCacheService {
  static const String _foodsCacheKey = 'cached_foods';
  static const String _lastSyncKey = 'foods_last_sync';
  static const Duration _cacheValidityDuration = Duration(days: 7);

  final SupabaseService _supabaseService = SupabaseService();

  Future<List<FoodItem>> getFoods({bool forceRefresh = false}) async {
    if (!forceRefresh && await _isCacheValid()) {
      final cachedFoods = await _getFoodsFromCache();
      if (cachedFoods.isNotEmpty) {
        return cachedFoods;
      }
    }

    return await _fetchAndCacheFoods();
  }

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

  Future<List<FoodItem>> refreshFoods() async {
    return await _fetchAndCacheFoods();
  }

  Future<bool> needsUpdate() async {
    return !(await _isCacheValid());
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_foodsCacheKey);
    await prefs.remove(_lastSyncKey);
  }

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
      final cachedFoods = await _getFoodsFromCache();
      if (cachedFoods.isNotEmpty) {
        return cachedFoods;
      }
      rethrow;
    }
  }

  Future<void> _cacheFoods(List<FoodItem> foods) async {
    final prefs = await SharedPreferences.getInstance();

    final foodsJson = foods.map((food) => food.toJson()).toList();
    final jsonString = jsonEncode(foodsJson);

    await prefs.setString(_foodsCacheKey, jsonString);
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

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
      await clearCache();
      return [];
    }
  }

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
