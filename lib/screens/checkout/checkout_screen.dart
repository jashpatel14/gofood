import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/address_provider.dart';
import '../../models/address_model.dart';
import '../../widgets/custom_button.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _selectedPayment = 0;
  bool _isPlacing = false;
  AddressModel? _selectedAddress;

  final _paymentMethods = [
    {'title': 'Cash on Delivery', 'icon': Icons.money, 'subtitle': 'Pay when delivered'},
    {'title': 'Credit / Debit Card', 'icon': Icons.credit_card, 'subtitle': 'Visa, Mastercard, RuPay'},
    {'title': 'UPI Payment', 'icon': Icons.account_balance_wallet, 'subtitle': 'GPay, PhonePe, Paytm'},
  ];

  Future<void> _placeOrder() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;
    setState(() => _isPlacing = true);

    final firstCartItem = cart.items.first;
    final restaurantId = firstCartItem.food.restaurantId;
    final restaurantName = firstCartItem.food.restaurantName;

    final items = cart.items.map((item) => OrderItemModel(
      foodId: item.food.id, foodName: item.food.name, foodImage: item.food.image,
      price: item.food.price, quantity: item.quantity, totalPrice: item.itemPrice,
    )).toList();

    final address = _selectedAddress;
    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a delivery address')));
      setState(() => _isPlacing = false);
      return;
    }

    await ref.read(orderProvider.notifier).placeOrder(
      items: items, subtotal: cart.subtotal, gst: cart.gst, deliveryFee: cart.deliveryFee,
      discount: cart.discount, totalAmount: cart.total,
      paymentMethod: _paymentMethods[_selectedPayment]['title'] as String,
      deliveryAddress: address.fullAddress,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
    );

    ref.read(cartProvider.notifier).clearCart();
    if (mounted) context.pushReplacement('/order-success');
  }

  void _showAddressSelectionBottomSheet(BuildContext context, List<AddressModel> addresses) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : AppColors.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: subColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Delivery Address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/add-address');
                    },
                    icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                    label: const Text('Add New', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (addresses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: [
                        Icon(Icons.location_off_outlined, size: 48, color: subColor.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text('No saved addresses found', style: TextStyle(color: subColor, fontSize: 14)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.push('/add-address');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Add Address', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: addresses.length,
                    itemBuilder: (context, i) {
                      final address = addresses[i];
                      final isSelected = _selectedAddress?.id == address.id;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedAddress = address);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: isDark ? null : AppColors.cardShadow,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (isSelected ? AppColors.primary : subColor).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  address.addressType.toLowerCase() == 'home' ? Icons.home : 
                                  address.addressType.toLowerCase() == 'work' ? Icons.work : Icons.location_on, 
                                  color: isSelected ? AppColors.primary : subColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(address.addressType, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                                    const SizedBox(height: 4),
                                    Text(address.fullAddress, style: TextStyle(fontSize: 12, color: subColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSelected ? AppColors.primary : subColor.withValues(alpha: 0.5),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = ref.watch(cartProvider);
    final addresses = ref.watch(addressProvider);
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;

    // Reset selected address if it was deleted/removed from provider state
    if (_selectedAddress != null && !addresses.any((e) => e.id == _selectedAddress!.id)) {
      _selectedAddress = null;
    }

    // Set default selected address initially
    if (_selectedAddress == null && addresses.isNotEmpty) {
      try {
        _selectedAddress = addresses.firstWhere((e) => e.isDefault);
      } catch (_) {
        _selectedAddress = addresses.first;
      }
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Delivery Address
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Delivery Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
            TextButton(
              onPressed: () => _showAddressSelectionBottomSheet(context, addresses),
              child: const Text('Change', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Builder(
          builder: (context) {
            final address = _selectedAddress;
            if (address == null) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.location_off, color: AppColors.error, size: 32),
                    const SizedBox(height: 12),
                    const Text('No Address Selected', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.push('/manage-addresses'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      child: const Text('Add Address'),
                    ),
                  ],
                ),
              );
            }
            
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary, width: 2),
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(
                      address.addressType.toLowerCase() == 'home' ? Icons.home : 
                      address.addressType.toLowerCase() == 'work' ? Icons.work : Icons.location_on, 
                      color: AppColors.primary, size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(address.addressType, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor)),
                        const SizedBox(height: 3),
                        Text(address.fullAddress, style: TextStyle(fontSize: 13, color: subColor)),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Payment Method
        Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
        const SizedBox(height: 14),
        ...List.generate(_paymentMethods.length, (i) {
          final method = _paymentMethods[i];
          final selected = i == _selectedPayment;
          return GestureDetector(onTap: () => setState(() => _selectedPayment = i),
            child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: selected ? AppColors.primary : Colors.transparent, width: 2),
                boxShadow: isDark ? null : AppColors.cardShadow),
              child: Row(children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(method['icon'] as IconData, color: AppColors.primary, size: 22)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(method['title'] as String, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
                  Text(method['subtitle'] as String, style: TextStyle(fontSize: 12, color: subColor)),
                ])),
                if (selected) const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
              ])));
        }),

        const SizedBox(height: 24),

        // Order Summary
        Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
        const SizedBox(height: 14),
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(18), boxShadow: isDark ? null : AppColors.cardShadow),
          child: Column(children: [
            _row('Subtotal', '₹${cart.subtotal.toStringAsFixed(2)}', textColor, subColor),
            const SizedBox(height: 10),
            _row('GST (5%)', '₹${cart.gst.toStringAsFixed(2)}', textColor, subColor),
            const SizedBox(height: 10),
            _row('Delivery Fee', cart.deliveryFee == 0 ? 'FREE' : '₹${cart.deliveryFee.toStringAsFixed(2)}', textColor, subColor, valueColor: cart.deliveryFee == 0 ? AppColors.success : null),
            if (cart.discount > 0) ...[const SizedBox(height: 10), _row('Discount', '-₹${cart.discount.toStringAsFixed(2)}', textColor, subColor, valueColor: AppColors.success)],
            Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Divider(color: isDark ? AppColors.darkDivider : AppColors.divider)),
            _row('Total', '₹${cart.total.toStringAsFixed(2)}', textColor, subColor, isBold: true),
          ])),

        const SizedBox(height: 30),

        CustomButton(text: 'Place Order', isLoading: _isPlacing, icon: Icons.shopping_bag, onPressed: _placeOrder),
        const SizedBox(height: 20),
      ])),
    );
  }

  Widget _row(String t, String v, Color tc, Color sc, {bool isBold = false, Color? valueColor}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(t, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400, color: isBold ? tc : sc)),
      Text(v, style: TextStyle(fontSize: isBold ? 18 : 14, fontWeight: isBold ? FontWeight.w800 : FontWeight.w500, color: valueColor ?? (isBold ? AppColors.primary : tc))),
    ]);
  }
}
