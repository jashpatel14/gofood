class RestaurantModel {
  final String id;
  final String name;
  final String image;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final String cuisineType;
  final bool isOpen;
  final String address;
  final double distance;
  final double deliveryFee;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    this.reviewCount = 0,
    required this.deliveryTime,
    required this.cuisineType,
    this.isOpen = true,
    this.address = '',
    this.distance = 0.0,
    this.deliveryFee = 40.0,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      reviewCount: json['review_count'] ?? 0,
      deliveryTime: json['delivery_time'] ?? '30 min',
      cuisineType: json['cuisine_type'] ?? '',
      isOpen: json['is_open'] == null ? true : (json['is_open'] == 1 || json['is_open'] == true),
      address: json['address'] ?? '',
      distance: double.tryParse(json['distance']?.toString() ?? '0') ?? 0.0,
      deliveryFee: double.tryParse(json['delivery_fee']?.toString() ?? '40') ?? 40.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'rating': rating,
      'review_count': reviewCount,
      'delivery_time': deliveryTime,
      'cuisine_type': cuisineType,
      'is_open': isOpen,
      'address': address,
      'distance': distance,
      'delivery_fee': deliveryFee,
    };
  }
}
