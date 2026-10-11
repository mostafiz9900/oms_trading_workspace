import 'dart:io';

import 'package:get_storage/get_storage.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Points path_provider at a temp folder so GetStorage (and StorageService)
/// work in tests exactly as on a device. Call from `setUpAll`.
Future<void> initTestStorage() async {
  final dir = await Directory.systemTemp.createTemp('oms_storage_test');
  PathProviderPlatform.instance = _TempPathProvider(dir.path);
  await GetStorage.init();
}

/// Empties the default GetStorage box between tests.
Future<void> clearTestStorage() => GetStorage().erase();

class _TempPathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _TempPathProvider(this.path);
  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}
