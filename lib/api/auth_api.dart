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

  Future<UserModel> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String avatarUrl,
  }) async {
    final response = await _dio.put('/auth/profile', data: {
      'name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
    });
    return UserModel.fromJson(response.data);
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post('/auth/forgot-password', data: {
      'email': email,
    });
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await _dio.post('/auth/reset-password', data: {
      'token': token,
      'password': newPassword,
    });
  }
}
