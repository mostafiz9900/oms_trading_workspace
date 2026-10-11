import 'package:get/get.dart';

import '../../app_pkg.dart';

sealed class Result2<T> {
  const Result2._();

  factory Result2.success(T value) = Success<T>;
  factory Result2.error(ApiError error) = Error<T>;
}

class Success<T> extends Result2<T> {
  final T value;
  const Success(this.value) : super._();
}

class Error<T> extends Result2<T> {
  final ApiError error;
  const Error(this.error) : super._();
}

class ApiError {
  final String message;
  ApiError(this.message);
}

class MyController extends GetxController {
  getResult() async {
    final AuthController cont = Get.put(AuthController(authRepository: Get.find()));
    // var result2 = await cont.login(Get.overlayContext!);
    var result2 = await Future.delayed(Duration.zero, () {
      Result2.success("value");
    });
    result2.when(value: "", error: "");
  }
}
