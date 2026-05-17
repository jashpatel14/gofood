class AddressModel {
  final String id;
  final String label;
  final String fullAddress;
  final String city;
  final String pincode;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.label,
    required this.fullAddress,
    this.city = '',
    this.pincode = '',
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      label: json['label'] ?? '',
      fullAddress: json['full_address'] ?? '',
      city: json['city'] ?? '',
      pincode: json['pincode'] ?? '',
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'full_address': fullAddress,
      'city': city,
      'pincode': pincode,
      'is_default': isDefault,
    };
  }
}
