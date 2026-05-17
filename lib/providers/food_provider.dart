import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/food_api.dart';
import '../models/food_model.dart';
import '../services/mock_data_service.dart';

// Provider for popular foods
final popularFoodsProvider = FutureProvider<List<FoodModel>>((ref) async {
  try {
    return await FoodApi().getPopularFoods();
  } catch (_) {
    return MockData.getPopularFoods();
  }
});

// Provider for foods by restaurant
final foodsByRestaurantProvider = FutureProvider.family<List<FoodModel>, String>((ref, restaurantId) async {
  try {
    return await FoodApi().getFoods(restaurantId: restaurantId);
  } catch (_) {
    return MockData.getFoodsByRestaurant(restaurantId);
  }
});

// Provider for a single food by ID
final foodDetailProvider = FutureProvider.family<FoodModel?, String>((ref, id) async {
  try {
    return await FoodApi().getFoodById(id);
  } catch (_) {
    return MockData.getFoodById(id);
  }
});

// Provider for food search
final foodSearchProvider = FutureProvider.family<List<FoodModel>, String>((ref, query) async {
  if (query.isEmpty) return [];
  try {
    return await FoodApi().searchFoods(query);
  } catch (_) {
    return MockData.searchFoods(query);
  }
});
