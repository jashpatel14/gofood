import 'package:flutter_test/flutter_test.dart';
import 'package:gofood/core/utils/app_utils.dart';

void main() {
  group('AppUtils Tests', () {
    group('Currency Formatting', () {
      test('formatCurrency formats correctly', () {
        expect(AppUtils.formatCurrency(12.50), '\$12.50');
        expect(AppUtils.formatCurrency(100.0), '\$100.00');
        expect(AppUtils.formatCurrency(0.99), '\$0.99');
      });

      test('parseCurrency parses correctly', () {
        expect(AppUtils.parseCurrency('\$12.50'), 12.50);
        expect(AppUtils.parseCurrency('\$100.00'), 100.0);
        expect(AppUtils.parseCurrency('\$0.99'), 0.99);
      });

      test('parseCurrency returns null for invalid input', () {
        expect(AppUtils.parseCurrency('invalid'), null);
        expect(AppUtils.parseCurrency(''), null);
      });
    });

    group('Time Formatting', () {
      test('formatTimeRemaining formats minutes', () {
        expect(AppUtils.formatTimeRemaining(30), '30 mins');
        expect(AppUtils.formatTimeRemaining(45), '45 mins');
      });

      test('formatTimeRemaining formats hours', () {
        expect(AppUtils.formatTimeRemaining(60), '1h 0m');
        expect(AppUtils.formatTimeRemaining(90), '1h 30m');
      });
    });

    group('Delivery Fee Calculation', () {
      test('calculateDeliveryFee for short distance', () {
        expect(AppUtils.calculateDeliveryFee(1.0), 2.0);
        expect(AppUtils.calculateDeliveryFee(2.0), 2.0);
      });

      test('calculateDeliveryFee for medium distance', () {
        expect(AppUtils.calculateDeliveryFee(3.0), 3.5);
        expect(AppUtils.calculateDeliveryFee(5.0), 3.5);
      });

      test('calculateDeliveryFee for long distance', () {
        expect(AppUtils.calculateDeliveryFee(7.0), 5.0);
        expect(AppUtils.calculateDeliveryFee(15.0), 7.5);
      });
    });

    group('GST Calculation', () {
      test('calculateGST calculates 5% tax', () {
        expect(AppUtils.calculateGST(100.0), 5.0);
        expect(AppUtils.calculateGST(200.0), 10.0);
        expect(AppUtils.calculateGST(50.0), 2.5);
      });
    });

    group('Total Calculation', () {
      test('calculateTotal with all fees', () {
        final total = AppUtils.calculateTotal(
          subtotal: 100.0,
          deliveryFee: 5.0,
          gstPercentage: 0.05,
        );
        expect(total, 110.0); // 100 + 5 + (100 * 0.05)
      });

      test('calculateTotal with different percentages', () {
        final total = AppUtils.calculateTotal(
          subtotal: 100.0,
          deliveryFee: 3.0,
          gstPercentage: 0.18, // 18% GST
        );
        expect(total, 121.0); // 100 + 3 + (100 * 0.18)
      });
    });

    group('String Utilities', () {
      test('isNullOrEmpty returns true for null', () {
        expect(AppUtils.isNullOrEmpty(null), true);
      });

      test('isNullOrEmpty returns true for empty string', () {
        expect(AppUtils.isNullOrEmpty(''), true);
        expect(AppUtils.isNullOrEmpty('   '), true);
      });

      test('isNullOrEmpty returns false for valid string', () {
        expect(AppUtils.isNullOrEmpty('hello'), false);
      });

      test('getInitials returns single initial for one name', () {
        expect(AppUtils.getInitials('John'), 'J');
      });

      test('getInitials returns two initials for full name', () {
        expect(AppUtils.getInitials('John Doe'), 'JD');
        expect(AppUtils.getInitials('Jane Smith'), 'JS');
      });
    });
  });

  group('FormValidator Tests', () {
    test('validateEmail validates correct email', () {
      expect(FormValidator.validateEmail('test@example.com'), null);
      expect(FormValidator.validateEmail('user@domain.co.uk'), null);
    });

    test('validateEmail rejects invalid email', () {
      expect(FormValidator.validateEmail('invalid'), isNotNull);
      expect(FormValidator.validateEmail('user@'), isNotNull);
      expect(FormValidator.validateEmail(''), isNotNull);
      expect(FormValidator.validateEmail(null), isNotNull);
    });

    test('validatePassword validates correct password', () {
      expect(FormValidator.validatePassword('password123'), null);
      expect(FormValidator.validatePassword('Test@123'), null);
    });

    test('validatePassword rejects short password', () {
      expect(FormValidator.validatePassword('12345'), isNotNull);
      expect(FormValidator.validatePassword(''), isNotNull);
      expect(FormValidator.validatePassword(null), isNotNull);
    });

    test('validatePhoneNumber validates correct phone', () {
      expect(FormValidator.validatePhoneNumber('9876543210'), null);
      expect(FormValidator.validatePhoneNumber('987-654-3210'), null);
    });

    test('validatePhoneNumber rejects invalid phone', () {
      expect(FormValidator.validatePhoneNumber('123'), isNotNull);
      expect(FormValidator.validatePhoneNumber(''), isNotNull);
      expect(FormValidator.validatePhoneNumber(null), isNotNull);
    });

    test('validateAddress validates correct address', () {
      expect(FormValidator.validateAddress('123 Main Street'), null);
    });

    test('validateAddress rejects short address', () {
      expect(FormValidator.validateAddress('123'), isNotNull);
      expect(FormValidator.validateAddress(''), isNotNull);
    });

    test('validateName validates correct name', () {
      expect(FormValidator.validateName('John'), null);
      expect(FormValidator.validateName('John Doe'), null);
    });

    test('validateName rejects short name', () {
      expect(FormValidator.validateName('J'), isNotNull);
      expect(FormValidator.validateName(''), isNotNull);
    });
  });

  group('Exception Tests', () {
    test('GoFoodException creates with message', () {
      final exception = GoFoodException(message: 'Test error');
      expect(exception.message, 'Test error');
      expect(exception.code, null);
    });

    test('NetworkException creates with code', () {
      final exception = NetworkException(message: 'Connection failed');
      expect(exception.message, 'Connection failed');
      expect(exception.code, 'NETWORK_ERROR');
    });

    test('ValidationException creates properly', () {
      final exception = ValidationException(message: 'Invalid input');
      expect(exception.message, 'Invalid input');
      expect(exception.code, 'VALIDATION_ERROR');
    });

    test('AuthenticationException creates properly', () {
      final exception = AuthenticationException(message: 'Auth failed');
      expect(exception.message, 'Auth failed');
      expect(exception.code, 'AUTH_ERROR');
    });
  });
}
