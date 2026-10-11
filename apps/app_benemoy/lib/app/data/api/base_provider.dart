import 'package:get/get.dart';

import '../../app_pkg.dart';

class BaseProvider extends GetConnect {
  @override
  void onInit() {
    printLog('base provider initialized');
    httpClient.baseUrl = AppConfig.baseUrl;
    httpClient.addAuthenticator(authInterceptor);
    httpClient.addRequestModifier(requestInterceptor);
    httpClient.addResponseModifier(responseInterceptor);
  }
}
