export '../app/core/core.dart';
export '../app/data/data.dart';
export '../app/global_widgets/global_widgets.dart';
export '../app/modules/modules.dart';
export '../main.dart';
export 'app_binding.dart';
export 'di.dart';
export 'my_app.dart';
export 'routes/routes.dart';
export 'global_provider.dart';

const kLOGTAG = "[benemoy]";
const kLOGENABLE = true;

void printLog(dynamic data) {
  if (kLOGENABLE) {
    print("$kLOGTAG:👍 ⚖️ ${data.toString()}");
    // log('benemoy:: ${data.toString()}');
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
