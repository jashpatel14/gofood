import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/food/food_details_screen.dart';
import '../screens/navigation/main_navigation_screen.dart';
import '../screens/order/order_success_screen.dart';
import '../screens/order/order_tracking_screen.dart';
import '../screens/restaurant/restaurant_details_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/address/manage_address_screen.dart';
import '../screens/address/add_address_screen.dart';
import '../screens/food/category_details_screen.dart';
import '../models/address_model.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/my_coupons_screen.dart';
import '../screens/profile/payment_methods_screen.dart';
import '../screens/profile/help_support_screen.dart';
import '../screens/profile/about_screen.dart';
import '../models/order_model.dart';
import '../screens/orders/order_details_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              Text('Page not found', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/navigation',
        name: 'navigation',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/restaurant/:id',
        name: 'restaurant',
        builder: (context, state) => RestaurantDetailsScreen(
          restaurantId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/food-details/:id',
        name: 'food-details',
        builder: (context, state) => FoodDetailsScreen(
          foodId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/order-success',
        name: 'order-success',
        builder: (context, state) {
          final order = state.extra as OrderModel?;
          return OrderSuccessScreen(order: order);
        },
      ),
      GoRoute(
        path: '/order-tracking/:id',
        name: 'order-tracking',
        builder: (context, state) => OrderTrackingScreen(
          orderId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/manage-addresses',
        name: 'manage-addresses',
        builder: (context, state) => const ManageAddressScreen(),
      ),
      GoRoute(
        path: '/add-address',
        name: 'add-address',
        builder: (context, state) {
          final address = state.extra as AddressModel?;
          return AddAddressScreen(addressToEdit: address);
        },
      ),
      GoRoute(
        path: '/category/:name',
        name: 'category-details',
        builder: (context, state) => CategoryDetailsScreen(
          categoryName: state.pathParameters['name'] ?? '',
        ),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/my-coupons',
        name: 'my-coupons',
        builder: (context, state) => const MyCouponsScreen(),
      ),
      GoRoute(
        path: '/payment-methods',
        name: 'payment-methods',
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: '/help-support',
        name: 'help-support',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/order-details',
        name: 'order-details',
        builder: (context, state) {
          final order = state.extra as OrderModel;
          return OrderDetailsScreen(order: order);
        },
      ),
    ],
  );
}
