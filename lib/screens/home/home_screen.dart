import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/food_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/address_provider.dart';
import '../../models/address_model.dart';
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

  void _handleBannerTap(BuildContext context, Map<String, String> banner) {
    final type = banner['targetType'];
    final id = banner['targetId'] ?? '';
    
    if (type == 'restaurant') {
      context.push('/restaurant/$id');
    } else if (type == 'food') {
      context.push('/food-details/$id');
    } else if (type == 'offer') {
      _showOfferBottomSheet(context, id, banner['title'] ?? 'Special Offer');
    }
  }

  void _showOfferBottomSheet(BuildContext context, String couponCode, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : AppColors.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: subColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Claim $title!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textColor),
              ),
              const SizedBox(height: 6),
              Text(
                'Copy code to grab the maximum discount on your meal',
                style: TextStyle(fontSize: 13, color: subColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppColors.bannerGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'GOFOOD SPECIAL',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withValues(alpha: 0.6), style: BorderStyle.solid, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        couponCode,
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      couponCode == 'FIRST50' 
                          ? 'Get ₹50 discount on your first order of ₹150 or more!'
                          : 'Flat ₹100 discount on premium feasts of ₹799 or more!',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().scale(delay: 100.ms, duration: 300.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  Clipboard.setData(ClipboardData(text: couponCode));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Coupon "$couponCode" copied to clipboard!'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ));
                },
                icon: const Icon(Icons.copy_rounded, color: Colors.white),
                label: const Text('COPY COUPON CODE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Text(
                    'Applicable Restaurants',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor),
                  ),
                  const Spacer(),
                  Text(
                    '2 Available',
                    style: TextStyle(fontSize: 12, color: subColor, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...MockData.restaurants.take(2).map((r) {
                return GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: couponCode));
                    Navigator.pop(ctx);
                    context.push('/restaurant/${r.id}');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Coupon "$couponCode" applied! Ordering from ${r.name}'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isDark ? null : AppColors.cardShadow,
                    ),
                    child: Row(
                      children: [
                        NetworkImageWidget(imageUrl: r.image, width: 50, height: 50, borderRadius: 10),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                              const SizedBox(height: 4),
                              Text(r.cuisineType, style: TextStyle(fontSize: 11, color: subColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Text('Order', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w800)),
                              SizedBox(width: 2),
                              Icon(Icons.chevron_right, color: AppColors.primary, size: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAddressSelectionBottomSheet(BuildContext context, List<AddressModel> addresses) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;

    // Get current default address id
    AddressModel? currentDefault;
    if (addresses.isNotEmpty) {
      try {
        currentDefault = addresses.firstWhere((e) => e.isDefault);
      } catch (_) {
        currentDefault = addresses.first;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : AppColors.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: subColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Delivery Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/manage-addresses');
                    },
                    icon: const Icon(Icons.edit_location_alt_rounded, size: 16, color: AppColors.primary),
                    label: const Text('Manage', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (addresses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: [
                        Icon(Icons.location_off_outlined, size: 48, color: subColor.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text('No saved addresses found', style: TextStyle(color: subColor, fontSize: 14)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.push('/add-address');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Add Address', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: addresses.length,
                    itemBuilder: (context, i) {
                      final address = addresses[i];
                      final isSelected = currentDefault?.id == address.id;

                      return GestureDetector(
                        onTap: () async {
                          Navigator.pop(ctx);
                          // Set default globally
                          await ref.read(addressProvider.notifier).setDefaultAddress(address.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Delivery location updated to ${address.addressType}!'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ));
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: isDark ? null : AppColors.cardShadow,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (isSelected ? AppColors.primary : subColor).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  address.addressType.toLowerCase() == 'home' ? Icons.home : 
                                  address.addressType.toLowerCase() == 'work' ? Icons.work : Icons.location_on, 
                                  color: isSelected ? AppColors.primary : subColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(address.addressType, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                                    const SizedBox(height: 4),
                                    Text(address.fullAddress, style: TextStyle(fontSize: 12, color: subColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSelected ? AppColors.primary : subColor.withValues(alpha: 0.5),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final restaurantsAsync = ref.watch(restaurantListProvider);
    final popularFoodsAsync = ref.watch(popularFoodsProvider);
    final addresses = ref.watch(addressProvider);
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    AddressModel? defaultAddress;
    if (addresses.isNotEmpty) {
      try {
        defaultAddress = addresses.firstWhere((e) => e.isDefault);
      } catch (_) {
        defaultAddress = addresses.first;
      }
    }

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
                  onTap: () => _showAddressSelectionBottomSheet(context, addresses),
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
              items: MockData.banners.map((b) => GestureDetector(
                onTap: () => _handleBannerTap(context, b),
                child: ClipRRect(borderRadius: BorderRadius.circular(20),
                  child: Stack(fit: StackFit.expand, children: [
                    NetworkImageWidget(imageUrl: b['image']!),
                    Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent]))),
                    Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(b['title']!, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.1)),
                      const SizedBox(height: 6),
                      Text(b['subtitle']!, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                      const SizedBox(height: 12),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          b['targetType'] == 'offer' ? 'Claim Offer' : 'Order Now', 
                          style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)
                        )),
                    ])),
                  ]))),
              ).toList(),
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
                return GestureDetector(
                  onTap: () => context.push('/category/${c.name}'),
                  child: Container(
                    width: 80, 
                    margin: const EdgeInsets.symmetric(horizontal: 6), 
                    child: Column(
                      children: [
                        Container(width: 60, height: 60, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.primary.withValues(alpha: 0.05)]), borderRadius: BorderRadius.circular(18)),
                          child: Icon(c.icon, color: AppColors.primary, size: 28)),
                        const SizedBox(height: 8),
                        Text(c.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: (100 + i * 60).ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0));
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
