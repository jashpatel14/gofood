import '../api/dio_client.dart';
import '../models/user_model.dart';

class AuthApi {
  final _dio = DioClient.instance;

  Future<UserModel> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final user = UserModel.fromJson(response.data);
    if (user.token != null) {
      _dio.setToken(user.token!);
    }
    return user;
  }

  Future<UserModel> register(String name, String email, String phone, String password) async {
    final response = await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    });
    final user = UserModel.fromJson(response.data);
    if (user.token != null) {
      _dio.setToken(user.token!);
    }
    return user;
  }

  Future<UserModel> getProfile() async {
    final response = await _dio.get('/auth/profile');
    return UserModel.fromJson(response.data);
  }
}
