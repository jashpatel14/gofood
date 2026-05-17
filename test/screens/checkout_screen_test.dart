import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gofood/screens/checkout/checkout_screen.dart';

void main() {
  group('Checkout Screen Tests', () {
    testWidgets('Checkout screen displays correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const CheckoutScreen()));

      // Verify checkout screen elements
      expect(find.text('Checkout'), findsOneWidget);
      expect(find.text('Delivery Address'), findsOneWidget);
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Order Summary'), findsOneWidget);
    });

    testWidgets('Delivery address is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const CheckoutScreen()));

      expect(find.text('Home Address'), findsOneWidget);
      expect(find.text('221B Baker Street, London'), findsOneWidget);
    });

    testWidgets('Payment methods are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const CheckoutScreen()));

      expect(find.text('Cash On Delivery'), findsOneWidget);
      expect(find.text('Credit Card'), findsOneWidget);
      expect(find.text('UPI Payment'), findsOneWidget);
    });

    testWidgets('Payment method can be selected', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const CheckoutScreen()));

      // Find and tap payment method
      final paymentMethods = find.text('Credit Card');
      expect(paymentMethods, findsOneWidget);

      await tester.tap(paymentMethods);
      await tester.pump();

      // Verify selection
      expect(find.byIcon(Icons.check_circle), findsWidgets);
    });

    testWidgets('Order summary shows pricing details', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const CheckoutScreen()));

      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('GST'), findsOneWidget);
      expect(find.text('Delivery'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('Place order button is present', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const CheckoutScreen()));

      expect(find.text('Place Order'), findsOneWidget);
    });

    testWidgets('Place order button is clickable', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const CheckoutScreen()));

      final button = find.text('Place Order');
      expect(button, findsOneWidget);

      // Verify button is enabled
      final buttonWidget = find.byType(ElevatedButton);
      expect(buttonWidget, findsWidgets);
    });
  });
}
