import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/extensions/app_context.dart';
import '../../../../core/values/dimens.dart';

class CreateNewAccount extends StatelessWidget {
  const CreateNewAccount({
    super.key,
    this.color,
    required this.recognizer,
    this.titleOne,
    this.titleTwo,
    this.alignment,
  });
  final GestureRecognizer? recognizer;
  final String? titleOne, titleTwo;
  final AlignmentGeometry? alignment;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment ?? Alignment.centerRight,
      padding: const .only(right: 10),
      child: RichText(
        text: TextSpan(
          text: titleOne ?? "",
          style: Get.textTheme.titleSmall!.copyWith(
            color: context.textColor,
            fontSize: AppDimens.fontSizeMedium,
            fontWeight: FontWeight.normal,
          ),
          children: [
            TextSpan(
              recognizer: recognizer,
              text: titleTwo ?? ' Already have an account? ',
              style: Get.textTheme.titleSmall!.copyWith(
                color: context.textColor,
                fontSize: AppDimens.fontSizeMedium,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
