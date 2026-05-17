import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(30),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Lottie.asset('assets/animations/success.json', height: 180, repeat: false),
          ).animate().scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 36),
          Text('Order Placed!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary))
            .animate().fadeIn(delay: 400.ms, duration: 500.ms),
          const SizedBox(height: 12),
          Text('Your delicious food is being prepared\nand will be delivered soon.', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.6, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary))
            .animate().fadeIn(delay: 600.ms, duration: 500.ms),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.timer, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text('Estimated delivery: 30-40 min', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
            ])).animate().fadeIn(delay: 800.ms, duration: 500.ms),
          const Spacer(),
          CustomButton(text: 'Track Order', icon: Icons.local_shipping_outlined, onPressed: () => context.go('/navigation'))
            .animate().fadeIn(delay: 1000.ms, duration: 400.ms),
          const SizedBox(height: 14),
          CustomButton(text: 'Back to Home', isOutlined: true, onPressed: () => context.go('/navigation'))
            .animate().fadeIn(delay: 1100.ms, duration: 400.ms),
        ]))),
    );
  }
}
