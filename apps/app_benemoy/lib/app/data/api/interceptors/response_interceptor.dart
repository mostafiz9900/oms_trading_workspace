import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';

FutureOr<dynamic> responseInterceptor(Request request, Response response) async {
  print('Response received for ${request.url}: ${response.statusCode}');
  // EasyLoading.dismiss();
  responseLogger(response);
  // if (response.statusCode != 200) {
  //   handleErrorStatus(response);
  //   return;
  // }

  return response;
}

void handleErrorStatus(Response response) {
  switch (response.statusCode) {
    case 400:
      // final message = ErrorResponse.fromJson(response.body);
      // CommonWidget.toast(message.error);
      break;
    default:
  }

  return;
}

void responseLogger(Response response) {
  debugPrint('Status Code: ${response.statusCode}\n');
  debugPrint('Data: ${response.bodyString?.toString() ?? ''}');
}
