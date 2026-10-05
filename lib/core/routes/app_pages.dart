import 'package:get/get.dart';
import '../constants/app_routes.dart';

// Bindings
import '../../features/splash/splash_binding.dart';
import '../../features/onboarding/onboarding_binding.dart';
import '../../features/auth/auth_binding.dart';
import '../../features/home/main_binding.dart';
import '../../features/category/category_binding.dart';
import '../../features/search/search_binding.dart';
import '../../features/product/product_binding.dart';
import '../../features/cart/cart_binding.dart';
import '../../features/checkout/checkout_binding.dart';
import '../../features/favorite/favorite_binding.dart';
import '../../features/order/order_binding.dart';
import '../../features/profile/profile_binding.dart';

// Screens
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/main_screen.dart';
import '../../features/category/category_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/product/product_detail_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/favorite/favorite_screen.dart';
import '../../features/order/order_history_screen.dart';
import '../../features/order/order_detail_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/change_password_screen.dart';
import '../../features/profile/address_book_screen.dart';
import '../../features/admin/admin_binding.dart';
import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/ai_assistant/ai_assistant_binding.dart';
import '../../features/ai_assistant/ai_assistant_screen.dart';
import '../../features/notification/notification_binding.dart';
import '../../features/notification/notification_screen.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen(), binding: SplashBinding()),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingScreen(), binding: OnboardingBinding()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen(), binding: AuthBinding()),
    GetPage(name: AppRoutes.register, page: () => const RegisterScreen(), binding: AuthBinding()),
    GetPage(name: AppRoutes.main, page: () => const MainScreen(), binding: MainBinding()),
    GetPage(name: AppRoutes.category, page: () => const CategoryScreen(), binding: CategoryBinding()),
    GetPage(name: AppRoutes.search, page: () => const SearchScreen(), binding: SearchBinding()),
    GetPage(name: AppRoutes.productDetail, page: () => const ProductDetailScreen(), binding: ProductBinding()),
    GetPage(name: AppRoutes.cart, page: () => const CartScreen(), binding: CartBinding()),
    GetPage(name: AppRoutes.checkout, page: () => const CheckoutScreen(), binding: CheckoutBinding()),
    GetPage(name: AppRoutes.favorites, page: () => const FavoriteScreen(), binding: FavoriteBinding()),
    GetPage(name: AppRoutes.orders, page: () => const OrderHistoryScreen(), binding: OrderBinding()),
    GetPage(name: AppRoutes.orderDetail, page: () => const OrderDetailScreen(), binding: OrderBinding()),
    GetPage(name: AppRoutes.profile, page: () => const ProfileScreen(), binding: ProfileBinding()),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfileScreen(), binding: ProfileBinding()),
    GetPage(name: AppRoutes.changePassword, page: () => const ChangePasswordScreen(), binding: ProfileBinding()),
    GetPage(name: AppRoutes.address, page: () => const AddressBookScreen(), binding: ProfileBinding()),
    GetPage(name: AppRoutes.adminDashboard, page: () => const AdminDashboardScreen(), binding: AdminBinding()),
    GetPage(name: AppRoutes.aiAssistant, page: () => const AiAssistantScreen(), binding: AiAssistantBinding()),
    GetPage(name: AppRoutes.notifications, page: () => const NotificationScreen(), binding: NotificationBinding()),
  ];
}