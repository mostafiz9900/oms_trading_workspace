import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import 'app_pkg.dart';

final getConnectionProvider = Provider<GetConnect>((ref) {
  var connect = GetConnect(timeout: const Duration(seconds: 500))..baseUrl = AppConfig.baseUrl;
  return connect;
});

final orderTypeProvider = Provider<List<String>>((Ref ref) {
  var result = ['Limit', 'Market', 'Market At Based'];
  return result;
});
final validityProvider = Provider<List<String>>((ref) {
  var result = ['Day', 'FOK', 'IOC', 'Session'];
  return result;
});
final typeProvider = Provider<List<String>>((ref) {
  var result = ['Placed', 'Park', 'Unpark'];
  return result;
});
