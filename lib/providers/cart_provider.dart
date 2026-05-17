import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item_model.dart';
import '../models/food_model.dart';
import '../services/mock_data_service.dart';

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

class CartState {
  final List<CartItemModel> items;
  final String? appliedCoupon;
  final double discount;

  const CartState({
    this.items = const [],
    this.appliedCoupon,
    this.discount = 0,
  });

  double get subtotal {
    double total = 0;
    for (final item in items) {
      total += item.itemPrice;
    }
    return total;
  }

  double get gst => subtotal * 0.05;

  double get deliveryFee {
    if (subtotal >= 500) return 0;
    return 40.0;
  }

  double get total => subtotal + gst + deliveryFee - discount;

  int get totalItems {
    int count = 0;
    for (final item in items) {
      count += item.quantity;
    }
    return count;
  }

  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<CartItemModel>? items,
    String? appliedCoupon,
    double? discount,
  }) {
    return CartState(
      items: items ?? this.items,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      discount: discount ?? this.discount,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addItem(FoodModel food, int quantity, List<AddonModel> selectedAddons) {
    final existingIndex = state.items.indexWhere((item) => item.food.id == food.id);

    if (existingIndex >= 0) {
      final updatedItems = [...state.items];
      final existingItem = updatedItems[existingIndex];
      updatedItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItemModel(
            food: food,
            quantity: quantity,
            selectedAddons: selectedAddons,
          ),
        ],
      );
    }
  }

  void removeItem(String foodId) {
    state = state.copyWith(
      items: state.items.where((item) => item.food.id != foodId).toList(),
    );
  }

  void updateQuantity(String foodId, int quantity) {
    if (quantity <= 0) {
      removeItem(foodId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.food.id == foodId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  void incrementQuantity(String foodId) {
    final item = state.items.firstWhere((i) => i.food.id == foodId);
    updateQuantity(foodId, item.quantity + 1);
  }

  void decrementQuantity(String foodId) {
    final item = state.items.firstWhere((i) => i.food.id == foodId);
    updateQuantity(foodId, item.quantity - 1);
  }

  String? applyCoupon(String code) {
    final discountAmount = MockData.applyCoupon(code);
    if (discountAmount != null) {
      state = state.copyWith(
        appliedCoupon: code.toUpperCase(),
        discount: discountAmount,
      );
      return null; // success
    }
    return 'Invalid coupon code';
  }

  void removeCoupon() {
    state = CartState(
      items: state.items,
      appliedCoupon: null,
      discount: 0,
    );
  }

  void clearCart() {
    state = const CartState();
  }
}
