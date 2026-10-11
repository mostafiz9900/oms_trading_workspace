import 'package:oms_shared/app/app_pkg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomLoaderWidget extends StatelessWidget {
  const CustomLoaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SpinKitCircle(color: ColorConstants.primaryColor, size: 50.0),
    );

    //     //ignored progress for the moment
  }
}
