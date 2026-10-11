// fvm flutter run -t lib/main_uat.dart \
//   --dart-define-from-file=config/houses/benemoy-uat.json
import 'package:oms_shared/oms_shared.dart';

import 'src/run.dart';

void main() => runBenemoy(OmsEnvironment.uat);
