// fvm flutter build appbundle -t lib/main_prod.dart --flavor benemoy \
//   --dart-define-from-file=config/houses/benemoy-prod.json
import 'package:oms_shared/oms_shared.dart';

import 'src/run.dart';

void main() => runBenemoy(OmsEnvironment.prod);
