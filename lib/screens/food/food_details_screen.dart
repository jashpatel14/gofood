import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/food_model.dart';
import '../../models/restaurant_status.dart';
import '../../providers/cart_provider.dart';
import '../../providers/food_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/network_image_widget.dart';

class FoodDetailsScreen extends ConsumerStatefulWidget {
  final String foodId;
  const FoodDetailsScreen({super.key, required this.foodId});
  @override
  ConsumerState<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends ConsumerState<FoodDetailsScreen> {
  int _quantity = 1;
  List<AddonModel>? _addons;
  FoodModel? _food;

  void _initAddons(FoodModel food) {
    if (_food?.id != food.id) {
      _food = food;
      _addons = food.addons.map((a) => AddonModel(id: a.id, name: a.name, price: a.price)).toList();
    }
  }

  double get _totalPrice {
    if (_food == null || _addons == null) return 0;
    double addonTotal = 0;
    for (final a in _addons!) {
      if (a.isSelected) addonTotal += a.price;
    }
    return (_food!.price + addonTotal) * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foodAsync = ref.watch(foodDetailProvider(widget.foodId));
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;

    return foodAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary))),
      error: (e, s) => Scaffold(appBar: AppBar(), body: const Center(child: Text('Failed to load food details'))),
      data: (foodData) {
    if (foodData == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Food not found')));
    }
    final food = foodData;
    _initAddons(food);
    final addons = _addons ?? [];

    final restaurantAsync = ref.watch(restaurantDetailProvider(food.restaurantId));
    final restaurant = restaurantAsync.value;
    final isClosedOrPaused = restaurant != null && 
        (restaurant.status == RestaurantStatus.closed || restaurant.status == RestaurantStatus.temporarilyClosed);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: BoxDecoration(color: cardColor,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))]),
        child: SafeArea(
          child: Row(children: [
            Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total', style: TextStyle(fontSize: 12, color: subColor)),
              const SizedBox(height: 2),
              Text('₹${_totalPrice.toInt()}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ]),
            const SizedBox(width: 20),
            Expanded(child: CustomButton(
              text: isClosedOrPaused 
                  ? (restaurant.status == RestaurantStatus.temporarilyClosed ? 'Temporarily Closed' : 'Restaurant is Closed') 
                  : 'Add To Cart', 
              icon: isClosedOrPaused ? Icons.block : Icons.shopping_bag_outlined,
              onPressed: isClosedOrPaused ? null : () {
                final selected = addons.where((a) => a.isSelected).toList();
                ref.read(cartProvider.notifier).addItem(food, _quantity, selected);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Added to cart!'), backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(label: 'VIEW CART', textColor: Colors.white, onPressed: () => context.push('/cart')),
                ));
              },
            )),
          ]),
        ),
      ),
      body: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Hero Image
        Stack(children: [
          NetworkImageWidget(imageUrl: food.image, height: 320, width: double.infinity),
          Container(height: 320, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.center, colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent]))),
          Positioned(top: 50, left: 20, child: CircleAvatar(backgroundColor: Colors.white.withValues(alpha: 0.9),
            child: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back, size: 20)))),
          Positioned(top: 50, right: 20, child: CircleAvatar(backgroundColor: Colors.white.withValues(alpha: 0.9),
            child: IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border, size: 20, color: AppColors.error)))),
        ]).animate().fadeIn(duration: 400.ms),

        // Content
        Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Veg/Non-veg + Name
          Row(children: [
            Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(border: Border.all(color: food.isVeg ? AppColors.success : AppColors.error, width: 2), borderRadius: BorderRadius.circular(4)),
              child: Container(width: 10, height: 10, decoration: BoxDecoration(color: food.isVeg ? AppColors.success : AppColors.error, shape: BoxShape.circle))),
            const SizedBox(width: 8),
            Text(food.isVeg ? 'Vegetarian' : 'Non-Vegetarian', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: food.isVeg ? AppColors.success : AppColors.error)),
          ]),
          const SizedBox(height: 10),
          Text(food.name, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textColor)),
          const SizedBox(height: 6),
          Text(food.restaurantName, style: TextStyle(fontSize: 14, color: subColor)),
          const SizedBox(height: 14),
          Text(food.description, style: TextStyle(fontSize: 15, color: subColor, height: 1.5)),
          const SizedBox(height: 18),

          // Rating & Time
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Row(children: [const Icon(Icons.star, color: AppColors.success, size: 18), const SizedBox(width: 4),
                Text('${food.rating}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.success))])),
            const SizedBox(width: 12),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Row(children: [Icon(Icons.timer, color: AppColors.primary, size: 18), SizedBox(width: 4),
                Text('20 min', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary))])),
          ]),

          const SizedBox(height: 24),

          // Price & Quantity
          Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(18), boxShadow: isDark ? null : AppColors.cardShadow),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Price', style: TextStyle(fontSize: 13, color: subColor)),
                const SizedBox(height: 4),
                Text('₹${food.price.toInt()}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ]),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  _qtyButton(Icons.remove, () { if (_quantity > 1) setState(() => _quantity--); }),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('$_quantity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor))),
                  _qtyButton(Icons.add, () => setState(() => _quantity++)),
                ])),
            ])),

          const SizedBox(height: 24),

          // Addons
          if (addons.isNotEmpty) ...[
            Text('Add-ons & Toppings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
            const SizedBox(height: 14),
            ...List.generate(addons.length, (i) {
              final addon = addons[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: addon.isSelected ? AppColors.primary : (isDark ? AppColors.darkDivider : AppColors.divider), width: addon.isSelected ? 2 : 1)),
                child: Row(children: [
                  Expanded(child: Text(addon.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textColor))),
                  Text('+₹${addon.price.toInt()}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: subColor)),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => setState(() => _addons![i] = addon.copyWith(isSelected: !addon.isSelected)),
                    child: Container(width: 24, height: 24, decoration: BoxDecoration(
                      color: addon.isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: addon.isSelected ? AppColors.primary : subColor, width: 2)),
                      child: addon.isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null),
                  ),
                ]),
              ).animate().fadeIn(delay: (i * 60).ms, duration: 300.ms);
            }),
          ],
        ])),
      ])),
    );
  });
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(onTap: onTap,
      child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.white, size: 20)));
  }
}
