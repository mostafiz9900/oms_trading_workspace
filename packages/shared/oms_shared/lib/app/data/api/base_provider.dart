import 'package:get/get.dart';

import '../../core/utils/helpers/log_helper.dart';
import '../../core/values/app_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/request_interceptor.dart';
import 'interceptors/response_interceptor.dart';

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
