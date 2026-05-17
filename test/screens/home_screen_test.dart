import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gofood/main.dart';

void main() {
  group('Home Screen Tests', () {
    testWidgets('Home screen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: GoFoodApp()));

      // Navigate to home screen
      await tester.pumpAndSettle();

      // Verify home screen elements
      expect(find.text('Deliver To'), findsOneWidget);
      expect(find.text('New York, USA'), findsOneWidget);
      expect(find.text('Search food or restaurant'), findsOneWidget);
    });

    testWidgets('Home screen has categories', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: GoFoodApp()));
      await tester.pumpAndSettle();

      // Verify categories are displayed
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Burger'), findsOneWidget);
      expect(find.text('Pizza'), findsOneWidget);
      expect(find.text('Drinks'), findsOneWidget);
      expect(find.text('Dessert'), findsOneWidget);
    });

    testWidgets('Home screen has popular restaurants', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: GoFoodApp()));
      await tester.pumpAndSettle();

      // Verify restaurants section
      expect(find.text('Popular Restaurants'), findsOneWidget);
      expect(find.text('Italian Pizza Restaurant'), findsWidgets);
    });

    testWidgets('Search bar is functional', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: GoFoodApp()));
      await tester.pumpAndSettle();

      // Find and interact with search field
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.tap(searchField);
      await tester.enterText(searchField, 'Pizza');
      expect(find.text('Pizza'), findsWidgets);
    });

    testWidgets('Bottom navigation is present', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: GoFoodApp()));
      await tester.pumpAndSettle();

      // Verify bottom navigation bar exists
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Cart'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });
  });
}
