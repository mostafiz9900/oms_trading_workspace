import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app_pkg.dart';

import '../../quote/views/local_widgets/quote_tab_widget.dart';

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
        builder: (controller) {
          if (controller.news.isEmpty) {
            return const Center(child: Text('No notifications yet'));
          }

          return ListView.separated(
            itemCount: controller.news.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: context.dividerColor),
            padding: .zero,
            itemBuilder: (context, index) {
              NewsModel? model = controller.news[index];
              return model.tl == null ? SizedBox() : NewsItemWidget(model: model);
            },
          );
        },
      ),
    );
  }
}
