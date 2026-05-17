import '../api/dio_client.dart';
import '../models/food_model.dart';

class FoodApi {
  final _dio = DioClient.instance;

  Future<List<FoodModel>> getFoods({String? restaurantId, String? category}) async {
    final params = <String, dynamic>{};
    if (restaurantId != null) params['restaurant_id'] = restaurantId;
    if (category != null) params['category'] = category;
    final response = await _dio.get('/foods', queryParams: params);
    final List data = response.data;
    return data.map((json) => FoodModel.fromJson(json)).toList();
  }

  Future<List<FoodModel>> getPopularFoods() async {
    final response = await _dio.get('/foods/popular');
    final List data = response.data;
    return data.map((json) => FoodModel.fromJson(json)).toList();
  }

  Future<FoodModel> getFoodById(String id) async {
    final response = await _dio.get('/foods/$id');
    return FoodModel.fromJson(response.data);
  }

  Future<List<FoodModel>> searchFoods(String query) async {
    final response = await _dio.get('/foods/search', queryParams: {'q': query});
    final List data = response.data;
    return data.map((json) => FoodModel.fromJson(json)).toList();
  }
}
