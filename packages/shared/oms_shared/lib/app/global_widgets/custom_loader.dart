import '../core/values/colors.dart';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomLoaderWidget extends StatelessWidget {
  const CustomLoaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SpinKitCircle(color: ColorConstants.primaryColor, size: 50.0),
    );

    //     //ignored progress for the moment
  }
}
