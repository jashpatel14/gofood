import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'About GoFood',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Logo Scale
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppColors.elevatedShadow,
                ),
                child: const Icon(
                  Icons.fastfood_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            ),
            const SizedBox(height: 24),
            Text(
              'GoFood',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: textColor),
            ),
            const SizedBox(height: 6),
            Text(
              'Version 1.0.0 (Stable)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: subColor),
            ),
            const SizedBox(height: 24),

            // Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: Text(
                'GoFood is a professional, high-performance food ordering and delivery system. We connect food lovers with premium local restaurants to deliver hot, fresh, and delicious meals right to their doorsteps in record times.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 28),

            // Settings options list
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  _aboutTile(Icons.assignment_outlined, 'Terms of Service', isDark, textColor, subColor, context),
                  Divider(color: isDark ? AppColors.darkDivider : AppColors.divider, height: 1),
                  _aboutTile(Icons.privacy_tip_outlined, 'Privacy Policy', isDark, textColor, subColor, context),
                  Divider(color: isDark ? AppColors.darkDivider : AppColors.divider, height: 1),
                  _aboutTile(Icons.article_outlined, 'Open Source Licenses', isDark, textColor, subColor, context),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

            const SizedBox(height: 40),
            Text(
              '© 2026 GoFood Ltd. All rights reserved.',
              style: TextStyle(fontSize: 11, color: subColor, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _aboutTile(
    IconData icon,
    String title,
    bool isDark,
    Color textColor,
    Color subColor,
    BuildContext context,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textColor),
      ),
      trailing: Icon(Icons.chevron_right, color: subColor, size: 20),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Displaying $title details...'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }
}
