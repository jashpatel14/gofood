import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/food_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/address_provider.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/network_image_widget.dart';
import '../../widgets/status_badge.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentBanner = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final restaurantsAsync = ref.watch(restaurantListProvider);
    final popularFoodsAsync = ref.watch(popularFoodsProvider);
    final defaultAddress = ref.watch(addressProvider.notifier).defaultAddress;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => context.push('/manage-addresses'),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Deliver To', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: subColor)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          defaultAddress != null ? '${defaultAddress.addressType} - ${defaultAddress.city}' : 'Select Delivery Address', 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: subColor, size: 22),
                    ]),
                  ]),
                )),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14), boxShadow: isDark ? null : AppColors.cardShadow),
                  child: Icon(Icons.notifications_none_rounded, color: textColor, size: 24),
                ),
              ]),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 20),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => context.push('/search'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), boxShadow: isDark ? null : AppColors.cardShadow),
                  child: Row(children: [
                    Icon(Icons.search_rounded, color: AppColors.primary.withValues(alpha: 0.7), size: 24),
                    const SizedBox(width: 12),
                    Text('Search food or restaurant...', style: TextStyle(fontSize: 14, color: subColor)),
                    const Spacer(),
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 18)),
                  ]),
                ),
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // Banner Slider
            CarouselSlider(
              options: CarouselOptions(height: 170, autoPlay: true, autoPlayInterval: const Duration(seconds: 4), enlargeCenterPage: true, viewportFraction: 0.88,
                onPageChanged: (i, _) => setState(() => _currentBanner = i)),
              items: MockData.banners.map((b) => ClipRRect(borderRadius: BorderRadius.circular(20),
                child: Stack(fit: StackFit.expand, children: [
                  NetworkImageWidget(imageUrl: b['image']!),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent]))),
                  Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(b['title']!, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.1)),
                    const SizedBox(height: 6),
                    Text(b['subtitle']!, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                    const SizedBox(height: 12),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: const Text('Order Now', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700))),
                  ])),
                ]))).toList(),
            ),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(MockData.banners.length, (i) =>
              AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4), width: _currentBanner == i ? 24 : 8, height: 8,
                decoration: BoxDecoration(color: _currentBanner == i ? AppColors.primary : AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4))))),

            const SizedBox(height: 28),

            // Categories
            _sectionHeader('Categories', 'See All', textColor),
            const SizedBox(height: 16),
            SizedBox(height: 100, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: MockData.categories.length,
              itemBuilder: (ctx, i) {
                final c = MockData.categories[i];
                return Container(width: 80, margin: const EdgeInsets.symmetric(horizontal: 6), child: Column(children: [
                  Container(width: 60, height: 60, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.primary.withValues(alpha: 0.05)]), borderRadius: BorderRadius.circular(18)),
                    child: Icon(c.icon, color: AppColors.primary, size: 28)),
                  const SizedBox(height: 8),
                  Text(c.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                ])).animate().fadeIn(delay: (100 + i * 60).ms, duration: 400.ms);
              })),

            const SizedBox(height: 28),

            // Popular Restaurants
            _sectionHeader('Popular Restaurants', 'View All', textColor),
            const SizedBox(height: 16),
            restaurantsAsync.when(
              loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
              error: (e, s) => const Padding(padding: EdgeInsets.all(20), child: Text('Failed to load restaurants')),
              data: (restaurants) => ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: restaurants.length > 4 ? 4 : restaurants.length, itemBuilder: (ctx, i) {
                final r = restaurants[i];
                return GestureDetector(onTap: () => context.push('/restaurant/${r.id}'),
                  child: Container(margin: const EdgeInsets.only(bottom: 18), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(22), boxShadow: isDark ? null : AppColors.cardShadow),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Stack(children: [
                        NetworkImageWidget(imageUrl: r.image, height: 170, width: double.infinity, borderRadius: 22),
                        Positioned(top: 12, right: 12, child: RatingBadge(rating: r.rating)),
                        Positioned(bottom: 12, left: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.timer_outlined, size: 14, color: AppColors.primary), const SizedBox(width: 4),
                            Text(r.deliveryTime, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))]))),
                        if (!r.isOpen) Positioned(top: 12, left: 12, child: StatusBadge.closed()),
                      ]),
                      Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r.name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: textColor)),
                        const SizedBox(height: 6),
                        Text(r.cuisineType, style: TextStyle(fontSize: 13, color: subColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ])),
                    ])));
              })),

            const SizedBox(height: 28),

            // Recommended Foods
            _sectionHeader('Recommended For You', 'See All', textColor),
            const SizedBox(height: 16),
            popularFoodsAsync.when(
              loading: () => const SizedBox(height: 230, child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
              error: (e, s) => const Padding(padding: EdgeInsets.all(20), child: Text('Failed to load foods')),
              data: (popularFoods) => SizedBox(height: 230, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: popularFoods.length,
              itemBuilder: (ctx, i) {
                final f = popularFoods[i];
                return GestureDetector(onTap: () => context.push('/food-details/${f.id}'),
                  child: Container(width: 170, margin: const EdgeInsets.symmetric(horizontal: 8), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), boxShadow: isDark ? null : AppColors.cardShadow),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Stack(children: [
                        NetworkImageWidget(imageUrl: f.image, height: 120, width: 170, borderRadius: 20),
                        Positioned(top: 8, right: 8, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                          child: const Icon(Icons.favorite_border, size: 16, color: AppColors.error))),
                      ]),
                      Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(f.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(f.restaurantName, style: TextStyle(fontSize: 11, color: subColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('₹${f.price.toInt()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
                          Row(children: [const Icon(Icons.star, size: 14, color: AppColors.warning), const SizedBox(width: 2), Text(f.rating.toString(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor))]),
                        ]),
                      ])),
                    ])));
              }))),

            const SizedBox(height: 28),

            // Special Offers
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Special Offers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor)),
              const SizedBox(height: 16),
              Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: AppColors.bannerGradient, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8))]),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                      child: const Text('LIMITED TIME', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1))),
                    const SizedBox(height: 12),
                    const Text('Use Code\nFIRST50', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, height: 1.2)),
                    const SizedBox(height: 8),
                    Text('Get ₹50 off on your first order', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
                  ])),
                  Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.local_offer, color: Colors.white, size: 36)),
                ])),
            ])),

            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String action, Color textColor) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor)),
      Text(action, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
    ]));
  }
}
