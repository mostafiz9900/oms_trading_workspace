
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  static final _box = GetStorage();

  static Future<void> save(String key, dynamic value) async {
    await _box.write(key, value);
  }

  // Function to retrieve a value by its key
  static Future<dynamic> read(String key) async {
    return await _box.read(key);
  }

  /// Synchronous read, for values needed while a service is constructed.
  static T? readSync<T>(String key) => _box.read<T>(key);

  // Function to remove a value by its key
  static void remove(String key) {
    _box.remove(key);
  }

  // Save Map
  static Future<void> saveMap(String key, Map<String, dynamic> map) async {
    await _box.write(key, map);
  }

  // Get Map
  static Map<String, dynamic>? getMap(String key) {
    return _box.read(key);
  }
}
