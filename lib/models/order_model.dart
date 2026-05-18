enum OrderStatus {
  pending('Pending', 'Your order has been placed'),
  accepted('Accepted', 'Restaurant accepted your order'),
  preparing('Preparing', 'Your food is being prepared'),
  outForDelivery('Out for Delivery', 'Rider is on the way'),
  delivered('Delivered', 'Order delivered successfully');

  final String label;
  final String description;
  const OrderStatus(this.label, this.description);
}

class OrderItemModel {
  final String foodId;
  final String foodName;
  final String foodImage;
  final double price;
  final int quantity;
  final double totalPrice;

  const OrderItemModel({
    required this.foodId,
    required this.foodName,
    required this.foodImage,
    required this.price,
    required this.quantity,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      foodId: json['food_id']?.toString() ?? '',
      foodName: json['food_name'] ?? '',
      foodImage: json['food_image'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: json['quantity'] ?? 1,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_id': foodId,
      'food_name': foodName,
      'food_image': foodImage,
      'price': price,
      'quantity': quantity,
      'total_price': totalPrice,
    };
  }
}

class OrderModel {
  final String id;
  final List<OrderItemModel> items;
  final double subtotal;
  final double gst;
  final double deliveryFee;
  final double discount;
  final double totalAmount;
  final OrderStatus status;
  final String paymentMethod;
  final String deliveryAddress;
  final DateTime createdAt;
  final String? estimatedDelivery;

  const OrderModel({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.gst,
    required this.deliveryFee,
    this.discount = 0,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.createdAt,
    this.estimatedDelivery,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      items: (json['items'] as List?)
              ?.map((e) => OrderItemModel.fromJson(e))
              .toList() ??
          [],
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      gst: double.tryParse(json['gst']?.toString() ?? '0') ?? 0.0,
      deliveryFee: double.tryParse(json['delivery_fee']?.toString() ?? '0') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      status: OrderStatus.values.firstWhere(
        (s) => s.name == (json['status'] ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      paymentMethod: json['payment_method'] ?? 'Cash on Delivery',
      deliveryAddress: json['delivery_address'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      estimatedDelivery: json['estimated_delivery'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'gst': gst,
      'delivery_fee': deliveryFee,
      'discount': discount,
      'total_amount': totalAmount,
      'status': status.name,
      'payment_method': paymentMethod,
      'delivery_address': deliveryAddress,
      'created_at': createdAt.toIso8601String(),
      'estimated_delivery': estimatedDelivery,
    };
  }
}
