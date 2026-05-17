import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gofood/main.dart';

void main() {
  group('GoFood App Tests', () {
    testWidgets('App initializes and shows splash screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: GoFoodApp()));
      await tester.pumpAndSettle();

      // Check if splash screen is displayed
      expect(find.byIcon(Icons.fastfood), findsOneWidget);
      expect(find.text('GoFood'), findsWidgets);
    });

    testWidgets('Splash screen navigates to login', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: GoFoodApp()));

      // Wait for 4 seconds (splash duration is 3 + 1 for safety)
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Verify that login screen appears
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Login to continue'), findsOneWidget);
    });

    testWidgets('Login button is visible and functional', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: GoFoodApp()));
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Check if login button exists
      expect(find.text('Login'), findsOneWidget);

      // Tap the login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Check if navigation occurred
      expect(find.text('Welcome Back'), findsNothing);
    });

    testWidgets('Login form has required fields', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: GoFoodApp()));
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Verify email and password text fields
      expect(find.byType(TextField), findsWidgets);
    });
  });
}
