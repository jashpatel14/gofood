import '../api/dio_client.dart';
import '../models/address_model.dart';

class AddressApi {
  final _dio = DioClient.instance;

  Future<List<AddressModel>> getAddresses() async {
    final response = await _dio.get('/addresses');
    final List data = response.data;
    return data.map((json) => AddressModel.fromJson(json)).toList();
  }

  Future<AddressModel> createAddress(Map<String, dynamic> data) async {
    final response = await _dio.post('/addresses', data: data);
    return AddressModel.fromJson(response.data);
  }

  Future<AddressModel> updateAddress(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/addresses/$id', data: data);
    return AddressModel.fromJson(response.data);
  }

  Future<void> deleteAddress(String id) async {
    await _dio.delete('/addresses/$id');
  }
}
