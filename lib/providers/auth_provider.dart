import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../api/auth_api.dart';
import '../api/dio_client.dart';
import '../models/user_model.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _tryAutoLogin();
  }

  final _authApi = AuthApi();

  Future<void> _tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userDataStr = prefs.getString('user_data');

      if (token != null && userDataStr != null) {
        DioClient.instance.setToken(token);
        final userJson = json.decode(userDataStr);
        final user = UserModel.fromJson(userJson).copyWith(token: token);
        state = AuthState(user: user, isAuthenticated: true, isLoading: false);
      }
    } catch (e) {
      // Fail silently on auto-login failure
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(isLoading: false, error: 'Please fill all fields');
      return false;
    }

    try {
      final user = await _authApi.login(email, password);
      state = AuthState(user: user, isAuthenticated: true, isLoading: false);

      // Persist session
      final prefs = await SharedPreferences.getInstance();
      if (user.token != null) {
        await prefs.setString('auth_token', user.token!);
      }
      await prefs.setString('user_data', json.encode(user.toJson()));
      return true;
    } catch (e) {
      String errorMessage = 'Login failed. Please try again.';
      if (e is DioException) {
        if (e.response?.data != null && e.response?.data is Map) {
          final message = e.response?.data['message'] ?? e.response?.data['error'];
          if (message != null) {
            errorMessage = message.toString();
          }
        } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'Connection timeout. Please check your internet connection.';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'Server unreachable. Please check if backend is running.';
        }
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  Future<bool> register(String name, String email, String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      state = state.copyWith(isLoading: false, error: 'Please fill all fields');
      return false;
    }

    try {
      final user = await _authApi.register(name, email, phone, password);
      state = AuthState(user: user, isAuthenticated: true, isLoading: false);

      // Persist session
      final prefs = await SharedPreferences.getInstance();
      if (user.token != null) {
        await prefs.setString('auth_token', user.token!);
      }
      await prefs.setString('user_data', json.encode(user.toJson()));
      return true;
    } catch (e) {
      String errorMessage = 'Registration failed. Please try again.';
      if (e is DioException) {
        if (e.response?.data != null && e.response?.data is Map) {
          final message = e.response?.data['message'] ?? e.response?.data['error'];
          if (message != null) {
            errorMessage = message.toString();
          }
        } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'Connection timeout. Please check your internet connection.';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'Server unreachable. Please check if backend is running.';
        }
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String avatarUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedUser = await _authApi.updateProfile(
        name: name,
        email: email,
        phone: phone,
        avatarUrl: avatarUrl,
      );
      
      // Retain previous token since update endpoint does not return a new one
      final token = state.user?.token;
      final finalUser = updatedUser.copyWith(token: token);

      state = state.copyWith(user: finalUser, isLoading: false);

      // Update persisted session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(finalUser.toJson()));
      return true;
    } catch (e) {
      String errorMessage = 'Failed to update profile. Please try again.';
      if (e is DioException) {
        if (e.response?.data != null && e.response?.data is Map) {
          final message = e.response?.data['message'] ?? e.response?.data['error'];
          if (message != null) {
            errorMessage = message.toString();
          }
        }
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  Future<void> logout() async {
    final userId = state.user?.id;
    DioClient.instance.clearToken();
    state = const AuthState();
    
    // Clear all local storage data to prevent leaking data to next user
    final prefs = await SharedPreferences.getInstance();
    // Remove specific user data keys instead of everything (so theme is preserved)
    if (userId != null) {
      await prefs.remove('user_addresses_$userId');
    }
    await prefs.remove('user_addresses');
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }
}
