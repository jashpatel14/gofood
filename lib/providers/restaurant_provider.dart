import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/restaurant_api.dart';
import '../models/restaurant_model.dart';
import '../services/mock_data_service.dart';

// Provider for all restaurants
final restaurantListProvider = FutureProvider<List<RestaurantModel>>((ref) async {
  try {
    return await RestaurantApi().getRestaurants();
  } catch (_) {
    return MockData.restaurants;
  }
});

// Provider for a single restaurant by ID
final restaurantDetailProvider = FutureProvider.family<RestaurantModel?, String>((ref, id) async {
  try {
    return await RestaurantApi().getRestaurantById(id);
  } catch (_) {
    return MockData.getRestaurantById(id);
  }
});

// Provider for restaurant search
final restaurantSearchProvider = FutureProvider.family<List<RestaurantModel>, String>((ref, query) async {
  if (query.isEmpty) return [];
  try {
    return await RestaurantApi().searchRestaurants(query);
  } catch (_) {
    return MockData.searchRestaurants(query);
  }
});
