import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/order_api.dart';
import '../models/order_model.dart';
import 'auth_provider.dart';

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  ref.watch(authProvider);
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
    loadOrders();
  }

  final _orderApi = OrderApi();

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true);
    try {
      final orders = await _orderApi.getOrders();
      state = OrderState(orders: orders);
    } catch (e) {
      state = OrderState(orders: [], error: e.toString());
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
    String? restaurantId,
    String? restaurantName,
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
      orderId = result['id']?.toString() ?? 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to place order');
      throw Exception('Failed to place order: $e');
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
      restaurantId: restaurantId,
      restaurantName: restaurantName,
    );

    state = OrderState(orders: [order, ...state.orders]);
    return order;
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _orderApi.updateOrderStatus(orderId, status.name);
      
      final updatedOrders = state.orders.map((o) {
        if (o.id == orderId) {
          return OrderModel(
            id: o.id,
            items: o.items,
            subtotal: o.subtotal,
            gst: o.gst,
            deliveryFee: o.deliveryFee,
            discount: o.discount,
            totalAmount: o.totalAmount,
            status: status,
            paymentMethod: o.paymentMethod,
            deliveryAddress: o.deliveryAddress,
            createdAt: o.createdAt,
            estimatedDelivery: o.estimatedDelivery,
            restaurantId: o.restaurantId,
            restaurantName: o.restaurantName,
            isRated: o.isRated,
            userRating: o.userRating,
            userComment: o.userComment,
          );
        }
        return o;
      }).toList();
      
      state = state.copyWith(orders: updatedOrders);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update order status');
      throw Exception('Failed to update status: $e');
    }
  }

  void markOrderAsRated(String orderId, double rating, String comment) {
    final updatedOrders = state.orders.map((o) {
      if (o.id == orderId) {
        return OrderModel(
          id: o.id,
          items: o.items,
          subtotal: o.subtotal,
          gst: o.gst,
          deliveryFee: o.deliveryFee,
          discount: o.discount,
          totalAmount: o.totalAmount,
          status: o.status,
          paymentMethod: o.paymentMethod,
          deliveryAddress: o.deliveryAddress,
          createdAt: o.createdAt,
          estimatedDelivery: o.estimatedDelivery,
          restaurantId: o.restaurantId,
          restaurantName: o.restaurantName,
          isRated: true,
          userRating: rating,
          userComment: comment,
        );
      }
      return o;
    }).toList();
    state = state.copyWith(orders: updatedOrders);
  }

  Future<void> refreshOrder(String orderId) async {
    try {
      final updatedOrder = await _orderApi.getOrderById(orderId);
      final updatedOrders = state.orders.map((o) {
        return o.id == orderId ? updatedOrder : o;
      }).toList();
      state = state.copyWith(orders: updatedOrders);
    } catch (e) {
      print("Failed to refresh order $orderId: $e");
    }
  }

  OrderModel? getOrderById(String id) {
    try {
      return state.orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }
}
