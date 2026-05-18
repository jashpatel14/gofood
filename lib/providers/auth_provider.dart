import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  AuthNotifier() : super(const AuthState());

  final _authApi = AuthApi();

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(isLoading: false, error: 'Please fill all fields');
      return false;
    }

    try {
      final user = await _authApi.login(email, password);
      state = AuthState(user: user, isAuthenticated: true, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Login failed. Please try again.');
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
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Registration failed. Please try again.');
      return false;
    }
  }

  Future<void> logout() async {
    final userId = state.user?.id?.toString();
    DioClient.instance.clearToken();
    state = const AuthState();
    
    // Clear all local storage data to prevent leaking data to next user
    final prefs = await SharedPreferences.getInstance();
    // Remove specific user data keys instead of everything (so theme is preserved)
    if (userId != null) {
      await prefs.remove('user_addresses_$userId');
    }
    await prefs.remove('user_addresses');
    // Note: tokenKey, userKey etc are probably handled elsewhere, but clear them too if they exist
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }
}
