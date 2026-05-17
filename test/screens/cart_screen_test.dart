import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gofood/screens/cart/cart_screen.dart';

void main() {
  group('Cart Screen Tests', () {
    testWidgets('Cart screen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const CartScreen()));

      // Verify cart screen elements
      expect(find.text('My Cart'), findsOneWidget);
      expect(find.text('Cheese Pizza'), findsOneWidget);
      expect(find.text('\$12.99'), findsOneWidget);
    });

    testWidgets('Quantity can be increased', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const CartScreen()));

      // Find and tap add button
      final addButtons = find.byIcon(Icons.add);
      expect(addButtons, findsWidgets);

      await tester.tap(addButtons.first);
      await tester.pump();

      // Verify quantity updated
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('Quantity can be decreased', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const CartScreen()));

      // First increase quantity
      final addButtons = find.byIcon(Icons.add);
      await tester.tap(addButtons.first);
      await tester.pump();

      // Then decrease
      final removeButtons = find.byIcon(Icons.remove);
      await tester.tap(removeButtons.first);
      await tester.pump();

      // Should be back to 1
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Bill details are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const CartScreen()));

      // Verify bill details
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('GST (5%)'), findsOneWidget);
      expect(find.text('Delivery Fee'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('Checkout button is present', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const CartScreen()));

      expect(find.text('Proceed To Checkout'), findsOneWidget);
    });

    testWidgets('Delete button is present', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const CartScreen()));

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });
  });
}
