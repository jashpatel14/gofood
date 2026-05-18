import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/address_model.dart';
import '../services/storage/address_storage_service.dart';
import '../api/address_api.dart';
import 'auth_provider.dart';

final addressApiProvider = Provider((ref) => AddressApi());
final addressStorageProvider = Provider((ref) => AddressStorageService());

final addressProvider = StateNotifierProvider<AddressNotifier, List<AddressModel>>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.user?.id?.toString() ?? 'guest';
  return AddressNotifier(
    ref.watch(addressApiProvider),
    ref.watch(addressStorageProvider),
    userId,
  );
});

class AddressNotifier extends StateNotifier<List<AddressModel>> {
  final AddressApi _api;
  final AddressStorageService _storage;
  final String _userId;
  final _uuid = const Uuid();

  AddressNotifier(this._api, this._storage, this._userId) : super([]) {
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final addresses = await _api.getAddresses();
      state = addresses;
      await _storage.saveAddresses(_userId, addresses);
    } catch (e) {
      final addresses = await _storage.getAddresses(_userId);
      state = addresses;
    }
  }

  Future<void> addAddress(AddressModel address) async {
    final isFirst = state.isEmpty;
    final newAddress = address.copyWith(
      id: _uuid.v4(),
      isDefault: address.isDefault || isFirst,
    );
    
    var newState = [...state, newAddress];
    
    if (newAddress.isDefault && !isFirst) {
      newState = newState.map((e) => e.id == newAddress.id ? e : e.copyWith(isDefault: false)).toList();
    }
    
    state = newState;
    await _storage.saveAddresses(_userId, state);

    try {
      await _api.createAddress(newAddress.toJsonForApi());
    } catch (e) {
      print('API Error adding address: $e');
    }
  }

  Future<void> updateAddress(AddressModel address) async {
    var newState = state.map((e) => e.id == address.id ? address : e).toList();
    
    if (address.isDefault) {
      newState = newState.map((e) => e.id == address.id ? e : e.copyWith(isDefault: false)).toList();
    }
    
    state = newState;
    await _storage.saveAddresses(_userId, state);

    try {
      await _api.updateAddress(address.id, address.toJsonForApi());
    } catch (e) {
      print('API Error updating address: $e');
    }
  }

  Future<void> deleteAddress(String id) async {
    final addressToDelete = state.firstWhere((e) => e.id == id, orElse: () => state.first);
    var newState = state.where((e) => e.id != id).toList();
    
    if (addressToDelete.isDefault && newState.isNotEmpty) {
      newState[0] = newState[0].copyWith(isDefault: true);
    }
    
    state = newState;
    await _storage.saveAddresses(_userId, state);

    try {
      await _api.deleteAddress(id);
    } catch (e) {
      print('API Error deleting address: $e');
    }
  }

  Future<void> setDefaultAddress(String id) async {
    final newState = state.map((e) => e.copyWith(isDefault: e.id == id)).toList();
    state = newState;
    await _storage.saveAddresses(_userId, state);

    try {
      final address = state.firstWhere((e) => e.id == id);
      await _api.updateAddress(id, address.toJsonForApi());
    } catch (e) {
      print('API Error setting default address: $e');
    }
  }

  AddressModel? get defaultAddress {
    if (state.isEmpty) return null;
    try {
      return state.firstWhere((e) => e.isDefault);
    } catch (_) {
      return state.first;
    }
  }
}
