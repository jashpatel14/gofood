import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/address_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = ref.watch(authProvider);
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;

    final isLoggedIn = auth.isAuthenticated && auth.user != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Dynamic Profile Header ───────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Column(
                children: [
                  if (isLoggedIn) ...[
                    // Logged in user details
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundImage: auth.user!.avatarUrl.isNotEmpty
                            ? NetworkImage(auth.user!.avatarUrl)
                            : null,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: auth.user!.avatarUrl.isEmpty
                            ? const Icon(Icons.person, size: 48, color: Colors.white)
                            : null,
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 16),
                    Text(
                      auth.user!.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 4),
                    Text(
                      auth.user!.email,
                      style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.85)),
                    ).animate().fadeIn(delay: 150.ms),
                    const SizedBox(height: 6),
                    Text(
                      auth.user!.phone,
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
                    ).animate().fadeIn(delay: 200.ms),
                  ] else ...[
                    // Guest User Details
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: const Icon(Icons.person_outline_rounded, size: 48, color: Colors.white),
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 16),
                    const Text(
                      'Welcome Foodie!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 6),
                    Text(
                      'Login or Sign Up to unlock custom orders and savings',
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.75)),
                    ).animate().fadeIn(delay: 150.ms),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Login / Sign Up', style: TextStyle(fontWeight: FontWeight.w700)),
                    ).animate().fadeIn(delay: 200.ms),
                  ],
                ],
              ),
            ),

            // ── Main Options ──────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Stats card (only visible or active if logged in)
                  if (isLoggedIn)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isDark ? null : AppColors.cardShadow,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _stat('Orders', '${ref.watch(orderProvider).orders.length}', textColor, subColor),
                          Container(width: 1, height: 40, color: isDark ? AppColors.darkDivider : AppColors.divider),
                          _stat('Favorites', '0', textColor, subColor),
                          Container(width: 1, height: 40, color: isDark ? AppColors.darkDivider : AppColors.divider),
                          _stat('Addresses', '${ref.watch(addressProvider).length}', textColor, subColor),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  // Profile Settings Section
                  _tile(
                    Icons.person_outline,
                    'Edit Profile',
                    null,
                    cardColor,
                    textColor,
                    isDark,
                    isLoggedIn ? () => context.push('/edit-profile') : () => _showLoginPrompt(context),
                  ),
                  _tile(
                    Icons.location_on_outlined,
                    'Manage Addresses',
                    null,
                    cardColor,
                    textColor,
                    isDark,
                    isLoggedIn ? () => context.push('/manage-addresses') : () => _showLoginPrompt(context),
                  ),
                  _tile(
                    Icons.payment_outlined,
                    'Payment Methods',
                    null,
                    cardColor,
                    textColor,
                    isDark,
                    () => context.push('/payment-methods'),
                  ),
                  _tile(
                    Icons.local_offer_outlined,
                    'My Coupons',
                    null,
                    cardColor,
                    textColor,
                    isDark,
                    () => context.push('/my-coupons'),
                  ),

                  // Dark mode toggle
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isDark ? null : AppColors.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.dark_mode_outlined, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Dark Mode',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                          ),
                        ),
                        Switch(
                          value: isDark,
                          activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                          activeThumbColor: AppColors.primary,
                          onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
                        ),
                      ],
                    ),
                  ),

                  _tile(
                    Icons.help_outline,
                    'Help & Support',
                    null,
                    cardColor,
                    textColor,
                    isDark,
                    () => context.push('/help-support'),
                  ),
                  _tile(
                    Icons.info_outline,
                    'About GoFood',
                    'v1.0.0',
                    cardColor,
                    textColor,
                    isDark,
                    () => context.push('/about'),
                  ),

                  const SizedBox(height: 12),

                  // Logout or Quick Login Option at bottom
                  if (isLoggedIn)
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w800)),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref.read(authProvider.notifier).logout();
                                  Navigator.pop(ctx);
                                  context.go('/login');
                                },
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: AppColors.error, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Logout',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login_rounded, color: AppColors.primary, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'Login Now',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Account Required', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('You need to be logged in to view or edit profile details.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/login');
            },
            child: const Text(
              'Login Now',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color textColor, Color subColor) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: subColor, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _tile(
    IconData icon,
    String title,
    String? trailing,
    Color cardColor,
    Color textColor,
    bool isDark,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? null : AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.darkTextSecondary : AppColors.iconDefault,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
