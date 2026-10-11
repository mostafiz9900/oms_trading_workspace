import 'dart:async';

import 'package:oms_shared/app/app_pkg.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/request/request.dart';

FutureOr<Request> requestInterceptor(request) async {
  final token = await StorageService.read(StorageConstants.token);
  if (token != null) {
    request.headers['Authorization'] = 'Bearer $token';
  }
  // request.headers['X-Requested-With'] = 'XMLHttpRequest';
  // EasyLoading.show(status: 'loading...');
  requestlLogger(request);
  return request;
}

void requestlLogger(Request request) {
  debugPrint('Url: ${request.method} ${request.url}\n');
}
