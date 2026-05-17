class AppConstants {
  // API
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_done';

  // Animation Durations
  static const int splashDuration = 3;
  static const int animationDuration = 300;
  static const int pageTransition = 250;

  // Misc
  static const double gstPercentage = 0.05;
  static const double deliveryFee = 40.0;
  static const double freeDeliveryAbove = 500.0;
  static const String currency = '₹';

  // Assets
  static const String successAnimation = 'assets/animations/success.json';
  static const String emptyCartAnimation = 'assets/animations/empty_cart.json';
  static const String deliveryAnimation = 'assets/animations/delivery.json';
  static const String searchAnimation = 'assets/animations/search.json';
}
