import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'Where is my order?',
      'answer': 'You can track your order in real-time by navigating to the "Orders" tab, selecting your active order, and choosing "Track Order". If the driver is delayed, please contact support.'
    },
    {
      'question': 'How do I cancel my order?',
      'answer': 'Orders can only be cancelled within 60 seconds of placing them. After the restaurant accepts your order, we cannot cancel or refund it as preparation has already commenced.'
    },
    {
      'question': 'How do I get a refund?',
      'answer': 'Refunds are automatically initiated if an order is rejected or cancelled by the restaurant. The funds will return to your source payment method within 3-5 business days.'
    },
    {
      'question': 'How can I change my delivery address?',
      'answer': 'To change a delivery address, please contact customer support immediately via Live Chat before the delivery executive is dispatched.'
    },
    {
      'question': 'Can I pay cash on delivery?',
      'answer': 'Yes! We support Cash on Delivery, credit cards, debit cards, UPI (GPay, PhonePe, Paytm), and Netbanking for maximum convenience.'
    },
  ];

  int _expandedIndex = -1;

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
          'Help & Support',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'How can we help?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Our customer service is available 24/7 to solve your issues.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.support_agent_rounded, size: 56, color: Colors.white)
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .slideY(begin: -0.05, end: 0.05, duration: 1.5.seconds, curve: Curves.easeInOut),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 28),

            // Contact shortcuts
            Text(
              'Direct Support Channels',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _supportCard(
                    Icons.chat_bubble_outline_rounded,
                    'Live Chat',
                    'Chat with support agents',
                    cardColor,
                    textColor,
                    subColor,
                    () => _simulateSupportAction('Starting a Live Chat session with GoFood assistant...'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _supportCard(
                    Icons.phone_in_talk_outlined,
                    'Call Support',
                    'Direct toll-free hotlines',
                    cardColor,
                    textColor,
                    subColor,
                    () => _simulateSupportAction('Dialing toll-free support helpline (1800-GO-FOOD)...'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

            const SizedBox(height: 28),

            // Expandable FAQ list
            Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor),
            ),
            const SizedBox(height: 14),

            ..._faqs.asMap().entries.map((entry) {
              final idx = entry.key;
              final faq = entry.value;
              final isExpanded = _expandedIndex == idx;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isDark ? null : AppColors.cardShadow,
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    key: Key('faq_$idx'),
                    initiallyExpanded: isExpanded,
                    onExpansionChanged: (expanding) {
                      setState(() {
                        _expandedIndex = expanding ? idx : -1;
                      });
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.help_outline_rounded, color: AppColors.primary, size: 18),
                    ),
                    title: Text(
                      faq['question']!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    trailing: Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Text(
                          faq['answer']!,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: subColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (idx * 80).ms, duration: 400.ms).slideY(begin: 0.05, end: 0);
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _simulateSupportAction(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _supportCard(
    IconData icon,
    String title,
    String sub,
    Color cardColor,
    Color textColor,
    Color subColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: cardColor == Colors.white ? AppColors.cardShadow : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: TextStyle(fontSize: 10, color: subColor),
            ),
          ],
        ),
      ),
    );
  }
}
