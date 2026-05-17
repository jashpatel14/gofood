import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../models/order_model.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;

    // Simulate order tracking at "Preparing" step
    const currentStep = 2;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(title: Text('Order $orderId')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ETA
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(22)),
          child: Row(children: [
            const Icon(Icons.timer, color: Colors.white, size: 32),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Estimated Delivery', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              const Text('25-30 Minutes', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            ])),
          ])).animate().fadeIn(duration: 400.ms),

        const SizedBox(height: 28),

        // Tracking Steps
        Text('Order Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
        const SizedBox(height: 20),
        ...List.generate(OrderStatus.values.length, (i) {
          final status = OrderStatus.values[i];
          final isCompleted = i <= currentStep;
          final isCurrent = i == currentStep;
          final isLast = i == OrderStatus.values.length - 1;

          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Timeline
            Column(children: [
              Container(width: 28, height: 28,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  color: isCompleted ? AppColors.primary : (isDark ? AppColors.darkCard : AppColors.divider),
                  border: isCurrent ? Border.all(color: AppColors.primary, width: 3) : null),
                child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 16) : null),
              if (!isLast) Container(width: 3, height: 50,
                color: isCompleted ? AppColors.primary : (isDark ? AppColors.darkDivider : AppColors.divider)),
            ]),
            const SizedBox(width: 16),
            Expanded(child: Container(
              margin: const EdgeInsets.only(bottom: 20), padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: isCurrent ? AppColors.primary.withValues(alpha: 0.08) : cardColor, borderRadius: BorderRadius.circular(14),
                border: isCurrent ? Border.all(color: AppColors.primary.withValues(alpha: 0.3)) : null),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(status.label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isCompleted ? AppColors.primary : textColor)),
                const SizedBox(height: 3),
                Text(status.description, style: TextStyle(fontSize: 12, color: subColor)),
              ]))),
          ]).animate().fadeIn(delay: (i * 100).ms, duration: 350.ms);
        }),

        const SizedBox(height: 24),

        // Delivery Partner
        Text('Delivery Partner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
        const SizedBox(height: 14),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(18), boxShadow: isDark ? null : AppColors.cardShadow),
          child: Row(children: [
            CircleAvatar(radius: 26, backgroundColor: AppColors.primarySurface, child: const Icon(Icons.delivery_dining, color: AppColors.primary, size: 28)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Rahul Kumar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
              const SizedBox(height: 3),
              Row(children: [const Icon(Icons.star, color: AppColors.warning, size: 16), const SizedBox(width: 4), Text('4.8 rating', style: TextStyle(fontSize: 13, color: subColor))]),
            ])),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.phone, color: Colors.white, size: 22)),
          ])),
      ])),
    );
  }
}
