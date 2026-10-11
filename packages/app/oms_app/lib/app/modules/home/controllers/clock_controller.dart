import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

final clockProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

class ClockController extends GetxController {
  var currentTime = ''.obs;
  late Timer _timer;

  @override
  void onInit() {
    super.onInit();
    _updateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final formatted = DateFormat('EEE, dd MMM, yy, hh:mm:ss a').format(now);
    currentTime.value = formatted;
  }

  @override
  void onClose() {
    _timer.cancel();
    super.onClose();
  }
}
