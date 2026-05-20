import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/food_model.dart';
import '../../models/restaurant_model.dart';
import '../../providers/cart_provider.dart';
import '../../services/mock_data_service.dart';
import '../../api/food_api.dart';
import '../../api/restaurant_api.dart';
import '../../models/restaurant_status.dart';
import '../../providers/restaurant_provider.dart';
import '../../widgets/cart_counter_button.dart';
import '../../widgets/network_image_widget.dart';
import '../../widgets/status_badge.dart';

class CategoryDetailsScreen extends ConsumerStatefulWidget {
  final String categoryName;
  const CategoryDetailsScreen({super.key, required this.categoryName});

  @override
  ConsumerState<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends ConsumerState<CategoryDetailsScreen> with SingleTickerProviderStateMixin {
  late String _activeCategory;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  // Future caches to prevent continuous reloading
  Future<List<FoodModel>>? _foodsFuture;
  Future<List<RestaurantModel>>? _restaurantsFuture;

  @override
  void initState() {
    super.initState();
    _activeCategory = widget.categoryName;
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    _foodsFuture = _fetchCategoryFoods(_activeCategory);
    _restaurantsFuture = _foodsFuture!.then((foods) => _fetchCategoryRestaurants(foods));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<FoodModel>> _fetchCategoryFoods(String category) async {
    try {
      final foods = await FoodApi().getFoods(category: category);
      if (foods.isEmpty) {
        return MockData.getFoodsByCategory(category);
      }
      return foods;
    } catch (_) {
      return MockData.getFoodsByCategory(category);
    }
  }

  Future<List<RestaurantModel>> _fetchCategoryRestaurants(List<FoodModel> categoryFoods) async {
    final uniqueIds = categoryFoods.map((f) => f.restaurantId).toSet().toList();
    final List<RestaurantModel> matchedRestaurants = [];
    
    for (final id in uniqueIds) {
      try {
        final r = await RestaurantApi().getRestaurantById(id);
        matchedRestaurants.add(r);
      } catch (_) {
        final r = MockData.getRestaurantById(id);
        if (r != null) matchedRestaurants.add(r);
      }
    }

    // Fallback: search all restaurants by name match in cuisine types if no direct dishes match
    if (matchedRestaurants.isEmpty) {
      try {
        final all = await RestaurantApi().getRestaurants();
        final matches = all.where((r) => r.cuisineType.toLowerCase().contains(_activeCategory.toLowerCase())).toList();
        matchedRestaurants.addAll(matches);
      } catch (_) {
        final matches = MockData.restaurants.where((r) => r.cuisineType.toLowerCase().contains(_activeCategory.toLowerCase())).toList();
        matchedRestaurants.addAll(matches);
      }
    }
    return matchedRestaurants;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;

    // Cart badge calculation
    final cartState = ref.watch(cartProvider);
    final cartCount = cartState.totalItems;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '$_activeCategory Feast',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: textColor),
            onPressed: () => context.push('/search'),
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_bag_outlined, color: textColor),
                onPressed: () => context.push('/cart'),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Horizontal Category Switcher ──
          SizedBox(
            height: 55,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: MockData.categories.length,
              itemBuilder: (context, i) {
                final cat = MockData.categories[i];
                final isActive = cat.name.toLowerCase() == _activeCategory.toLowerCase();
                
                return GestureDetector(
                  onTap: () {
                    if (!isActive) {
                      setState(() {
                        _activeCategory = cat.name;
                        _loadData();
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: isActive ? AppColors.primaryGradient : null,
                      color: isActive ? null : (isDark ? AppColors.darkCard : AppColors.surface),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isActive ? AppColors.elevatedShadow : (isDark ? null : AppColors.cardShadow),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          cat.icon,
                          color: isActive ? Colors.white : AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat.name,
                          style: TextStyle(
                            color: isActive ? Colors.white : textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // ── Premium Tab Bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: subColor,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                tabs: const [
                  Tab(text: 'Popular Dishes'),
                  Tab(text: 'Restaurants'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Tab Bar View ──
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDishesTab(isDark, cardColor, textColor, subColor),
                _buildRestaurantsTab(isDark, cardColor, textColor, subColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Dishes Grid Tab View ──
  Widget _buildDishesTab(bool isDark, Color cardColor, Color textColor, Color subColor) {
    final restaurants = ref.watch(restaurantListProvider).value ?? [];
    return FutureBuilder<List<FoodModel>>(
      future: _foodsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('No dishes found in this category');
        }

        final dishes = snapshot.data!;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 14,
            mainAxisSpacing: 16,
          ),
          itemCount: dishes.length,
          itemBuilder: (context, i) {
            final f = dishes[i];
            
            return GestureDetector(
              onTap: () => context.push('/food-details/${f.id}'),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isDark ? null : AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          NetworkImageWidget(
                            imageUrl: f.image,
                            height: double.infinity,
                            width: double.infinity,
                            borderRadius: 20,
                          ),
                          // Rating Badge
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: AppColors.warning, size: 12),
                                  const SizedBox(width: 2),
                                  Text(
                                    f.rating.toString(),
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Veg / Non-veg dot
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  border: Border.all(color: f.isVeg ? AppColors.success : AppColors.error, width: 1.5),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: f.isVeg ? AppColors.success : AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.name,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            f.restaurantName,
                            style: TextStyle(fontSize: 11, color: subColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${f.price.toInt()}',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
                              ),
                              CartCounterButton(
                                food: f,
                                isDisabled: (() {
                                  RestaurantModel? matchedRest;
                                  for (final r in restaurants) {
                                    if (r.id == f.restaurantId) {
                                      matchedRest = r;
                                      break;
                                    }
                                  }
                                  return matchedRest != null && 
                                      (matchedRest.status == RestaurantStatus.closed || matchedRest.status == RestaurantStatus.temporarilyClosed);
                                })(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (i * 60).ms, duration: 300.ms).slideY(begin: 0.1, end: 0);
          },
        );
      },
    );
  }

  // ── Restaurants Feed Tab View ──
  Widget _buildRestaurantsTab(bool isDark, Color cardColor, Color textColor, Color subColor) {
    return FutureBuilder<List<RestaurantModel>>(
      future: _restaurantsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('No restaurants found serving $_activeCategory');
        }

        final restaurants = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          itemCount: restaurants.length,
          itemBuilder: (context, i) {
            final r = restaurants[i];
            
            return GestureDetector(
              onTap: () => context.push('/restaurant/${r.id}'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: isDark ? null : AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        NetworkImageWidget(
                          imageUrl: r.image,
                          height: 170,
                          width: double.infinity,
                          borderRadius: 22,
                        ),
                        // Rating Badge
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  r.rating.toString(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Delivery Time Badge
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer_outlined, size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  r.deliveryTime,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!r.isOpen)
                          Positioned(top: 12, left: 12, child: StatusBadge.closed()),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.name,
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: textColor),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  r.cuisineType,
                                  style: TextStyle(fontSize: 13, color: subColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.location_on_outlined, size: 14, color: subColor),
                              const SizedBox(width: 2),
                              Text(
                                '${r.distance} km',
                                style: TextStyle(fontSize: 12, color: subColor, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (i * 100).ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
          },
        );
      },
    );
  }

  // ── Empty State Widget ──
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu_rounded, size: 72, color: AppColors.primary.withValues(alpha: 0.25)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
