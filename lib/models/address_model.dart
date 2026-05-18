class AddressModel {
  final String id;
  final String fullName;
  final String phone;
  final String addressLine;
  final String city;
  final String state;
  final String pincode;
  final String addressType; // 'Home', 'Work', 'Other'
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pincode,
    required this.addressType,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      addressLine: json['addressLine'] as String? ?? json['full_address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      addressType: json['addressType'] as String? ?? json['label'] as String? ?? 'Home',
      isDefault: json['isDefault'] as bool? ?? (json['is_default'] == 1 || json['is_default'] == true),
    );
  }

  Map<String, dynamic> toJsonForApi() {
    return {
      'label': addressType,
      'full_address': '$fullName, $phone, $addressLine, $state',
      'city': city,
      'pincode': pincode,
      'is_default': isDefault ? 1 : 0,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'addressLine': addressLine,
      'city': city,
      'state': state,
      'pincode': pincode,
      'addressType': addressType,
      'isDefault': isDefault,
    };
  }

  AddressModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? addressLine,
    String? city,
    String? state,
    String? pincode,
    String? addressType,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      addressType: addressType ?? this.addressType,
      isDefault: isDefault ?? this.isDefault,
    );
  }
  
  String get fullAddress => '$addressLine, $city, $state - $pincode';
}
