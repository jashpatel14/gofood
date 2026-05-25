import '../api/dio_client.dart';
import '../models/restaurant_model.dart';

class RestaurantApi {
  final _dio = DioClient.instance;

  Future<List<RestaurantModel>> getRestaurants() async {
    final response = await _dio.get('/restaurants');
    final List data = response.data;
    return data.map((json) => RestaurantModel.fromJson(json)).toList();
  }

  Future<RestaurantModel> getRestaurantById(String id) async {
    final response = await _dio.get('/restaurants/$id');
    return RestaurantModel.fromJson(response.data);
  }

  Future<List<RestaurantModel>> searchRestaurants(String query) async {
    final response = await _dio.get('/restaurants/search', queryParams: {'q': query});
    final List data = response.data;
    return data.map((json) => RestaurantModel.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> submitReview(String restaurantId, double rating, String comment, String orderId) async {
    final response = await _dio.post('/restaurants/$restaurantId/reviews', data: {
      'rating': rating,
      'comment': comment,
      'order_id': orderId,
    });
    return response.data;
  }
}
