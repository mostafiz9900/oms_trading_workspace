import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/utils/helpers/log_helper.dart';

void responseInterceptor(Response<dynamic> response) {
  printLog(
    'Response received for ${response.requestOptions.uri}: ${response.statusCode}',
  );
  responseLogger(response);
}

void responseErrorInterceptor(DioException error) {
  printLog(
    'Request failed for ${error.requestOptions.uri}: '
    '${error.response?.statusCode ?? error.message}',
  );
}

void responseLogger(Response<dynamic> response) {
  debugPrint('Status Code: ${response.statusCode}');
}
