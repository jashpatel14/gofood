import 'package:flutter/material.dart';

class RestaurantStatusService {
  /// Check if the current time falls within openTime and closeTime, supporting overnight timings.
  /// Format of openTime/closeTime: "HH:mm" (e.g., "08:00", "23:00", "04:30")
  static bool isTimeWithinRange(String openStr, String closeStr) {
    try {
      final now = TimeOfDay.fromDateTime(DateTime.now());
      final nowMinutes = now.hour * 60 + now.minute;

      final openParts = openStr.split(':');
      final closeParts = closeStr.split(':');
      
      final openHour = int.parse(openParts[0]);
      final openMin = int.parse(openParts[1]);
      
      final closeHour = int.parse(closeParts[0]);
      final closeMin = int.parse(closeParts[1]);

      final openMinutes = openHour * 60 + openMin;
      final closeMinutes = closeHour * 60 + closeMin;

      if (openMinutes <= closeMinutes) {
        // Same day timing (e.g., 09:00 to 22:00)
        return nowMinutes >= openMinutes && nowMinutes < closeMinutes;
      } else {
        // Overnight timing (e.g., 20:00 to 04:00)
        // It is open if we are past openMinutes (before midnight) OR before closeMinutes (after midnight)
        return nowMinutes >= openMinutes || nowMinutes < closeMinutes;
      }
    } catch (_) {
      // Fallback in case of parse error
      return true; 
    }
  }

  /// Calculates the minutes left before closing. Supports overnight closing.
  static int getMinutesBeforeClose(String openStr, String closeStr) {
    try {
      final now = TimeOfDay.fromDateTime(DateTime.now());
      final nowMinutes = now.hour * 60 + now.minute;

      final openParts = openStr.split(':');
      final closeParts = closeStr.split(':');
      
      final openHour = int.parse(openParts[0]);
      final openMin = int.parse(openParts[1]);
      
      final closeHour = int.parse(closeParts[0]);
      final closeMin = int.parse(closeParts[1]);

      final openMinutes = openHour * 60 + openMin;
      final closeMinutes = closeHour * 60 + closeMin;

      // First verify if we are open
      if (!isTimeWithinRange(openStr, closeStr)) return 0;

      if (openMinutes <= closeMinutes) {
        // Same day: closes at closeMinutes
        return closeMinutes - nowMinutes;
      } else {
        // Overnight: closes next day morning at closeMinutes
        if (nowMinutes >= openMinutes) {
          // We are still in the opening day (before midnight)
          return (1440 - nowMinutes) + closeMinutes;
        } else {
          // We are in the next day morning (after midnight)
          return closeMinutes - nowMinutes;
        }
      }
    } catch (_) {
      return 999;
    }
  }

  /// Format 24 hour string to professional 12 hour AM/PM (e.g. "23:00" -> "11:00 PM")
  static String formatTimeTo12Hour(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final min = int.parse(parts[1]);
      
      final period = hour >= 12 ? 'PM' : 'AM';
      final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final formattedMin = min < 10 ? '0$min' : '$min';
      
      return '$formattedHour:$formattedMin $period';
    } catch (_) {
      return timeStr;
    }
  }
}
