import 'restaurant_status.dart';
import '../services/restaurant_status_service.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String image;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final String cuisineType;
  final bool isOpen; // Retained for compatibility/fallback
  final String address;
  final double distance;
  final double deliveryFee;
  final String openTime;
  final String closeTime;
  final bool isBusy;
  final bool isTemporarilyClosed;

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
    this.openTime = '09:00',
    this.closeTime = '22:00',
    this.isBusy = false,
    this.isTemporarilyClosed = false,
  });

  /// Calculates the live dynamic status of the restaurant
  RestaurantStatus get status {
    if (isTemporarilyClosed) {
      return RestaurantStatus.temporarilyClosed;
    }
    if (!RestaurantStatusService.isTimeWithinRange(openTime, closeTime)) {
      return RestaurantStatus.closed;
    }
    final minutesLeft = RestaurantStatusService.getMinutesBeforeClose(openTime, closeTime);
    if (minutesLeft > 0 && minutesLeft <= 30) {
      return RestaurantStatus.closingSoon;
    }
    if (isBusy) {
      return RestaurantStatus.busy;
    }
    return RestaurantStatus.open;
  }

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
      openTime: json['open_time'] ?? '09:00',
      closeTime: json['close_time'] ?? '22:00',
      isBusy: json['is_busy'] == null ? false : (json['is_busy'] == 1 || json['is_busy'] == true),
      isTemporarilyClosed: json['is_temporarily_closed'] == null ? false : (json['is_temporarily_closed'] == 1 || json['is_temporarily_closed'] == true),
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
      'open_time': openTime,
      'close_time': closeTime,
      'is_busy': isBusy,
      'is_temporarily_closed': isTemporarilyClosed,
    };
  }
}
