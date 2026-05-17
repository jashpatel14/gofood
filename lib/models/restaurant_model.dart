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
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      deliveryTime: json['delivery_time'] ?? '30 min',
      cuisineType: json['cuisine_type'] ?? '',
      isOpen: json['is_open'] ?? true,
      address: json['address'] ?? '',
      distance: (json['distance'] ?? 0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 40).toDouble(),
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
