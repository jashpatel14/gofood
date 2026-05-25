import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/order_model.dart';
import '../../widgets/network_image_widget.dart';
import '../../api/restaurant_api.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/order_provider.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    // Poll the backend for this order's status every 4 seconds in the background
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        ref.read(orderProvider.notifier).refreshOrder(widget.order.id);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final activeOrder = orderState.orders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );
    final orderRef = activeOrder; // Shadowing reference safely
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;
    final statusColor = _getStatusColor(orderRef.status);

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
          'Order Summary',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status Banner Card ──────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [statusColor, statusColor.withValues(alpha: 0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.25),
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
                        Text(
                          orderRef.status.label.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          orderRef.status.description,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        if (orderRef.estimatedDelivery != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer_outlined, color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'ETA: ${orderRef.estimatedDelivery}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _getStatusIcon(orderRef.status)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2.seconds),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            // ── Dynamic Swiggy Stepper Timeline ──────────
            Text(
              'Delivery Timeline',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  _buildStepperStep('Order Placed', 'We have received your food request', true, isDark),
                  _buildDivider(orderRef.status.index >= 1, isDark),
                  _buildStepperStep('Accepted', 'Restaurant is reviewing your order', orderRef.status.index >= 1, isDark),
                  _buildDivider(orderRef.status.index >= 2, isDark),
                  _buildStepperStep('Preparing', 'Chef is cooking your fresh food box', orderRef.status.index >= 2, isDark),
                  _buildDivider(orderRef.status.index >= 3, isDark),
                  _buildStepperStep('Out for Delivery', 'Rider is carrying your warm box', orderRef.status.index >= 3, isDark),
                  _buildDivider(orderRef.status.index >= 4, isDark),
                  _buildStepperStep('Delivered', 'Delivered at your doorstep!', orderRef.status.index >= 4, isDark),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // ── Itemized summary ─────────────────────────
            Text(
              'Items Ordered',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orderRef.items.length,
                separatorBuilder: (ctx, idx) => Divider(
                  color: isDark ? AppColors.darkDivider : AppColors.divider,
                  height: 24,
                ),
                itemBuilder: (ctx, idx) {
                  final item = orderRef.items[idx];
                  return Row(
                    children: [
                      NetworkImageWidget(imageUrl: item.foodImage, width: 56, height: 56, borderRadius: 12),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.foodName,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${item.price.toStringAsFixed(0)} × ${item.quantity}',
                              style: TextStyle(fontSize: 12, color: subColor, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${item.totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textColor),
                      ),
                    ],
                  );
                },
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // ── Receipt Bill details ─────────────────────
            Text(
              'Bill Details',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  _billRow('Item Total', '₹${orderRef.subtotal.toStringAsFixed(0)}', subColor, textColor, false),
                  const SizedBox(height: 12),
                  _billRow('Delivery Fee', '₹${orderRef.deliveryFee.toStringAsFixed(0)}', subColor, textColor, false),
                  const SizedBox(height: 12),
                  _billRow('GST & Restaurant Charges', '₹${orderRef.gst.toStringAsFixed(0)}', subColor, textColor, false),
                  if (orderRef.discount > 0) ...[
                    const SizedBox(height: 12),
                    _billRow('Coupon Discount', '-₹${orderRef.discount.toStringAsFixed(0)}', AppColors.success, AppColors.success, false),
                  ],
                  Divider(color: isDark ? AppColors.darkDivider : AppColors.divider, height: 28),
                  _billRow('Grand Total', '₹${orderRef.totalAmount.toStringAsFixed(0)}', textColor, AppColors.primary, true),
                  Divider(color: isDark ? AppColors.darkDivider : AppColors.divider, height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paid via',
                            style: TextStyle(fontSize: 10, color: subColor, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            orderRef.paymentMethod,
                            style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'PAID',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.success),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // ── Delivery Information ─────────────────────
            Text(
              'Delivery Details',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Address',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              orderRef.deliveryAddress,
                              style: TextStyle(fontSize: 12, color: subColor, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(color: isDark ? AppColors.darkDivider : AppColors.divider, height: 28),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.receipt_rounded, color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order ID',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              orderRef.id,
                              style: TextStyle(fontSize: 12, color: subColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(color: isDark ? AppColors.darkDivider : AppColors.divider, height: 28),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Placed On',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${orderRef.createdAt.day}/${orderRef.createdAt.month}/${orderRef.createdAt.year} at ${_twoDigits(orderRef.createdAt.hour)}:${_twoDigits(orderRef.createdAt.minute)}',
                              style: TextStyle(fontSize: 12, color: subColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // ── Zomato-style Restaurant Review Card (when delivered) ──
            if (orderRef.status == OrderStatus.delivered) ...[
              _RestaurantReviewCard(order: orderRef, ref: ref),
            ],

            // ── Customer support button ──────────────────
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Connecting to customer service regarding your order...'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: cardColor,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.divider),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Need Help?',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  String _twoDigits(int n) => n >= 10 ? '$n' : '0$n';

  Widget _buildStepperStep(String title, String subtitle, bool isCompleted, bool isDark) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.success : (isDark ? AppColors.darkDivider : AppColors.divider),
            shape: BoxShape.circle,
            boxShadow: isCompleted
                ? [BoxShadow(color: AppColors.success.withValues(alpha: 0.3), blurRadius: 6)]
                : null,
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white30 : Colors.black26,
                    shape: BoxShape.circle,
                  ),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isCompleted ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.white38 : Colors.black38),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isCompleted ? (isDark ? Colors.white60 : Colors.black54) : (isDark ? Colors.white30 : Colors.black26),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isCompleted, bool isDark) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 11),
      child: Container(
        width: 2,
        height: 20,
        color: isCompleted ? AppColors.success : (isDark ? AppColors.darkDivider : AppColors.divider),
      ),
    );
  }

  Widget _billRow(String label, String value, Color labelColor, Color valueColor, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: labelColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 17 : 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const Icon(Icons.receipt_long_rounded, size: 52, color: Colors.white);
      case OrderStatus.accepted:
        return const Icon(Icons.thumb_up_alt_rounded, size: 52, color: Colors.white);
      case OrderStatus.preparing:
        return const Icon(Icons.outdoor_grill_rounded, size: 52, color: Colors.white);
      case OrderStatus.outForDelivery:
        return const Icon(Icons.delivery_dining_rounded, size: 52, color: Colors.white);
      case OrderStatus.delivered:
        return const Icon(Icons.task_alt_rounded, size: 52, color: Colors.white);
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.pending;
      case OrderStatus.accepted:
        return AppColors.accepted;
      case OrderStatus.preparing:
        return AppColors.preparing;
      case OrderStatus.outForDelivery:
        return AppColors.outForDelivery;
      case OrderStatus.delivered:
        return AppColors.delivered;
    }
  }
}

// ── Zomato/Swiggy-style Restaurant Review Card ──
class _RestaurantReviewCard extends StatefulWidget {
  final OrderModel order;
  final WidgetRef ref;

  const _RestaurantReviewCard({required this.order, required this.ref});

  @override
  State<_RestaurantReviewCard> createState() => _RestaurantReviewCardState();
}

class _RestaurantReviewCardState extends State<_RestaurantReviewCard> {
  double _rating = 5.0;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _getRatingText(double rating) {
    if (rating <= 1.0) return "Very Bad 😞";
    if (rating <= 2.0) return "Bad 😐";
    if (rating <= 3.0) return "Average 🙂";
    if (rating <= 4.0) return "Delicious! 😋";
    return "Awesome! 😍";
  }

  Future<void> _submitFeedback() async {
    final restaurantId = widget.order.restaurantId;
    if (restaurantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot resolve restaurant details for rating.'))
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final comment = _commentController.text.trim();
      // Call backend reviews API
      await RestaurantApi().submitReview(
        restaurantId,
        _rating,
        comment,
        widget.order.id,
      );

      // Invalidate Riverpod providers to update the rating/review count in real-time
      widget.ref.invalidate(restaurantDetailProvider(restaurantId));
      widget.ref.invalidate(restaurantListProvider);

      // Reactively mark this order as rated in the local order provider
      widget.ref.read(orderProvider.notifier).markOrderAsRated(
        widget.order.id,
        _rating,
        comment,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit feedback: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;
    final restaurantName = widget.order.restaurantName ?? 'the Restaurant';

    // If already rated (either from database or just submitted in-memory)
    if (widget.order.isRated) {
      final double userRating = widget.order.userRating ?? 5.0;
      final String userComment = widget.order.userComment ?? '';

      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.green.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: isDark ? null : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: AppColors.success, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  'Your Review Submitted',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 14),
            
            // Read-only stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1.0;
                final isSelected = starValue <= userRating;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.star_rounded,
                    size: 28,
                    color: isSelected ? Colors.amber[700] : (isDark ? Colors.white12 : Colors.grey[200]),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            Text(
              _getRatingText(userRating),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.amber[800]),
            ),
            
            if (userComment.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground.withValues(alpha: 0.4) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkDivider : AppColors.divider.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_quote_rounded, color: subColor.withValues(alpha: 0.4), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        userComment,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: textColor.withValues(alpha: 0.9),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ).animate().fadeIn(duration: 400.ms);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.stars_rounded, color: Colors.amber[700], size: 22),
              const SizedBox(width: 8),
              Text(
                'Rate Your Experience',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'How was the food from $restaurantName?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: subColor),
          ),
          const SizedBox(height: 18),

          // Rating stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1.0;
              final isSelected = starValue <= _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = starValue),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.star_rounded,
                    size: 38,
                    color: isSelected ? Colors.amber[700] : (isDark ? Colors.white24 : Colors.grey[300]),
                  ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 150.ms),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _getRatingText(_rating),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.amber[800]),
          ),
          const SizedBox(height: 20),

          // Review Comment field
          TextField(
            controller: _commentController,
            maxLines: 3,
            style: TextStyle(color: textColor, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Tell us what you liked or how we can improve (optional)...',
              hintStyle: TextStyle(color: subColor.withValues(alpha: 0.7), fontSize: 12),
              filled: true,
              fillColor: isDark ? AppColors.darkBackground.withValues(alpha: 0.5) : Colors.grey[50],
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: (isDark ? AppColors.darkDivider : AppColors.divider).withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 1,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text(
                      'Submit Feedback',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), duration: 400.ms);
  }
}
