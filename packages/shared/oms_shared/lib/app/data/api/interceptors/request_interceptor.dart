import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/values/storage.dart';
import '../../services/storage_service.dart';

Future<void> requestInterceptor(RequestOptions request) async {
  final token = await StorageService.read(StorageConstants.token);
  if (token != null && token.toString().isNotEmpty) {
    request.headers['Authorization'] = 'Bearer $token';
  }
  requestLogger(request);
}

void requestLogger(RequestOptions request) {
  debugPrint('Url: ${request.method} ${request.uri}');
}
