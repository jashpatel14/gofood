import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/restaurant_model.dart';
import '../../models/restaurant_status.dart';
import '../../providers/cart_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/network_image_widget.dart';
import '../navigation/main_navigation_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});
  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _couponController = TextEditingController();

  @override
  void dispose() { _couponController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = ref.watch(cartProvider);
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;

    final restaurantsAsync = ref.watch(restaurantListProvider);
    final restaurants = restaurantsAsync.value ?? [];

    bool hasClosedRestaurantItems = false;
    String closedRestaurantName = '';
    if (restaurants.isNotEmpty) {
      for (final item in cart.items) {
        RestaurantModel? rest;
        for (final r in restaurants) {
          if (r.id == item.food.restaurantId) {
            rest = r;
            break;
          }
        }
        if (rest != null && (rest.status == RestaurantStatus.closed || rest.status == RestaurantStatus.temporarilyClosed)) {
          hasClosedRestaurantItems = true;
          closedRestaurantName = rest.name;
          break;
        }
      }
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(title: Text('My Cart (${cart.totalItems})')),
      body: cart.isEmpty
        ? EmptyStateWidget(icon: Icons.shopping_cart_outlined, title: 'Your cart is empty', subtitle: 'Browse restaurants and add delicious food to your cart!',
            buttonText: 'Browse Restaurants', onButtonPressed: () {
              ref.read(navigationIndexProvider.notifier).state = 0;
              context.go('/navigation');
            })
        : Column(children: [
          Expanded(child: SingleChildScrollView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(16), child: Column(children: [
            if (hasClosedRestaurantItems)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.25), width: 1.2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ordering is disabled because "$closedRestaurantName" is currently closed. Please remove these items to proceed.',
                        style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ).animate().shake(duration: 400.ms),
            // Cart Items
            ...List.generate(cart.items.length, (i) {
              final item = cart.items[i];
              return Dismissible(
                key: Key(item.food.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => ref.read(cartProvider.notifier).removeItem(item.food.id),
                background: Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
                  alignment: Alignment.centerRight, child: const Icon(Icons.delete_outline, color: Colors.white, size: 28)),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), boxShadow: isDark ? null : AppColors.cardShadow),
                  child: Row(children: [
                    NetworkImageWidget(imageUrl: item.food.image, width: 90, height: 90, borderRadius: 14),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.food.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (item.selectedAddons.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(item.selectedAddons.map((a) => a.name).join(', '), style: TextStyle(fontSize: 11, color: subColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('₹${item.itemPrice.toInt()}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(10)),
                          child: Row(children: [
                            _qtyBtn(Icons.remove, () => ref.read(cartProvider.notifier).decrementQuantity(item.food.id)),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('${item.quantity}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor))),
                            _qtyBtn(Icons.add, () => ref.read(cartProvider.notifier).incrementQuantity(item.food.id)),
                          ])),
                      ]),
                    ])),
                  ]),
                ),
              ).animate().fadeIn(delay: (i * 80).ms, duration: 300.ms);
            }),

            const SizedBox(height: 10),

            // Coupon
            Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), boxShadow: isDark ? null : AppColors.cardShadow),
              child: cart.appliedCoupon != null
                ? Padding(padding: const EdgeInsets.all(14), child: Row(children: [
                    const Icon(Icons.local_offer, color: AppColors.success, size: 22),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(cart.appliedCoupon!, style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
                      Text('₹${cart.discount.toInt()} discount applied', style: const TextStyle(fontSize: 12, color: AppColors.success)),
                    ])),
                    IconButton(onPressed: () => ref.read(cartProvider.notifier).removeCoupon(), icon: const Icon(Icons.close, color: AppColors.error, size: 20)),
                  ]))
                : Row(children: [
                    Expanded(child: TextField(controller: _couponController,
                      decoration: InputDecoration(hintText: 'Enter coupon code', hintStyle: TextStyle(fontSize: 14, color: subColor), prefixIcon: const Icon(Icons.local_offer_outlined, color: AppColors.primary, size: 20),
                        border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)))),
                    Padding(padding: const EdgeInsets.only(right: 6), child: ElevatedButton(
                      onPressed: () {
                        final err = ref.read(cartProvider.notifier).applyCoupon(_couponController.text.trim());
                        if (err != null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                        } else { _couponController.clear(); }
                      },
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Apply', style: TextStyle(fontSize: 14)))),
                  ])),

            const SizedBox(height: 18),

            // Bill
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), boxShadow: isDark ? null : AppColors.cardShadow),
              child: Column(children: [
                Text('Bill Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
                const SizedBox(height: 16),
                _billRow('Subtotal', '₹${cart.subtotal.toStringAsFixed(2)}', textColor, subColor),
                const SizedBox(height: 10),
                _billRow('GST (5%)', '₹${cart.gst.toStringAsFixed(2)}', textColor, subColor),
                const SizedBox(height: 10),
                _billRow('Delivery Fee', cart.deliveryFee == 0 ? 'FREE' : '₹${cart.deliveryFee.toStringAsFixed(2)}', textColor, subColor, valueColor: cart.deliveryFee == 0 ? AppColors.success : null),
                if (cart.discount > 0) ...[
                  const SizedBox(height: 10),
                  _billRow('Discount', '-₹${cart.discount.toStringAsFixed(2)}', textColor, subColor, valueColor: AppColors.success),
                ],
                Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Divider(color: isDark ? AppColors.darkDivider : AppColors.divider)),
                _billRow('Total', '₹${cart.total.toStringAsFixed(2)}', textColor, subColor, isBold: true),
                if (cart.subtotal < 500) ...[
                  const SizedBox(height: 10),
                  Text('Add ₹${(500 - cart.subtotal).toInt()} more for free delivery!', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
                ],
              ])),
          ]))),

          // Checkout Button
          Container(padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(color: cardColor, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))]),
            child: SafeArea(
              child: CustomButton(
                text: hasClosedRestaurantItems 
                    ? 'Restaurant is Closed' 
                    : 'Proceed To Checkout  •  ₹${cart.total.toStringAsFixed(0)}',
                onPressed: hasClosedRestaurantItems ? null : () => context.push('/checkout'),
              ),
            )),
        ]),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: Colors.white, size: 16)));
  }

  Widget _billRow(String title, String value, Color textColor, Color subColor, {bool isBold = false, Color? valueColor}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400, color: isBold ? textColor : subColor)),
      Text(value, style: TextStyle(fontSize: isBold ? 18 : 14, fontWeight: isBold ? FontWeight.w800 : FontWeight.w500, color: valueColor ?? (isBold ? AppColors.primary : textColor))),
    ]);
  }
}
