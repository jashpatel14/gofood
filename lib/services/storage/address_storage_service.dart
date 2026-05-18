import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/address_model.dart';

class AddressStorageService {
  String _getKey(String userId) => 'user_addresses_$userId';

  Future<void> saveAddresses(String userId, List<AddressModel> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(addresses.map((e) => e.toJson()).toList());
    await prefs.setString(_getKey(userId), data);
  }

  Future<List<AddressModel>> getAddresses(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_getKey(userId));
    if (data == null) return [];
    
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => AddressModel.fromJson(e)).toList();
  }
}
