# GoFood Developer Guide

## Quick Start

### Get the project running in 3 steps:
```bash
flutter pub get
flutter run
```

---

## File Structure Guide

### Core Files
- `lib/main.dart` - App entry point (Don't modify routing here, use app_router.dart)
- `lib/routes/app_router.dart` - All route definitions
- `lib/core/theme/app_theme.dart` - App theme, colors, typography
- `lib/core/utils/app_utils.dart` - Utility functions and validators

### Screen Files
Each screen should be a StatelessWidget or StatefulWidget with proper imports:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Other imports...

class ScreenName extends StatelessWidget {
  const ScreenName({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Title')),
      body: Center(child: Text('Content')),
    );
  }
}
```

---

## Navigation Guide

### Use GoRouter (NOT Navigator)

❌ **Don't do this:**
```dart
Navigator.push(context, MaterialPageRoute(builder: (_) => NextScreen()));
```

✅ **Do this instead:**
```dart
context.push('/next-screen');
```

### Common Navigation Patterns

**Push (keep previous screen in stack):**
```dart
context.push('/restaurant');
```

**Replace (remove current screen from stack):**
```dart
context.pushReplacement('/order-success');
```

**Go (pop to root then navigate):**
```dart
context.go('/home');
```

**Go with named route:**
```dart
context.goNamed('/profile');
```

---

## Validation Guide

Use `FormValidator` utility for common validations:

```dart
import 'package:gofood/core/utils/app_utils.dart';

// Email validation
String? emailError = FormValidator.validateEmail(emailValue);
if (emailError != null) {
  print(emailError); // "Please enter a valid email"
}

// Password validation
String? passwordError = FormValidator.validatePassword(passwordValue);

// Phone validation
String? phoneError = FormValidator.validatePhoneNumber(phoneValue);

// Address validation
String? addressError = FormValidator.validateAddress(addressValue);

// Name validation
String? nameError = FormValidator.validateName(nameValue);
```

---

## Utility Functions Guide

### Currency Operations
```dart
import 'package:gofood/core/utils/app_utils.dart';

// Format to currency
String formatted = AppUtils.formatCurrency(25.99); // "\$25.99"

// Parse from currency
double amount = AppUtils.parseCurrency('\$25.99'); // 25.99
```

### Calculations
```dart
// Delivery fee based on distance
double fee = AppUtils.calculateDeliveryFee(3.5); // $3.50

// Calculate GST
double gst = AppUtils.calculateGST(100); // 5.0

// Calculate total with all fees
double total = AppUtils.calculateTotal(
  subtotal: 100.0,
  deliveryFee: 5.0,
);
```

### String Utilities
```dart
// Check if empty/null
if (AppUtils.isNullOrEmpty(name)) {
  print('Name is required');
}

// Get initials from name
String initials = AppUtils.getInitials('John Doe'); // "JD"
```

### Time Formatting
```dart
String time = AppUtils.formatTimeRemaining(45); // "45 mins"
String time2 = AppUtils.formatTimeRemaining(90); // "1h 30m"
```

---

## Error Handling Guide

### Using Custom Exceptions

```dart
import 'package:gofood/core/utils/app_utils.dart';

try {
  // Some operation
} on NetworkException catch (e) {
  print('Network error: ${e.message}');
} on ValidationException catch (e) {
  print('Validation error: ${e.message}');
} on GoFoodException catch (e) {
  print('Error: ${e.message}');
}
```

### Throwing Exceptions

```dart
// Network error
throw NetworkException(
  message: 'Failed to fetch restaurants',
  code: 'FETCH_ERROR',
);

// Validation error
throw ValidationException(
  message: 'Email format is invalid',
);

// Auth error
throw AuthenticationException(
  message: 'Login failed',
);
```

---

## Logging Guide

```dart
import 'package:gofood/core/utils/app_utils.dart';

// Info level
Logger.info('User logged in');

// Warning level
Logger.warning('Slow network detected');

// Error level
Logger.error('Failed to process order', exception);

// Debug level
Logger.debug('Response data', {'status': 200, 'data': []});
```

---

## Testing Guide

### Run Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage report
flutter test --coverage

# Run tests in verbose mode
flutter test -v
```

### Write a New Test
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Feature Tests', () {
    testWidgets('Feature works correctly', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(const MyWidget());

      // Verify elements
      expect(find.text('Expected Text'), findsOneWidget);

      // Interact with widget
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify after interaction
      expect(find.text('Updated Text'), findsOneWidget);
    });
  });
}
```

---

## Adding a New Screen

1. **Create screen file**: `lib/screens/[feature]/[feature]_screen.dart`

2. **Add route**: In `lib/routes/app_router.dart`:
```dart
GoRoute(
  path: '/feature',
  builder: (context, state) => const FeatureScreen(),
),
```

3. **Create test file**: `test/screens/[feature]_screen_test.dart`

4. **Import in other screens** if needed for navigation:
```dart
context.push('/feature');
```

---

## Code Style Guidelines

### Widget Naming
- Screen files: `*_screen.dart`
- Widget files: `*_widget.dart`
- Model files: `*_model.dart`

### Class Naming
- Screens: `FeatureScreen`
- Exceptions: `FeatureException`
- Services: `FeatureService`
- Utilities: `FeatureUtil`

### Variable Naming
```dart
// Good
final userName = 'John';
final isLoading = true;
final _privateVariable = 42;

// Bad
final userName_1 = 'John';
final CONSTANT = true;
final is_loading = true;
```

### Code Formatting
```bash
# Format code
dart format lib/

# Analyze code
dart analyze
```

---

## Common Issues & Solutions

### Issue: Route not found error
**Solution**: Check that the route path in GoRouter matches the navigation call
```dart
// In router
GoRoute(path: '/restaurant', builder: ...)

// In screen
context.push('/restaurant'); // ✅ Correct

context.push('/restaurants'); // ❌ Wrong - extra 's'
```

### Issue: Lottie animation not showing
**Solution**: Ensure file exists at `assets/animations/success.json`

### Issue: Image not loading
**Solution**: Check internet connection (app uses Unsplash URLs)

### Issue: Tests failing
**Solution**: Run `flutter clean && flutter pub get && flutter test`

---

## Debugging Tips

### Enable verbose logging
```bash
flutter run -v
```

### Use DevTools
```bash
flutter pub global activate devtools
devtools
```

### Add breakpoints
- Click on line number in VS Code editor
- Run with `flutter run`
- Breakpoint will pause execution

---

## Deployment

### Android Build
```bash
flutter build apk --release
# Output: build/app/outputs/apk/release/app-release.apk
```

### iOS Build
```bash
flutter build ios --release
# Output: build/ios/iphoneos/Runner.app
```

### Web Build
```bash
flutter build web --release
# Output: build/web/
```

---

## Performance Tips

1. Use `const` constructor whenever possible
2. Avoid rebuilding entire tree - use `setState` carefully
3. Use `ListView.builder()` instead of `ListView()` for long lists
4. Cache network images with `cached_network_image`
5. Use `RepaintBoundary` for expensive widgets
6. Profile with DevTools for performance issues

---

## Useful Links

- [Flutter Documentation](https://flutter.dev/docs)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Flutter Testing Guide](https://flutter.dev/docs/testing)
- [Material Design 3](https://m3.material.io/)

---

## Contact & Support

For questions or issues:
1. Check TESTING.md for test guidance
2. Check FIXES_SUMMARY.md for applied fixes
3. Review existing code in `lib/screens/` for patterns
4. Check test files in `test/` for examples

---

Last Updated: 2024
