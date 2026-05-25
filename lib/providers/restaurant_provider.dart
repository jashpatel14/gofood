import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/restaurant_api.dart';
import '../models/restaurant_model.dart';

// Provider for all restaurants with periodic auto-invalidation
final restaurantListProvider = FutureProvider<List<RestaurantModel>>((ref) async {
  final timer = Timer(const Duration(seconds: 10), () {
    ref.invalidateSelf();
  });
  ref.onDispose(() => timer.cancel());
  
  return await RestaurantApi().getRestaurants();
});

// Provider for a single restaurant by ID with periodic auto-invalidation
final restaurantDetailProvider = FutureProvider.family<RestaurantModel?, String>((ref, id) async {
  final timer = Timer(const Duration(seconds: 10), () {
    ref.invalidateSelf();
  });
  ref.onDispose(() => timer.cancel());
  
  return await RestaurantApi().getRestaurantById(id);
});

// Provider for restaurant search
final restaurantSearchProvider = FutureProvider.family<List<RestaurantModel>, String>((ref, query) async {
  if (query.isEmpty) return [];
  return await RestaurantApi().searchRestaurants(query);
});

