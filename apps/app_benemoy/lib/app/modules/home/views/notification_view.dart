import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../app_pkg.dart';

import 'local_widgets/quote_tab_widget.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'News',
        isBackButtonIcon: true,
        backButtonOnClick: () => Get.back(),
        right: SizedBox(),
      ),
      body: GetBuilder<HomeController>(
        id: AppConfig.newsTimeSalesSocketId,
        // tag: 'home',
        builder: (controller) {
          if (controller.news.isEmpty) {
            return const Center(child: Text('No notifications yet'));
          }

          return ListView.separated(
            itemCount: controller.news.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: context.dividerColor),
            padding: .zero,
            itemBuilder: (context, index) {
              // final NewsModel? model = controller.news[index];
              NewsModel? model = controller.news[index];
              return model.tl == null ? SizedBox() : NewsItemWidget(model: model);
              // Container(
              //     padding: const .symmetric(horizontal: 10, vertical: 10),
              //     // color: model.seen == true ? Colors.white : ColorConstants.containerSecondLight,
              //     child: InkWell(
              //       onTap: () {
              //         printLog('mode: ${model.toMap()}');
              //         printLog('mode: ${model.nt}');
              //         showNewsBottomSheet(context, model);
              //       },
              //       child: Column(
              //         children: [
              //           Row(
              //             crossAxisAlignment: .start,
              //             mainAxisAlignment: .start,
              //             children: [
              //               Container(
              //                 width: 46,
              //                 height: 43,
              //                 padding: const .all(10),
              //                 decoration: BoxDecoration(
              //                   color: ColorConstants.buttonColorLight,
              //                   borderRadius: BorderRadius.circular(4),
              //                 ),
              //                 child: SvgPicture.asset(AssetsConstants.alertIconSvg, width: 20, height: 23),
              //               ),
              //               AppSpace.spaceW8,
              //               Flexible(
              //                 child: Column(
              //                   crossAxisAlignment: .start,
              //                   children: [
              //                     Text(
              //                       model.tl ?? "",
              //                       maxLines: 2,
              //                       overflow: TextOverflow.ellipsis,
              //                       style: Get.textTheme.bodyLarge?.copyWith(),
              //                     ),
              //                     AppSpace.spaceH6,
              //                     if (model.dt != null) ...[
              //                       Text(
              //                         Helpers.getTimeAgoFromDateTime('${model.dt}', '${model.t}'),
              //                         style: Get.textTheme.bodySmall?.copyWith(),
              //                       ),
              //                     ],
              //                   ],
              //                 ),
              //               ),
              //             ],
              //           ),
              //           // AppSpace.spaceH10,
              //           // Divider(height: 1, color: hexToColor('#DADADA')),
              //         ],
              //       ),
              //     ),
              //   );
            },
          );
        },
      ),
    );
  }
}
