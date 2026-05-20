import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  final List<Map<String, dynamic>> _savedCards = [
    {
      'holder': 'Jash Patel',
      'number': '•••• •••• •••• 4298',
      'expiry': '08/29',
      'type': 'Visa',
      'gradient': const LinearGradient(
        colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'holder': 'Jash Patel',
      'number': '•••• •••• •••• 9812',
      'expiry': '11/31',
      'type': 'Mastercard',
      'gradient': const LinearGradient(
        colors: [Color(0xFF833ab4), Color(0xFFfd1d1d), Color(0xFFfcb045)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
  ];

  final List<Map<String, String>> _upiApps = [
    {'name': 'Google Pay', 'icon': 'G'},
    {'name': 'PhonePe', 'icon': 'P'},
    {'name': 'Paytm', 'icon': 'Py'},
    {'name': 'BHIM UPI', 'icon': 'U'},
  ];

  void _showAddCardDialog() {
    final formKey = GlobalKey<FormState>();
    final numberController = TextEditingController();
    final holderController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add Credit / Debit Card',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: numberController,
                    hintText: 'Card Number (16 digits)',
                    prefixIcon: Icons.credit_card_outlined,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.length < 16) return 'Enter a valid 16-digit card number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: holderController,
                    hintText: 'Cardholder Full Name',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Enter cardholder name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: expiryController,
                          hintText: 'Expiry (MM/YY)',
                          prefixIcon: Icons.date_range_outlined,
                          keyboardType: TextInputType.datetime,
                          validator: (val) {
                            if (val == null || !val.contains('/')) return 'MM/YY';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: CustomTextField(
                          controller: cvvController,
                          hintText: 'CVV (3 digits)',
                          prefixIcon: Icons.lock_outline_rounded,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          validator: (val) {
                            if (val == null || val.length < 3) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Save Card',
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      setState(() {
                        final formattedNum = numberController.text;
                        final hiddenNum = '•••• •••• •••• ${formattedNum.substring(formattedNum.length - 4)}';
                        _savedCards.add({
                          'holder': holderController.text.trim(),
                          'number': hiddenNum,
                          'expiry': expiryController.text.trim(),
                          'type': formattedNum.startsWith('4') ? 'Visa' : 'Mastercard',
                          'gradient': const LinearGradient(
                            colors: [Color(0xFF232526), Color(0xFF414345)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        });
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Card saved successfully!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Payment Methods',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved Cards',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor),
                ),
                GestureDetector(
                  onTap: _showAddCardDialog,
                  child: Row(
                    children: [
                      Icon(Icons.add, color: AppColors.primary, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Add New',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card PageView / Column
            ..._savedCards.asMap().entries.map((entry) {
              final idx = entry.key;
              final card = entry.value;
              return _buildCreditCard(card, isDark)
                  .animate()
                  .fadeIn(delay: (idx * 150).ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0);
            }),

            const SizedBox(height: 28),

            // UPI Apps
            Text(
              'UPI Applications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _upiApps.length,
                separatorBuilder: (context, index) => Divider(
                  color: isDark ? AppColors.darkDivider : AppColors.divider,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final app = _upiApps[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        app['icon']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    title: Text(
                      app['name']!,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textColor),
                    ),
                    trailing: Text(
                      'Link Account',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    onTap: () => _simulateLinking(app['name']!),
                  );
                },
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 28),

            // More Options
            Text(
              'Other Payment Options',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  _tileItem(
                    Icons.account_balance_outlined,
                    'Net Banking',
                    'Pay using standard Indian Banks',
                    isDark,
                    textColor,
                    subColor,
                  ),
                  Divider(color: isDark ? AppColors.darkDivider : AppColors.divider, height: 1),
                  _tileItem(
                    Icons.payments_outlined,
                    'Cash on Delivery',
                    'Pay when your foodie box arrives',
                    isDark,
                    textColor,
                    subColor,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _simulateLinking(String appName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Linking $appName to your GoFood Wallet...'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _tileItem(
    IconData icon,
    String title,
    String sub,
    bool isDark,
    Color textColor,
    Color subColor,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textColor),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          sub,
          style: TextStyle(fontSize: 11, color: subColor),
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: subColor, size: 20),
      onTap: () {},
    );
  }

  Widget _buildCreditCard(Map<String, dynamic> card, bool isDark) {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: card['gradient'] as LinearGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card['type'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -1,
                ),
              ),
              const Icon(Icons.contactless_outlined, color: Colors.white70, size: 24),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card['number'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CARDHOLDER',
                    style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card['holder'],
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VALID THRU',
                    style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card['expiry'],
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
