import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import '../../../core/utils/helpers/log_helper.dart';

FutureOr<dynamic> responseInterceptor(Request request, Response response) async {
  printLog('Response received for ${request.url}: ${response.statusCode}');
  responseLogger(response);

  return response;
}

void responseLogger(Response response) {
  debugPrint('Status Code: ${response.statusCode}\n');
  debugPrint('Data: ${response.bodyString?.toString() ?? ''}');
}
