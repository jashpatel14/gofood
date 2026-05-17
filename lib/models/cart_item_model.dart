import 'food_model.dart';

class CartItemModel {
  final FoodModel food;
  int quantity;
  final List<AddonModel> selectedAddons;

  CartItemModel({
    required this.food,
    this.quantity = 1,
    this.selectedAddons = const [],
  });

  double get itemPrice {
    double addonTotal = 0;
    for (final addon in selectedAddons) {
      addonTotal += addon.price;
    }
    return (food.price + addonTotal) * quantity;
  }

  CartItemModel copyWith({
    FoodModel? food,
    int? quantity,
    List<AddonModel>? selectedAddons,
  }) {
    return CartItemModel(
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
      selectedAddons: selectedAddons ?? this.selectedAddons,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_id': food.id,
      'food_name': food.name,
      'food_image': food.image,
      'price': food.price,
      'quantity': quantity,
      'addons': selectedAddons.map((a) => a.toJson()).toList(),
      'total_price': itemPrice,
    };
  }
}
