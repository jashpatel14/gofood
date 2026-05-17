class AddonModel {
  final String id;
  final String name;
  final double price;
  bool isSelected;

  AddonModel({
    required this.id,
    required this.name,
    required this.price,
    this.isSelected = false,
  });

  factory AddonModel.fromJson(Map<String, dynamic> json) {
    return AddonModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      isSelected: json['is_selected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'is_selected': isSelected,
    };
  }

  AddonModel copyWith({bool? isSelected}) {
    return AddonModel(
      id: id,
      name: name,
      price: price,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class FoodModel {
  final String id;
  final String name;
  final String image;
  final String description;
  final double price;
  final double rating;
  final String restaurantId;
  final String restaurantName;
  final String category;
  final bool isVeg;
  final bool isPopular;
  final List<AddonModel> addons;

  const FoodModel({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.price,
    this.rating = 0.0,
    required this.restaurantId,
    this.restaurantName = '',
    this.category = '',
    this.isVeg = true,
    this.isPopular = false,
    this.addons = const [],
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      restaurantId: json['restaurant_id']?.toString() ?? '',
      restaurantName: json['restaurant_name'] ?? '',
      category: json['category'] ?? '',
      isVeg: json['is_veg'] ?? true,
      isPopular: json['is_popular'] ?? false,
      addons: (json['addons'] as List?)
              ?.map((e) => AddonModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'price': price,
      'rating': rating,
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'category': category,
      'is_veg': isVeg,
      'is_popular': isPopular,
      'addons': addons.map((e) => e.toJson()).toList(),
    };
  }
}
