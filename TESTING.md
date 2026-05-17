# GoFood - Food Delivery App

A Flutter application for food ordering and delivery management.

## Project Structure

```
lib/
├── main.dart                          # Entry point
├── core/
│   └── theme/
│       └── app_theme.dart            # Theme configuration
├── routes/
│   └── app_router.dart               # Route definitions
└── screens/
    ├── auth/
    │   └── login_screen.dart         # Login screen
    ├── home/
    │   └── home_screen.dart          # Main home screen
    ├── restaurant/
    │   └── restaurant_details_screen.dart
    ├── food/
    │   └── food_details_screen.dart
    ├── cart/
    │   └── cart_screen.dart          # Shopping cart
    ├── checkout/
    │   └── checkout_screen.dart      # Checkout process
    ├── orders/
    │   └── orders_screen.dart        # Order history
    ├── profile/
    │   └── profile_screen.dart       # User profile
    ├── navigation/
    │   └── main_navigation_screen.dart # Main navigation
    ├── splash/
    │   └── splash_screen.dart        # Splash screen
    └── order/
        └── order_success_screen.dart # Order confirmation
```

## Getting Started

### Prerequisites
- Flutter 3.11.5 or higher
- Dart 3.11.5 or higher

### Installation

1. **Clone or setup the project**
```bash
cd gofood
```

2. **Get dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

## Dependencies

- **flutter_riverpod**: State management
- **go_router**: Routing and navigation
- **dio**: HTTP client for API calls
- **carousel_slider**: Image carousel
- **lottie**: Animations
- **cached_network_image**: Network image caching
- **google_fonts**: Google Fonts integration
- **flutter_screenutil**: Responsive design
- **shimmer**: Loading shimmer effect
- **shared_preferences**: Local storage

## Running Tests

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/widget_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage
```

### Run tests in release mode
```bash
flutter test --release
```

## Test Files

The project includes the following test files:

1. **test/widget_test.dart** - Main app tests
   - App initialization
   - Splash screen navigation
   - Login flow
   - Login form validation

2. **test/screens/home_screen_test.dart** - Home screen tests
   - Home screen display
   - Categories display
   - Popular restaurants
   - Search functionality
   - Bottom navigation

3. **test/screens/cart_screen_test.dart** - Cart screen tests
   - Cart display
   - Quantity management
   - Bill calculation
   - Checkout navigation

4. **test/screens/checkout_screen_test.dart** - Checkout tests
   - Checkout display
   - Address display
   - Payment method selection
   - Order summary
   - Place order functionality

## Features

### ✅ Implemented
- Splash screen with animations
- User login flow
- Home screen with restaurants and food items
- Restaurant details view
- Food details with quantity selection
- Shopping cart with bill calculation
- Checkout with payment method selection
- Order success confirmation
- Order history
- User profile
- Proper routing with GoRouter
- Responsive UI with ScreenUtil

### 🔄 Navigation Flow
1. Splash Screen (3 seconds)
2. Login Screen
3. Main Navigation (Home/Orders/Profile)
4. Restaurant Details
5. Food Details
6. Shopping Cart
7. Checkout
8. Order Success

## Error Fixes Applied

✅ Fixed missing import: `carousel_slider`
✅ Fixed incomplete `home_screen.dart`
✅ Updated routes in `app_router.dart` with all screens
✅ Converted Navigator usage to GoRouter
✅ Added proper error handling in router
✅ Fixed navigation consistency across app
✅ Added comprehensive test coverage
✅ Fixed asset configuration in pubspec.yaml

## Building for Production

### Build APK (Android)
```bash
flutter build apk --release
```

### Build iOS
```bash
flutter build ios --release
```

### Build Web
```bash
flutter build web --release
```

## Troubleshooting

### Issue: Lottie animation not showing
**Solution**: Ensure `assets/animations/success.json` exists

### Issue: Images not loading
**Solution**: Images are loaded from Unsplash URLs, ensure internet connectivity

### Issue: Routes not working
**Solution**: Ensure GoRouter is properly configured in main.dart

### Issue: Tests failing
**Solution**: Run `flutter clean && flutter pub get && flutter test`

## Code Quality

- All screens follow Material Design 3
- Consistent naming conventions
- Proper widget composition
- Error handling in navigation
- Testable code structure
- No unused imports
- Proper state management with StatefulWidget

## Future Improvements

- Add state management with Riverpod
- Implement API integration with Dio
- Add user authentication
- Implement local database with Hive/Sqflite
- Add payment gateway integration
- Add push notifications
- Add order tracking with real-time updates
- Add reviews and ratings
- Add wishlist/favorites
- Add multilingual support

## License

This project is private and not licensed for public distribution.

## Support

For issues and questions, please contact the development team.
