import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/food_api.dart';
import '../models/food_model.dart';

// Provider for popular foods
final popularFoodsProvider = FutureProvider<List<FoodModel>>((ref) async {
  return await FoodApi().getPopularFoods();
});

// Provider for foods by restaurant
final foodsByRestaurantProvider = FutureProvider.family<List<FoodModel>, String>((ref, restaurantId) async {
  return await FoodApi().getFoods(restaurantId: restaurantId);
});

// Provider for a single food by ID
final foodDetailProvider = FutureProvider.family<FoodModel?, String>((ref, id) async {
  return await FoodApi().getFoodById(id);
});

// Provider for food search
final foodSearchProvider = FutureProvider.family<List<FoodModel>, String>((ref, query) async {
  if (query.isEmpty) return [];
  return await FoodApi().searchFoods(query);
});
