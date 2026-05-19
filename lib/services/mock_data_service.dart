import 'package:flutter/material.dart';
import '../models/restaurant_model.dart';
import '../models/food_model.dart';
import '../models/category_model.dart';
import '../models/address_model.dart';
import '../models/order_model.dart';

class MockData {
  // ── Categories ────────────────────────────────────────
  static const List<CategoryModel> categories = [
    CategoryModel(id: '1', name: 'Burger', icon: Icons.lunch_dining),
    CategoryModel(id: '2', name: 'Pizza', icon: Icons.local_pizza),
    CategoryModel(id: '3', name: 'Biryani', icon: Icons.rice_bowl),
    CategoryModel(id: '4', name: 'Chinese', icon: Icons.ramen_dining),
    CategoryModel(id: '5', name: 'Dessert', icon: Icons.icecream),
    CategoryModel(id: '6', name: 'Drinks', icon: Icons.local_cafe),
    CategoryModel(id: '7', name: 'Thali', icon: Icons.dinner_dining),
    CategoryModel(id: '8', name: 'Rolls', icon: Icons.kebab_dining),
  ];

  // ── Restaurants ───────────────────────────────────────
  static const List<RestaurantModel> restaurants = [
    RestaurantModel(
      id: '1',
      name: 'Royal Biryani House',
      image: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600',
      rating: 4.5,
      reviewCount: 324,
      deliveryTime: '25-35 min',
      cuisineType: 'Biryani • Mughlai • North Indian',
      isOpen: true,
      address: 'MG Road, Bangalore',
      distance: 2.5,
    ),
    RestaurantModel(
      id: '2',
      name: 'Pizza Paradise',
      image: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600',
      rating: 4.7,
      reviewCount: 512,
      deliveryTime: '20-30 min',
      cuisineType: 'Pizza • Italian • Pasta',
      isOpen: true,
      address: 'Koramangala, Bangalore',
      distance: 1.8,
    ),
    RestaurantModel(
      id: '3',
      name: 'Dragon Wok',
      image: 'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=600',
      rating: 4.3,
      reviewCount: 267,
      deliveryTime: '30-40 min',
      cuisineType: 'Chinese • Thai • Asian',
      isOpen: true,
      address: 'Indiranagar, Bangalore',
      distance: 3.2,
    ),
    RestaurantModel(
      id: '4',
      name: 'Burger Junction',
      image: 'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?w=600',
      rating: 4.6,
      reviewCount: 445,
      deliveryTime: '15-25 min',
      cuisineType: 'Burger • American • Fast Food',
      isOpen: true,
      address: 'HSR Layout, Bangalore',
      distance: 1.2,
    ),
    RestaurantModel(
      id: '5',
      name: 'South Spice',
      image: 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=600',
      rating: 4.4,
      reviewCount: 198,
      deliveryTime: '20-30 min',
      cuisineType: 'South Indian • Dosa • Idli',
      isOpen: false,
      address: 'Jayanagar, Bangalore',
      distance: 4.0,
    ),
    RestaurantModel(
      id: '6',
      name: 'Dessert Haven',
      image: 'https://images.unsplash.com/photo-1559329007-40df8a9345d8?w=600',
      rating: 4.8,
      reviewCount: 678,
      deliveryTime: '25-35 min',
      cuisineType: 'Desserts • Ice Cream • Cakes',
      isOpen: true,
      address: 'Whitefield, Bangalore',
      distance: 5.5,
    ),
    RestaurantModel(
      id: '7',
      name: 'Tandoori Nights',
      image: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600',
      rating: 4.2,
      reviewCount: 156,
      deliveryTime: '35-45 min',
      cuisineType: 'Tandoori • North Indian • Kebab',
      isOpen: true,
      address: 'Electronic City, Bangalore',
      distance: 6.0,
    ),
    RestaurantModel(
      id: '8',
      name: 'Wrap & Roll',
      image: 'https://images.unsplash.com/photo-1537047902294-62a40c20a6ae?w=600',
      rating: 4.1,
      reviewCount: 89,
      deliveryTime: '15-20 min',
      cuisineType: 'Rolls • Wraps • Kebabs',
      isOpen: true,
      address: 'BTM Layout, Bangalore',
      distance: 1.5,
    ),
  ];

  // ── Foods ─────────────────────────────────────────────
  static List<FoodModel> foods = [
    // Restaurant 1 - Royal Biryani House
    FoodModel(
      id: '1', name: 'Hyderabadi Chicken Biryani',
      image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600',
      description: 'Aromatic basmati rice layered with tender chicken, saffron, and traditional Hyderabadi spices. Slow-cooked to perfection.',
      price: 299, rating: 4.6, restaurantId: '1', restaurantName: 'Royal Biryani House',
      category: 'Biryani', isVeg: false, isPopular: true,
      addons: [
        AddonModel(id: 'a1', name: 'Extra Raita', price: 30),
        AddonModel(id: 'a2', name: 'Boiled Egg', price: 20),
        AddonModel(id: 'a3', name: 'Extra Chicken', price: 80),
        AddonModel(id: 'a4', name: 'Salan Gravy', price: 40),
      ],
    ),
    FoodModel(
      id: '2', name: 'Mutton Biryani Special',
      image: 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=600',
      description: 'Premium mutton pieces cooked with fragrant rice, whole spices, and topped with crispy fried onions.',
      price: 399, rating: 4.8, restaurantId: '1', restaurantName: 'Royal Biryani House',
      category: 'Biryani', isVeg: false, isPopular: true,
      addons: [
        AddonModel(id: 'a5', name: 'Extra Raita', price: 30),
        AddonModel(id: 'a6', name: 'Extra Mutton', price: 120),
      ],
    ),
    FoodModel(
      id: '3', name: 'Paneer Biryani',
      image: 'https://images.unsplash.com/photo-1645177628172-a94c1f96e6db?w=600',
      description: 'Cottage cheese cubes with flavored rice, mint, and aromatic spices. A vegetarian delight.',
      price: 249, rating: 4.3, restaurantId: '1', restaurantName: 'Royal Biryani House',
      category: 'Biryani', isVeg: true,
      addons: [
        AddonModel(id: 'a7', name: 'Extra Paneer', price: 60),
        AddonModel(id: 'a8', name: 'Raita', price: 30),
      ],
    ),
    FoodModel(
      id: '4', name: 'Chicken 65',
      image: 'https://images.unsplash.com/photo-1610057099443-fde6c99db9e1?w=600',
      description: 'Crispy deep-fried chicken marinated in red chilli paste and curry leaves. Spicy and crunchy.',
      price: 229, rating: 4.5, restaurantId: '1', restaurantName: 'Royal Biryani House',
      category: 'Starters', isVeg: false,
      addons: [
        AddonModel(id: 'a9', name: 'Extra Portion', price: 100),
      ],
    ),

    // Restaurant 2 - Pizza Paradise
    FoodModel(
      id: '5', name: 'Margherita Pizza',
      image: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=600',
      description: 'Classic Italian pizza with fresh mozzarella, San Marzano tomato sauce, and basil leaves.',
      price: 349, rating: 4.7, restaurantId: '2', restaurantName: 'Pizza Paradise',
      category: 'Pizza', isVeg: true, isPopular: true,
      addons: [
        AddonModel(id: 'a10', name: 'Extra Cheese', price: 50),
        AddonModel(id: 'a11', name: 'Olives', price: 30),
        AddonModel(id: 'a12', name: 'Jalapenos', price: 25),
        AddonModel(id: 'a13', name: 'Mushroom', price: 40),
      ],
    ),
    FoodModel(
      id: '6', name: 'Pepperoni Pizza',
      image: 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=600',
      description: 'Loaded with spicy pepperoni, melted mozzarella, and our signature pizza sauce.',
      price: 449, rating: 4.8, restaurantId: '2', restaurantName: 'Pizza Paradise',
      category: 'Pizza', isVeg: false, isPopular: true,
      addons: [
        AddonModel(id: 'a14', name: 'Extra Cheese', price: 50),
        AddonModel(id: 'a15', name: 'Stuffed Crust', price: 70),
      ],
    ),
    FoodModel(
      id: '7', name: 'Pasta Alfredo',
      image: 'https://images.unsplash.com/photo-1645112411341-6c4fd023714a?w=600',
      description: 'Creamy white sauce pasta with parmesan, garlic, and fresh herbs.',
      price: 279, rating: 4.4, restaurantId: '2', restaurantName: 'Pizza Paradise',
      category: 'Pasta', isVeg: true,
      addons: [
        AddonModel(id: 'a16', name: 'Grilled Chicken', price: 80),
        AddonModel(id: 'a17', name: 'Garlic Bread', price: 60),
      ],
    ),
    FoodModel(
      id: '8', name: 'Garlic Bread',
      image: 'https://images.unsplash.com/photo-1619535860434-ba1d8fa12536?w=600',
      description: 'Crispy bread brushed with garlic butter and topped with herbs and cheese.',
      price: 149, rating: 4.3, restaurantId: '2', restaurantName: 'Pizza Paradise',
      category: 'Starters', isVeg: true,
      addons: [
        AddonModel(id: 'a18', name: 'Extra Cheese', price: 40),
      ],
    ),

    // Restaurant 3 - Dragon Wok
    FoodModel(
      id: '9', name: 'Chicken Manchurian',
      image: 'https://images.unsplash.com/photo-1525755662778-989d0524087e?w=600',
      description: 'Crispy chicken balls tossed in spicy Manchurian sauce with spring onions.',
      price: 259, rating: 4.4, restaurantId: '3', restaurantName: 'Dragon Wok',
      category: 'Chinese', isVeg: false, isPopular: true,
      addons: [
        AddonModel(id: 'a19', name: 'Fried Rice', price: 90),
        AddonModel(id: 'a20', name: 'Noodles', price: 90),
      ],
    ),
    FoodModel(
      id: '10', name: 'Veg Hakka Noodles',
      image: 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=600',
      description: 'Stir-fried noodles with fresh vegetables, soy sauce, and Asian spices.',
      price: 199, rating: 4.2, restaurantId: '3', restaurantName: 'Dragon Wok',
      category: 'Chinese', isVeg: true,
      addons: [
        AddonModel(id: 'a21', name: 'Egg', price: 20),
        AddonModel(id: 'a22', name: 'Paneer', price: 50),
      ],
    ),
    FoodModel(
      id: '11', name: 'Dragon Roll Sushi',
      image: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=600',
      description: 'Fresh sushi rolls with avocado, cucumber, and spicy mayo drizzle.',
      price: 399, rating: 4.6, restaurantId: '3', restaurantName: 'Dragon Wok',
      category: 'Chinese', isVeg: false,
      addons: [
        AddonModel(id: 'a23', name: 'Wasabi', price: 20),
        AddonModel(id: 'a24', name: 'Soy Sauce', price: 10),
      ],
    ),

    // Restaurant 4 - Burger Junction
    FoodModel(
      id: '12', name: 'Classic Smash Burger',
      image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600',
      description: 'Double smashed beef patty with cheddar cheese, pickles, and secret sauce.',
      price: 279, rating: 4.7, restaurantId: '4', restaurantName: 'Burger Junction',
      category: 'Burger', isVeg: false, isPopular: true,
      addons: [
        AddonModel(id: 'a25', name: 'Extra Patty', price: 100),
        AddonModel(id: 'a26', name: 'Bacon', price: 60),
        AddonModel(id: 'a27', name: 'Fries', price: 80),
        AddonModel(id: 'a28', name: 'Coleslaw', price: 40),
      ],
    ),
    FoodModel(
      id: '13', name: 'Paneer Tikka Burger',
      image: 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=600',
      description: 'Grilled paneer tikka patty with mint mayo, onion rings, and fresh lettuce.',
      price: 229, rating: 4.5, restaurantId: '4', restaurantName: 'Burger Junction',
      category: 'Burger', isVeg: true, isPopular: true,
      addons: [
        AddonModel(id: 'a29', name: 'Extra Cheese', price: 40),
        AddonModel(id: 'a30', name: 'Fries', price: 80),
      ],
    ),
    FoodModel(
      id: '14', name: 'Loaded Fries',
      image: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600',
      description: 'Crispy golden fries loaded with cheese sauce, jalapeños, and sour cream.',
      price: 179, rating: 4.3, restaurantId: '4', restaurantName: 'Burger Junction',
      category: 'Sides', isVeg: true,
      addons: [
        AddonModel(id: 'a31', name: 'Extra Cheese', price: 40),
      ],
    ),

    // Restaurant 6 - Dessert Haven
    FoodModel(
      id: '15', name: 'Belgian Chocolate Cake',
      image: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600',
      description: 'Rich and moist chocolate cake with Belgian chocolate ganache frosting.',
      price: 349, rating: 4.9, restaurantId: '6', restaurantName: 'Dessert Haven',
      category: 'Dessert', isVeg: true, isPopular: true,
      addons: [
        AddonModel(id: 'a32', name: 'Whipped Cream', price: 30),
        AddonModel(id: 'a33', name: 'Ice Cream Scoop', price: 50),
      ],
    ),
    FoodModel(
      id: '16', name: 'Mango Cheesecake',
      image: 'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?w=600',
      description: 'Creamy cheesecake with fresh Alphonso mango puree and biscuit crust.',
      price: 299, rating: 4.7, restaurantId: '6', restaurantName: 'Dessert Haven',
      category: 'Dessert', isVeg: true,
      addons: [
        AddonModel(id: 'a34', name: 'Extra Mango', price: 40),
      ],
    ),
    FoodModel(
      id: '17', name: 'Cold Coffee Frappe',
      image: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=600',
      description: 'Chilled coffee blended with ice cream, milk, and chocolate syrup.',
      price: 199, rating: 4.5, restaurantId: '6', restaurantName: 'Dessert Haven',
      category: 'Drinks', isVeg: true,
      addons: [
        AddonModel(id: 'a35', name: 'Whipped Cream', price: 25),
        AddonModel(id: 'a36', name: 'Extra Shot', price: 30),
      ],
    ),

    // Restaurant 7 - Tandoori Nights
    FoodModel(
      id: '18', name: 'Butter Chicken',
      image: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=600',
      description: 'Tender chicken in rich tomato-butter gravy. Best served with naan or rice.',
      price: 329, rating: 4.6, restaurantId: '7', restaurantName: 'Tandoori Nights',
      category: 'Main Course', isVeg: false, isPopular: true,
      addons: [
        AddonModel(id: 'a37', name: 'Butter Naan', price: 40),
        AddonModel(id: 'a38', name: 'Jeera Rice', price: 60),
        AddonModel(id: 'a39', name: 'Raita', price: 30),
      ],
    ),
    FoodModel(
      id: '19', name: 'Paneer Tikka',
      image: 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=600',
      description: 'Grilled cottage cheese marinated in yogurt and tandoori spices. Served with mint chutney.',
      price: 249, rating: 4.4, restaurantId: '7', restaurantName: 'Tandoori Nights',
      category: 'Starters', isVeg: true,
      addons: [
        AddonModel(id: 'a40', name: 'Extra Portion', price: 80),
      ],
    ),
    FoodModel(
      id: '20', name: 'Dal Makhani',
      image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600',
      description: 'Slow-cooked black lentils in creamy tomato-butter gravy. Rich and flavorful.',
      price: 199, rating: 4.5, restaurantId: '7', restaurantName: 'Tandoori Nights',
      category: 'Main Course', isVeg: true,
      addons: [
        AddonModel(id: 'a41', name: 'Butter Naan', price: 40),
        AddonModel(id: 'a42', name: 'Jeera Rice', price: 60),
      ],
    ),

    // Restaurant 8 - Wrap & Roll
    FoodModel(
      id: '21', name: 'Chicken Shawarma Roll',
      image: 'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=600',
      description: 'Juicy chicken shawarma wrapped in warm pita with garlic sauce and pickles.',
      price: 179, rating: 4.3, restaurantId: '8', restaurantName: 'Wrap & Roll',
      category: 'Rolls', isVeg: false, isPopular: true,
      addons: [
        AddonModel(id: 'a43', name: 'Extra Sauce', price: 15),
        AddonModel(id: 'a44', name: 'Cheese', price: 30),
      ],
    ),
    FoodModel(
      id: '22', name: 'Paneer Kathi Roll',
      image: 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=600',
      description: 'Spiced paneer tikka rolled in flaky paratha with onions and green chutney.',
      price: 159, rating: 4.2, restaurantId: '8', restaurantName: 'Wrap & Roll',
      category: 'Rolls', isVeg: true,
      addons: [
        AddonModel(id: 'a45', name: 'Extra Paneer', price: 40),
        AddonModel(id: 'a46', name: 'Cheese', price: 30),
      ],
    ),
  ];

  // ── Banner Data ───────────────────────────────────────
  static const List<Map<String, String>> banners = [
    {
      'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
      'title': '50% OFF',
      'subtitle': 'On Your First Order',
      'targetType': 'offer',
      'targetId': 'FIRST50',
    },
    {
      'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
      'title': 'Pizza Paradise',
      'subtitle': 'Free Delivery on Pizza Feast',
      'targetType': 'restaurant',
      'targetId': '2',
    },
    {
      'image': 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=800',
      'title': 'Special Biryani',
      'subtitle': 'Hot & Spicy Hyderabadi Biryani',
      'targetType': 'food',
      'targetId': '1',
    },
    {
      'image': 'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?w=800',
      'title': 'Burger Craze',
      'subtitle': 'Delicious Smothered Burgers',
      'targetType': 'restaurant',
      'targetId': '4',
    },
  ];

  static const List<AddressModel> addresses = [];

  // ── Coupon Codes ──────────────────────────────────────
  static const Map<String, double> coupons = {
    'FIRST50': 50.0,
    'GOFOOD20': 20.0,
    'SAVE30': 30.0,
    'FLAT100': 100.0,
    'WELCOME': 40.0,
  };

  // ── Sample Orders ─────────────────────────────────────
  static List<OrderModel> sampleOrders = [
    OrderModel(
      id: 'ORD-1001',
      items: [
        const OrderItemModel(
          foodId: '1', foodName: 'Hyderabadi Chicken Biryani',
          foodImage: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600',
          price: 299, quantity: 2, totalPrice: 598,
        ),
        const OrderItemModel(
          foodId: '4', foodName: 'Chicken 65',
          foodImage: 'https://images.unsplash.com/photo-1610057099443-fde6c99db9e1?w=600',
          price: 229, quantity: 1, totalPrice: 229,
        ),
      ],
      subtotal: 827, gst: 41.35, deliveryFee: 40, totalAmount: 908.35,
      status: OrderStatus.delivered,
      paymentMethod: 'Cash on Delivery',
      deliveryAddress: '221B Baker Street, Koramangala',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    OrderModel(
      id: 'ORD-1002',
      items: [
        const OrderItemModel(
          foodId: '5', foodName: 'Margherita Pizza',
          foodImage: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=600',
          price: 349, quantity: 1, totalPrice: 349,
        ),
      ],
      subtotal: 349, gst: 17.45, deliveryFee: 40, totalAmount: 406.45,
      status: OrderStatus.preparing,
      paymentMethod: 'Online Payment',
      deliveryAddress: '42 Tech Park, Electronic City Phase 1',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      estimatedDelivery: '25 min',
    ),
    OrderModel(
      id: 'ORD-1003',
      items: [
        const OrderItemModel(
          foodId: '12', foodName: 'Classic Smash Burger',
          foodImage: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600',
          price: 279, quantity: 2, totalPrice: 558,
        ),
        const OrderItemModel(
          foodId: '14', foodName: 'Loaded Fries',
          foodImage: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600',
          price: 179, quantity: 1, totalPrice: 179,
        ),
      ],
      subtotal: 737, gst: 36.85, deliveryFee: 0, discount: 50, totalAmount: 723.85,
      status: OrderStatus.delivered,
      paymentMethod: 'Cash on Delivery',
      deliveryAddress: '221B Baker Street, Koramangala',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  // ── Helper Methods ────────────────────────────────────
  static List<FoodModel> getPopularFoods() {
    return foods.where((f) => f.isPopular).toList();
  }

  static List<FoodModel> getFoodsByRestaurant(String restaurantId) {
    return foods.where((f) => f.restaurantId == restaurantId).toList();
  }

  static List<FoodModel> getFoodsByCategory(String category) {
    return foods.where((f) => f.category.toLowerCase() == category.toLowerCase()).toList();
  }

  static List<FoodModel> searchFoods(String query) {
    final q = query.toLowerCase();
    return foods.where((f) =>
      f.name.toLowerCase().contains(q) ||
      f.description.toLowerCase().contains(q) ||
      f.category.toLowerCase().contains(q)
    ).toList();
  }

  static List<RestaurantModel> searchRestaurants(String query) {
    final q = query.toLowerCase();
    return restaurants.where((r) =>
      r.name.toLowerCase().contains(q) ||
      r.cuisineType.toLowerCase().contains(q)
    ).toList();
  }

  static FoodModel? getFoodById(String id) {
    try {
      return foods.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  static RestaurantModel? getRestaurantById(String id) {
    try {
      return restaurants.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  static double? applyCoupon(String code) {
    return coupons[code.toUpperCase()];
  }
}
