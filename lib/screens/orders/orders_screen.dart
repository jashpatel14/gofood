import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/network_image_widget.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orderState = ref.watch(orderProvider);
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;

    return DefaultTabController(length: 2, child: Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(title: const Text('My Orders'),
        bottom: TabBar(
          labelColor: AppColors.primary, unselectedLabelColor: subColor,
          indicatorColor: AppColors.primary, indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          tabs: [
            Tab(text: 'Active (${orderState.activeOrders.length})'),
            Tab(text: 'Past (${orderState.pastOrders.length})'),
          ])),
      body: orderState.isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : TabBarView(children: [
          _buildOrderList(orderState.activeOrders, isDark, textColor, subColor, cardColor, context),
          _buildOrderList(orderState.pastOrders, isDark, textColor, subColor, cardColor, context),
        ]),
    ));
  }

  Widget _buildOrderList(List<OrderModel> orders, bool isDark, Color textColor, Color subColor, Color cardColor, BuildContext context) {
    if (orders.isEmpty) {
      return const EmptyStateWidget(icon: Icons.receipt_long_outlined, title: 'No orders yet', subtitle: 'Your order history will appear here');
    }

    return ListView.builder(padding: const EdgeInsets.all(16), itemCount: orders.length,
      itemBuilder: (ctx, i) {
        final order = orders[i];
        final statusColor = _getStatusColor(order.status);
        return Container(
          margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), boxShadow: isDark ? null : AppColors.cardShadow),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(order.id, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(order.status.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor))),
            ]),
            const SizedBox(height: 14),
            // Items preview
            SizedBox(height: 60, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: order.items.length,
              itemBuilder: (ctx, j) {
                final item = order.items[j];
                return Padding(padding: const EdgeInsets.only(right: 10),
                  child: Row(children: [
                    NetworkImageWidget(imageUrl: item.foodImage, width: 50, height: 50, borderRadius: 12),
                    const SizedBox(width: 10),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(item.foodName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('x${item.quantity}', style: TextStyle(fontSize: 12, color: subColor)),
                    ]),
                    if (j < order.items.length - 1) Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Container(width: 1, height: 30, color: isDark ? AppColors.darkDivider : AppColors.divider)),
                  ]));
              })),
            Divider(color: isDark ? AppColors.darkDivider : AppColors.divider, height: 24),
            // Footer
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(_formatDate(order.createdAt), style: TextStyle(fontSize: 12, color: subColor)),
              Text('₹${order.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ]),
          ]),
        ).animate().fadeIn(delay: (i * 100).ms, duration: 350.ms);
      });
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return AppColors.pending;
      case OrderStatus.accepted: return AppColors.accepted;
      case OrderStatus.preparing: return AppColors.preparing;
      case OrderStatus.outForDelivery: return AppColors.outForDelivery;
      case OrderStatus.delivered: return AppColors.delivered;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
