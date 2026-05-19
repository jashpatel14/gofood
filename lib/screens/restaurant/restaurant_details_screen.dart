import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/restaurant_status.dart';
import '../../services/restaurant_status_service.dart';
import '../../providers/food_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/network_image_widget.dart';
import '../../widgets/status_badge.dart';

class RestaurantDetailsScreen extends ConsumerStatefulWidget {
  final String restaurantId;
  const RestaurantDetailsScreen({super.key, required this.restaurantId});
  @override
  ConsumerState<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends ConsumerState<RestaurantDetailsScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final restaurantAsync = ref.watch(restaurantDetailProvider(widget.restaurantId));
    final foodsAsync = ref.watch(foodsByRestaurantProvider(widget.restaurantId));
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;

    return restaurantAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary))),
      error: (e, s) => Scaffold(appBar: AppBar(), body: const Center(child: Text('Failed to load restaurant'))),
      data: (restaurant) {
        if (restaurant == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Restaurant not found')));
        }

        return foodsAsync.when(
          loading: () => Scaffold(body: const Center(child: CircularProgressIndicator(color: AppColors.primary))),
          error: (e, s) => Scaffold(appBar: AppBar(), body: const Center(child: Text('Failed to load menu'))),
          data: (allFoods) {
    final foods = _selectedCategory == 'All' ? allFoods : allFoods.where((f) => f.category == _selectedCategory).toList();
    final categories = ['All', ...{...allFoods.map((f) => f.category)}];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(slivers: [
        // Sliver App Bar
        SliverAppBar(
          expandedHeight: 260, pinned: true,
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
          leading: Padding(padding: const EdgeInsets.all(8),
            child: CircleAvatar(backgroundColor: Colors.white.withValues(alpha: 0.9),
              child: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20)))),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(fit: StackFit.expand, children: [
              NetworkImageWidget(imageUrl: restaurant.image),
              Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent]))),
              Positioned(bottom: 20, left: 20, right: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  RestaurantStatusBadge(status: restaurant.status),
                  const SizedBox(width: 8),
                  RatingBadge(rating: restaurant.rating),
                ]),
                const SizedBox(height: 10),
                Text(restaurant.name, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(restaurant.cuisineType, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14)),
              ])),
            ]),
          ),
        ),

        // Info Row
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(18), boxShadow: isDark ? null : AppColors.cardShadow),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _infoItem(Icons.timer_outlined, restaurant.status == RestaurantStatus.busy ? '${restaurant.deliveryTime} (+15m busy)' : restaurant.deliveryTime, 'Delivery', textColor, subColor),
              Container(width: 1, height: 40, color: isDark ? AppColors.darkDivider : AppColors.divider),
              _infoItem(Icons.star_rounded, '${restaurant.rating}', '${restaurant.reviewCount}+ ratings', textColor, subColor),
              Container(width: 1, height: 40, color: isDark ? AppColors.darkDivider : AppColors.divider),
              _infoItem(Icons.location_on_outlined, '${restaurant.distance} km', 'Distance', textColor, subColor),
            ]),
          ).animate().fadeIn(duration: 400.ms),
        ),

        // Closed or Temporarily Paused warning banner
        if (restaurant.status == RestaurantStatus.closed || restaurant.status == RestaurantStatus.temporarilyClosed)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.withValues(alpha: 0.25), width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      restaurant.status == RestaurantStatus.temporarilyClosed
                          ? 'We are temporarily closed. Accepting orders soon!'
                          : 'Ordering is disabled because this restaurant is closed. Opens at ${RestaurantStatusService.formatTimeTo12Hour(restaurant.openTime)}.',
                      style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ).animate().shake(duration: 400.ms),
          ),

        // Category Chips
        SliverToBoxAdapter(
          child: Padding(padding: const EdgeInsets.fromLTRB(20, 20, 0, 12),
            child: SizedBox(height: 40, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: categories.length,
              itemBuilder: (ctx, i) {
                final selected = categories[i] == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = categories[i]),
                  child: Container(margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(color: selected ? AppColors.primary : (isDark ? AppColors.darkCard : AppColors.primarySurface), borderRadius: BorderRadius.circular(12)),
                    alignment: Alignment.center,
                    child: Text(categories[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.primary))),
                );
              }))),
        ),

        // Menu Header
        SliverToBoxAdapter(
          child: Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text('Menu (${foods.length} items)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor))),
        ),

        // Food List
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(delegate: SliverChildBuilderDelegate((ctx, i) {
            final food = foods[i];
            return GestureDetector(
              onTap: () => context.push('/food-details/${food.id}'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(18), boxShadow: isDark ? null : AppColors.cardShadow),
                child: Row(children: [
                  NetworkImageWidget(imageUrl: food.image, width: 100, height: 100, borderRadius: 14),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(color: food.isVeg ? AppColors.success : AppColors.error, width: 1.5), borderRadius: BorderRadius.circular(4)),
                        child: Container(width: 8, height: 8, decoration: BoxDecoration(color: food.isVeg ? AppColors.success : AppColors.error, shape: BoxShape.circle))),
                      const SizedBox(width: 6),
                      Expanded(child: Text(food.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                    const SizedBox(height: 4),
                    Text(food.description, style: TextStyle(fontSize: 12, color: subColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('₹${food.price.toInt()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      Builder(
                        builder: (context) {
                          final isClosedOrPaused = restaurant.status == RestaurantStatus.closed || restaurant.status == RestaurantStatus.temporarilyClosed;
                          
                          if (isClosedOrPaused) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.withValues(alpha: 0.35), width: 1.2),
                              ),
                              child: const Text(
                                'CLOSED',
                                style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            );
                          }

                          final cartState = ref.watch(cartProvider);
                          final cartItemIndex = cartState.items.indexWhere((item) => item.food.id == food.id);
                          final isInCart = cartItemIndex != -1;

                          if (isInCart) {
                            final quantity = cartState.items[cartItemIndex].quantity;
                            return Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.primary, width: 1.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      ref.read(cartProvider.notifier).decrementQuantity(food.id);
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Icon(Icons.remove, color: AppColors.primary, size: 16),
                                    ),
                                  ),
                                  Text(
                                    '$quantity',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      ref.read(cartProvider.notifier).incrementQuantity(food.id);
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Icon(Icons.add, color: AppColors.primary, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return GestureDetector(
                            onTap: () {
                              if (food.addons.isNotEmpty) {
                                context.push('/food-details/${food.id}');
                              } else {
                                ref.read(cartProvider.notifier).addItem(food, 1, []);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: const Text('Added to cart!'), backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  duration: const Duration(seconds: 2),
                                  action: SnackBarAction(label: 'VIEW CART', textColor: Colors.white, onPressed: () => context.push('/cart')),
                                ));
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                              child: const Text('ADD', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                            ),
                          );
                        }
                      ),
                    ]),
                  ])),
                ]),
              ),
            ).animate().fadeIn(delay: (i * 80).ms, duration: 350.ms);
          }, childCount: foods.length)),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ]),
    );
  });
  });
  }

  Widget _infoItem(IconData icon, String value, String label, Color textColor, Color subColor) {
    return Column(children: [
      Icon(icon, color: AppColors.primary, size: 22),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textColor)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 11, color: subColor)),
    ]);
  }
}
