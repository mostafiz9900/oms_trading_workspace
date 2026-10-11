import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'languages/bn_bd.dart';
import 'languages/en_us.dart';

//Worker use backround task
class LocalizationService extends Translations {
  static const Locale fallbackLocale = Locale('en', 'US');
  /// Parses a locale tag such as `en_US` or `bn_BD`.
  static Locale parseLocale(String tag) {
    final parts = tag.split('_');
    return Locale(parts.first, parts.length > 1 ? parts[1] : '');
  }

  Map<String, Map<String, String>> get translations => {
    'bn_BD': BnLanguage().bnLanguage,
    'en_US': EnLanguage().enLanguage,
  };

  @override
  Map<String, Map<String, String>> get keys => translations;
}
