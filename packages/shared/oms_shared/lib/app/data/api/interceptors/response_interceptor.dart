import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';

FutureOr<dynamic> responseInterceptor(Request request, Response response) async {
  print('Response received for ${request.url}: ${response.statusCode}');
  responseLogger(response);

  return response;
}

void handleErrorStatus(Response response) {
  switch (response.statusCode) {
    case 400:
      break;
    default:
  }

  return;
}

void responseLogger(Response response) {
  debugPrint('Status Code: ${response.statusCode}\n');
  debugPrint('Data: ${response.bodyString?.toString() ?? ''}');
}
