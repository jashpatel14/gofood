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
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      isSelected: json['is_selected'] == null ? false : (json['is_selected'] == 1 || json['is_selected'] == true),
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
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      restaurantId: json['restaurant_id']?.toString() ?? '',
      restaurantName: json['restaurant_name'] ?? '',
      category: json['category'] ?? '',
      isVeg: json['is_veg'] == null ? true : (json['is_veg'] == 1 || json['is_veg'] == true),
      isPopular: json['is_popular'] == null ? false : (json['is_popular'] == 1 || json['is_popular'] == true),
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
