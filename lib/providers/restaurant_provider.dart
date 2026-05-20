import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/restaurant_api.dart';
import '../models/restaurant_model.dart';

// Provider for all restaurants
final restaurantListProvider = FutureProvider<List<RestaurantModel>>((ref) async {
  return await RestaurantApi().getRestaurants();
});

// Provider for a single restaurant by ID
final restaurantDetailProvider = FutureProvider.family<RestaurantModel?, String>((ref, id) async {
  return await RestaurantApi().getRestaurantById(id);
});

// Provider for restaurant search
final restaurantSearchProvider = FutureProvider.family<List<RestaurantModel>, String>((ref, query) async {
  if (query.isEmpty) return [];
  return await RestaurantApi().searchRestaurants(query);
});
