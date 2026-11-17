import 'package:material_ui/material_ui.dart';
import 'package:getxify/getxify.dart';

import '../../../../core/utils/extensions/app_context.dart';
import '../../../../core/values/space.dart';

class TitleAndSubTitleColumWidget extends StatelessWidget {
  const TitleAndSubTitleColumWidget({
    super.key,
    required this.titleText,
    this.subTitle,
    this.crossAxisAlignment,
    this.subTitle2,
  });
  final String titleText;
  final String? subTitle;
  final CrossAxisAlignment? crossAxisAlignment;
  final String? subTitle2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment ?? .start,
      mainAxisAlignment: .center,
      children: [
        Text(
          titleText,
          textAlign: TextAlign.center,
          style: Get.context!.textTheme.titleLarge?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: context.textColor,
          ),
        ),
        AppSpace.spaceH4,
        Visibility(
          visible: subTitle != null,
          child: Text(
            subTitle ?? "",
            style: Get.context!.textTheme.bodyLarge?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: context.textColor,
            ),
          ),
        ),
        AppSpace.spaceH2,
        Visibility(
          visible: subTitle2 != null,
          child: Text(
            subTitle2 ?? '',
            style: Get.context!.textTheme.bodyLarge?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: context.textColor,
            ),
          ),
        ),
      ],
    );
  }
}
