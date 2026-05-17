import 'package:flutter/foundation.dart';

/// Error handling and logging utilities for the GoFood application

class GoFoodException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  GoFoodException({required this.message, this.code, this.originalError});

  @override
  String toString() =>
      'GoFoodException: $message${code != null ? ' (Code: $code)' : ''}';
}

class NetworkException extends GoFoodException {
  NetworkException({
    required super.message,
    super.code = 'NETWORK_ERROR',
    super.originalError,
  });
}

class ValidationException extends GoFoodException {
  ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
  });
}

class AuthenticationException extends GoFoodException {
  AuthenticationException({required super.message, super.code = 'AUTH_ERROR'});
}

/// Logging utility for debugging
class Logger {
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[INFO] $message');
      if (error != null) print('  Error: $error');
      if (stackTrace != null) print('  StackTrace: $stackTrace');
    }
  }

  static void warning(String message, [dynamic error]) {
    if (kDebugMode) {
      print('[WARNING] $message');
      if (error != null) print('  Error: $error');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[ERROR] $message');
      if (error != null) print('  Error: $error');
      if (stackTrace != null) print('  StackTrace: $stackTrace');
    }
  }

  static void debug(String message, [dynamic data]) {
    if (kDebugMode) {
      print('[DEBUG] $message');
      if (data != null) print('  Data: $data');
    }
  }
}

/// Validator utility for form validations
class FormValidator {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^\d{10}$');

    if (!phoneRegex.hasMatch(value.replaceAll('-', ''))) {
      return 'Please enter a valid 10-digit phone number';
    }

    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }

    if (value.length < 5) {
      return 'Address must be at least 5 characters';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }
}

/// Utility for common operations
class AppUtils {
  /// Format currency
  static String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// Parse currency string
  static double? parseCurrency(String value) {
    try {
      return double.parse(value.replaceAll('\$', ''));
    } catch (e) {
      Logger.error('Failed to parse currency: $value', e);
      return null;
    }
  }

  /// Format time remaining
  static String formatTimeRemaining(int minutes) {
    if (minutes < 60) {
      return '$minutes mins';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  /// Calculate delivery fee based on distance
  static double calculateDeliveryFee(double distanceInKm) {
    if (distanceInKm <= 2) return 2.0;
    if (distanceInKm <= 5) return 3.5;
    if (distanceInKm <= 10) return 5.0;
    return 5.0 + ((distanceInKm - 10) * 0.5);
  }

  /// Calculate GST (5%)
  static double calculateGST(double subtotal) {
    return subtotal * 0.05;
  }

  /// Calculate total with all fees
  static double calculateTotal({
    required double subtotal,
    required double deliveryFee,
    double gstPercentage = 0.05,
  }) {
    final gst = subtotal * gstPercentage;
    return subtotal + gst + deliveryFee;
  }

  /// Check if string is empty or null
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Get initials from name
  static String getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, 1).toUpperCase();
  }
}
