import 'package:get/get.dart';

import '../../main.dart';
import '../modules/app_network/bindings/app_network_binding.dart';
import '../modules/app_network/views/app_network_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/contact_us/bindings/contact_us_binding.dart';
import '../modules/contact_us/views/contact_us_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/limit_request/bindings/limit_request_binding.dart';
import '../modules/limit_request/views/limit_request_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/order_alert/bindings/order_alert_binding.dart';
import '../modules/order_alert/views/order_alert_view.dart';
import '../modules/search_watch_list/bindings/search_watch_list_binding.dart';
import '../modules/search_watch_list/views/search_watch_list_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/top_share/bindings/top_share_binding.dart';
import '../modules/top_share/views/top_share_view.dart';
import '../modules/withdrawal_request/bindings/withdrawal_request_binding.dart';
import '../modules/withdrawal_request/views/withdrawal_request_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final INITIAL = initScreen == 0 ? Routes.ONBOARDING : Routes.SPLASH;

  static final routes = [
    GetPage(name: _Paths.LOGIN, page: () => const LoginView(), binding: AuthBinding()),
    GetPage(name: _Paths.HOME, page: () => const HomeView(), binding: HomeBinding()),
    GetPage(name: _Paths.SPLASH, page: () => const SplashView(), binding: SplashBinding()),
    GetPage(name: _Paths.APP_NETWORK, page: () => const AppNetworkView(), binding: AppNetworkBinding()),
    GetPage(name: _Paths.ONBOARDING, page: () => const OnboardingView(), binding: OnboardingBinding()),
    GetPage(name: _Paths.TOP_SHARE, page: () => const TopShareView(), binding: TopShareBinding()),
    GetPage(name: _Paths.SEARCH_WATCH_LIST, page: () => const SearchWatchListView(), binding: SearchWatchListBinding()),
    GetPage(name: _Paths.CONTACT_US, page: () => const ContactUsView(), binding: ContactUsBinding()),
    GetPage(name: _Paths.ORDER_ALERT, page: () => const OrderAlertView(), binding: OrderAlertBinding()),
    GetPage(name: _Paths.LIMIT_REQUEST, page: () => const LimitRequestView(), binding: LimitRequestBinding()),
    GetPage(
      name: _Paths.WITHDRAWAL_REQUEST,
      page: () => const WithdrawalRequestView(),
      binding: WithdrawalRequestBinding(),
    ),
  ];
}
