import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/order_api.dart';
import '../models/order_model.dart';
import '../services/mock_data_service.dart';

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier();
});

class OrderState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? error;

  const OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  List<OrderModel> get activeOrders =>
      orders.where((o) => o.status != OrderStatus.delivered).toList();

  List<OrderModel> get pastOrders =>
      orders.where((o) => o.status == OrderStatus.delivered).toList();

  OrderState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  OrderNotifier() : super(const OrderState()) {
    _loadOrders();
  }

  final _orderApi = OrderApi();

  Future<void> _loadOrders() async {
    state = state.copyWith(isLoading: true);
    try {
      final orders = await _orderApi.getOrders();
      state = OrderState(orders: orders);
    } catch (_) {
      // Fallback to mock data
      state = OrderState(orders: MockData.sampleOrders);
    }
  }

  Future<OrderModel> placeOrder({
    required List<OrderItemModel> items,
    required double subtotal,
    required double gst,
    required double deliveryFee,
    required double discount,
    required double totalAmount,
    required String paymentMethod,
    required String deliveryAddress,
  }) async {
    state = state.copyWith(isLoading: true);

    final orderData = {
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'gst': gst,
      'delivery_fee': deliveryFee,
      'discount': discount,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'delivery_address': deliveryAddress,
    };

    String orderId;
    try {
      final result = await _orderApi.placeOrder(orderData);
      orderId = result['id'] ?? 'ORD-${1004 + state.orders.length}';
    } catch (_) {
      orderId = 'ORD-${1004 + state.orders.length}';
    }

    final order = OrderModel(
      id: orderId,
      items: items,
      subtotal: subtotal,
      gst: gst,
      deliveryFee: deliveryFee,
      discount: discount,
      totalAmount: totalAmount,
      status: OrderStatus.pending,
      paymentMethod: paymentMethod,
      deliveryAddress: deliveryAddress,
      createdAt: DateTime.now(),
      estimatedDelivery: '30-40 min',
    );

    state = OrderState(orders: [order, ...state.orders]);
    return order;
  }

  OrderModel? getOrderById(String id) {
    try {
      return state.orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }
}
