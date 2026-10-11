import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://itch-chart.skytrade.us',
      connectTimeout: Duration(seconds: 5000),
      receiveTimeout: Duration(seconds: 3000),
    ),
  );
});
