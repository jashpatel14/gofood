import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/restaurant_status.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.fontSize = 11,
  });

  factory StatusBadge.open() => const StatusBadge(text: 'OPEN', color: AppColors.success);
  factory StatusBadge.closed() => const StatusBadge(text: 'CLOSED', color: AppColors.error);
  factory StatusBadge.veg() => const StatusBadge(text: 'VEG', color: AppColors.success);
  factory StatusBadge.nonVeg() => const StatusBadge(text: 'NON-VEG', color: AppColors.error);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class RestaurantStatusBadge extends StatelessWidget {
  final RestaurantStatus status;
  final double fontSize;

  const RestaurantStatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case RestaurantStatus.open:
        color = Colors.green;
        text = 'Open';
        icon = Icons.check_circle_outline;
        break;
      case RestaurantStatus.closingSoon:
        color = Colors.orange;
        text = 'Closing Soon';
        icon = Icons.warning_amber_rounded;
        break;
      case RestaurantStatus.busy:
        color = Colors.deepPurple;
        text = 'Busy';
        icon = Icons.bolt;
        break;
      case RestaurantStatus.temporarilyClosed:
        color = Colors.grey;
        text = 'Temporarily Closed';
        icon = Icons.pause_circle_outline;
        break;
      case RestaurantStatus.closed:
        color = Colors.red;
        text = 'Closed';
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: fontSize + 3),
          const SizedBox(width: 4),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class RatingBadge extends StatelessWidget {
  final double rating;
  final double size;

  const RatingBadge({super.key, required this.rating, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.white, size: size),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: Colors.white,
              fontSize: size - 1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
