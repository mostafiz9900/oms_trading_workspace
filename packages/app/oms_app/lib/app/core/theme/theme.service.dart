import 'package:oms_app/app/app_pkg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeServices extends GetxService {
  final _storage = GetStorage();
  final _key = StorageConstants.isDarkMode;

  // Get the current theme mode (light/dark)
  ThemeMode getThemeMode() {
    return _storage.read(_key) == true ? ThemeMode.dark : ThemeMode.light;
  }

  // Toggle the theme mode and save it to GetStorage
  void toggleTheme() {
    bool isDarkMode = _storage.read(_key) ?? false;
    _storage.write(_key, !isDarkMode);
    Get.changeThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }
}
