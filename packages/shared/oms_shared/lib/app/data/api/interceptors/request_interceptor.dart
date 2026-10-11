import 'dart:async';

import '../../../core/values/storage.dart';
import '../../services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/request/request.dart';

FutureOr<Request> requestInterceptor(request) async {
  final token = await StorageService.read(StorageConstants.token);
  if (token != null) {
    request.headers['Authorization'] = 'Bearer $token';
  }
  requestlLogger(request);
  return request;
}

void requestlLogger(Request request) {
  debugPrint('Url: ${request.method} ${request.url}\n');
}
