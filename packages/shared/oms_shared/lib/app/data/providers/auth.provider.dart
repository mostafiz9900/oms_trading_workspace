import 'dart:convert';

import 'package:oms_shared/app/app_pkg.dart';
import 'package:get/get.dart';

import '../data.dart';

class AuthProvider extends BaseProvider {
  Future<Response> login(String path, LoginRequest data) {
    return post(path, data.toJson());
  }

  Future<Response> loginBiometric(String path, String bioTokent) {
    var body = {'b': bioTokent};
    printLog('body ::::::::: $body');
    return post(path, body);
  }

  Future<Response> register(String path, data) {
    return post(path, jsonEncode(data));
  }

  Future<Response> verifyBoiId(String path, data) {
    return post(path, jsonEncode(data));
  }

  Future<Response> selectMedia(String path, data) {
    return post(path, jsonEncode(data));
  }

  Future<Response> verifyMedia(String path, data) {
    return post(path, jsonEncode(data));
  }

  Future<Response> verifyOtp(String path, data) {
    return post(path, jsonEncode(data));
  }

  Future<Response> verifyOtpForgot(String path, data) {
    return post(path, jsonEncode(data));
  }

  Future<Response> resetPassword(String path, data) {
    return put(path, jsonEncode(data));
  }

  Future<Response> forgotPassword(String path, data) {
    return post(path, jsonEncode(data));
  }

  Future<Response> getUsers(String path) {
    return get(path);
  }
}
