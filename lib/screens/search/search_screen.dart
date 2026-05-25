import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../api/food_api.dart';
import '../../api/restaurant_api.dart';
import '../../core/theme/app_colors.dart';
import '../../models/food_model.dart';
import '../../models/restaurant_model.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/network_image_widget.dart';
import '../../widgets/status_badge.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<RestaurantModel> _restaurants = [];
  List<FoodModel> _foods = [];

  void _onSearch(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.isEmpty) {
        setState(() { _restaurants = []; _foods = []; });
      } else {
        try {
          final restaurants = await RestaurantApi().searchRestaurants(query);
          final foods = await FoodApi().searchFoods(query);
          if (mounted) setState(() { _restaurants = restaurants; _foods = foods; });
        } catch (_) {
          // Fallback to mock data
          if (mounted) {
            setState(() {
              _restaurants = MockData.searchRestaurants(query);
              _foods = MockData.searchFoods(query);
            });
          }
        }
      }
    });
  }

  @override
  void dispose() { _debounce?.cancel(); _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;
    final hasResults = _restaurants.isNotEmpty || _foods.isNotEmpty;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.background,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkDivider : AppColors.divider,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _controller, 
            autofocus: true, 
            onChanged: _onSearch,
            style: TextStyle(color: textColor, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Search food, restaurants...', 
              hintStyle: TextStyle(color: subColor, fontSize: 14),
              border: InputBorder.none, 
              enabledBorder: InputBorder.none, 
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty) IconButton(onPressed: () { _controller.clear(); _onSearch(''); }, icon: const Icon(Icons.close)),
        ],
      ),
      body: !hasResults && _controller.text.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.search, size: 80, color: AppColors.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('Search for your favorite food', style: TextStyle(fontSize: 16, color: subColor)),
          ]))
        : !hasResults
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.no_food, size: 80, color: AppColors.primary.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text('No results found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
              const SizedBox(height: 6),
              Text('Try searching with different keywords', style: TextStyle(fontSize: 14, color: subColor)),
            ]))
          : SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (_restaurants.isNotEmpty) ...[
                Text('Restaurants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
                const SizedBox(height: 12),
                ...(_restaurants.map((r) => GestureDetector(
                  onTap: () async {
                    await context.push('/restaurant/${r.id}');
                    _onSearch(_controller.text);
                  },
                  child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), boxShadow: isDark ? null : AppColors.cardShadow),
                    child: Row(children: [
                      NetworkImageWidget(imageUrl: r.image, width: 70, height: 70, borderRadius: 14),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(r.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            const SizedBox(width: 6),
                            RestaurantStatusBadge(status: r.status, fontSize: 9),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(r.cuisineType, style: TextStyle(fontSize: 12, color: subColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Row(children: [RatingBadge(rating: r.rating, size: 12), const SizedBox(width: 8), Text(r.deliveryTime, style: TextStyle(fontSize: 12, color: subColor))]),
                      ])),
                    ]))))),
                const SizedBox(height: 20),
              ],
              if (_foods.isNotEmpty) ...[
                Text('Food Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
                const SizedBox(height: 12),
                ...(_foods.map((f) => GestureDetector(
                  onTap: () async {
                    await context.push('/food-details/${f.id}');
                    _onSearch(_controller.text);
                  },
                  child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), boxShadow: isDark ? null : AppColors.cardShadow),
                    child: Row(children: [
                      NetworkImageWidget(imageUrl: f.image, width: 70, height: 70, borderRadius: 14),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(f.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                        const SizedBox(height: 4),
                        Text(f.restaurantName, style: TextStyle(fontSize: 12, color: subColor)),
                        const SizedBox(height: 6),
                        Text('₹${f.price.toInt()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      ])),
                    ]))))),
              ],
            ])),
    );
  }
}
