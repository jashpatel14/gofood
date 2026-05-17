import '../api/dio_client.dart';
import '../models/order_model.dart';

class OrderApi {
  final _dio = DioClient.instance;

  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> orderData) async {
    final response = await _dio.post('/orders', data: orderData);
    return response.data;
  }

  Future<List<OrderModel>> getOrders() async {
    final response = await _dio.get('/orders');
    final List data = response.data;
    return data.map((json) => OrderModel.fromJson(json)).toList();
  }

  Future<OrderModel> getOrderById(String id) async {
    final response = await _dio.get('/orders/$id');
    return OrderModel.fromJson(response.data);
  }
}
