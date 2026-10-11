import 'package:flutter/foundation.dart';
import 'core/values/app_config.dart';

export '../app/core/core.dart';
export '../app/data/data.dart';
export '../app/global_widgets/global_widgets.dart';
export '../app/modules/modules.dart';
export '../bootstrap.dart';
export 'app_binding.dart';
export 'di.dart';
export 'routes/routes.dart';
export 'global_provider.dart';

String get kLOGTAG => "[${AppConfig.houseId}]";
// Logs only in debug builds; release builds skip formatting and printing.
const kLOGENABLE = kDebugMode;

void printLog(dynamic data) {
  if (kLOGENABLE) {
    print("$kLOGTAG:👍 ⚖️ ${data.toString()}");
  }
}

void printWrapped(String? text) {
  if (text == null || text.isEmpty) {
    print("⚠️ printWrapped: EMPTY OR NULL TEXT");
    return;
  }

  const chunkSize = 800;
  final pattern = RegExp('.{1,$chunkSize}', dotAll: true);

  int index = 0;
  for (final match in pattern.allMatches(text)) {
    print("🔹 [$index] ${match.group(0)}");
    index++;
  }
}
