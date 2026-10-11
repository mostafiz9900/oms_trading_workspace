import 'package:get/get.dart';
import 'package:oms_shared/app/routes/app_routes.dart';
import 'package:oms_shared/bootstrap.dart';
import 'package:oms_shared/app/modules/app_network/bindings/app_network_binding.dart';
import 'package:oms_shared/app/modules/app_network/views/app_network_view.dart';
import 'package:oms_shared/app/modules/auth/bindings/auth_binding.dart';
import 'package:oms_shared/app/modules/auth/views/login_view.dart';
import 'package:oms_shared/app/modules/contact_us/bindings/contact_us_binding.dart';
import 'package:oms_shared/app/modules/contact_us/views/contact_us_view.dart';
import 'package:oms_shared/app/modules/home/bindings/home_binding.dart';
import 'package:oms_shared/app/modules/home/views/home_view.dart';
import 'package:oms_shared/app/modules/limit_request/bindings/limit_request_binding.dart';
import 'package:oms_shared/app/modules/limit_request/views/limit_request_view.dart';
import 'package:oms_shared/app/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:oms_shared/app/modules/onboarding/views/onboarding_view.dart';
import 'package:oms_shared/app/modules/order_alert/bindings/order_alert_binding.dart';
import 'package:oms_shared/app/modules/order_alert/views/order_alert_view.dart';
import 'package:oms_shared/app/modules/search_watch_list/bindings/search_watch_list_binding.dart';
import 'package:oms_shared/app/modules/search_watch_list/views/search_watch_list_view.dart';
import 'package:oms_shared/app/modules/splash/bindings/splash_binding.dart';
import 'package:oms_shared/app/modules/splash/views/splash_view.dart';
import 'package:oms_shared/app/modules/top_share/bindings/top_share_binding.dart';
import 'package:oms_shared/app/modules/top_share/views/top_share_view.dart';
import 'package:oms_shared/app/modules/withdrawal_request/bindings/withdrawal_request_binding.dart';
import 'package:oms_shared/app/modules/withdrawal_request/views/withdrawal_request_view.dart';

class AppPages {
  AppPages._();

  static final INITIAL = initScreen == 0 ? Routes.ONBOARDING : Routes.SPLASH;

  static final routes = [
    GetPage(name: Routes.LOGIN, page: () => const LoginView(), binding: AuthBinding()),
    GetPage(name: Routes.HOME, page: () => const HomeView(), binding: HomeBinding()),
    GetPage(name: Routes.SPLASH, page: () => const SplashView(), binding: SplashBinding()),
    GetPage(name: Routes.APP_NETWORK, page: () => const AppNetworkView(), binding: AppNetworkBinding()),
    GetPage(name: Routes.ONBOARDING, page: () => const OnboardingView(), binding: OnboardingBinding()),
    GetPage(name: Routes.TOP_SHARE, page: () => const TopShareView(), binding: TopShareBinding()),
    GetPage(name: Routes.SEARCH_WATCH_LIST, page: () => const SearchWatchListView(), binding: SearchWatchListBinding()),
    GetPage(name: Routes.CONTACT_US, page: () => const ContactUsView(), binding: ContactUsBinding()),
    GetPage(name: Routes.ORDER_ALERT, page: () => const OrderAlertView(), binding: OrderAlertBinding()),
    GetPage(name: Routes.LIMIT_REQUEST, page: () => const LimitRequestView(), binding: LimitRequestBinding()),
    GetPage(
      name: Routes.WITHDRAWAL_REQUEST,
      page: () => const WithdrawalRequestView(),
      binding: WithdrawalRequestBinding(),
    ),
  ];
}
