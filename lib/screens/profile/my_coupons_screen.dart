import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class MyCouponsScreen extends ConsumerStatefulWidget {
  const MyCouponsScreen({super.key});

  @override
  ConsumerState<MyCouponsScreen> createState() => _MyCouponsScreenState();
}

class _MyCouponsScreenState extends ConsumerState<MyCouponsScreen> {
  final List<Map<String, dynamic>> _coupons = [
    {
      'code': 'FIRST50',
      'discount': '₹50 OFF',
      'description': 'Save ₹50 on your very first order',
      'minOrder': 'Min. order ₹200',
      'expiry': 'Expires in 7 days',
      'color': const Color(0xFFFF4B2B),
    },
    {
      'code': 'GOFOOD20',
      'discount': '20% OFF',
      'description': 'Enjoy 20% discount on any meal tonight',
      'minOrder': 'Min. order ₹100',
      'expiry': 'Expires in 2 days',
      'color': const Color(0xFF1D976C),
    },
    {
      'code': 'WELCOME',
      'discount': '₹40 OFF',
      'description': 'Special welcome gift coupon for our new foodies',
      'minOrder': 'Min. order ₹150',
      'expiry': 'Expires in 15 days',
      'color': AppColors.primary,
    },
    {
      'code': 'FLAT100',
      'discount': '₹100 OFF',
      'description': 'Flat ₹100 discount on bulk family feasts',
      'minOrder': 'Min. order ₹500',
      'expiry': 'Expires in 5 days',
      'color': const Color(0xFF8A2387),
    },
    {
      'code': 'SAVE30',
      'discount': '30% OFF',
      'description': 'Mid-week stress buster! Get 30% flat off',
      'minOrder': 'Min. order ₹300',
      'expiry': 'Expires in 1 day',
      'color': const Color(0xFF1A2980),
    },
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;

    final filteredCoupons = _coupons.where((c) {
      final code = c['code'].toString().toLowerCase();
      final desc = c['description'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return code.contains(query) || desc.contains(query);
    }).toList();

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
          'My Coupons',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Search promo code or restaurant...',
                  hintStyle: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textHint),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 22),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms),

          Expanded(
            child: filteredCoupons.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_offer_outlined, size: 64, color: AppColors.primary),
                        const SizedBox(height: 16),
                        Text(
                          'No Coupons Found',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try searching for another keyword',
                          style: TextStyle(fontSize: 13, color: subColor),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredCoupons.length,
                    itemBuilder: (context, index) {
                      final coupon = filteredCoupons[index];
                      return _buildCouponCard(coupon, isDark, cardColor, textColor, subColor)
                          .animate()
                          .fadeIn(delay: (index * 80).ms, duration: 400.ms)
                          .slideY(begin: 0.1, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(
    Map<String, dynamic> coupon,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subColor,
  ) {
    final couponColor = coupon['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 125,
      child: ClipPath(
        clipper: CouponClipper(),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark ? null : AppColors.cardShadow,
          ),
          child: Row(
            children: [
              // Left Colored Bar with Discount Tag
              Container(
                width: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [couponColor, couponColor.withValues(alpha: 0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_offer, color: Colors.white, size: 22),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        coupon['discount'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Dotted Separator Line
              CustomPaint(
                size: const Size(1, double.infinity),
                painter: DottedLinePainter(color: isDark ? AppColors.darkDivider : AppColors.divider),
              ),

              // Right details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: couponColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: couponColor.withValues(alpha: 0.3), width: 1),
                            ),
                            child: Text(
                              coupon['code'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: couponColor,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: coupon['code']));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text('Code "${coupon['code']}" copied!'),
                                    ],
                                  ),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Icon(Icons.copy_all_outlined, size: 14, color: AppColors.primary),
                                const SizedBox(width: 2),
                                Text(
                                  'COPY',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        coupon['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            coupon['minOrder'],
                            style: TextStyle(fontSize: 10, color: subColor, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            coupon['expiry'],
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Clipper for Ticket Cutout
class CouponClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const radius = 10.0;

    path.lineTo(90 - radius, 0);
    path.arcToPoint(
      const Offset(90 + radius, 0),
      radius: const Radius.circular(10.0),
      clockwise: false,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(90 + radius, size.height);
    path.arcToPoint(
      Offset(90 - radius, size.height),
      radius: const Radius.circular(10.0),
      clockwise: false,
    );
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Dotted Separator Painter
class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashHeight = 5.0;
    const dashSpace = 4.0;
    double startY = 8.0;

    while (startY < size.height - 8.0) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
