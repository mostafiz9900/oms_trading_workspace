import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/extensions/app_context.dart';
import '../../../core/values/app_config.dart';
import '../../../data/models/response/news_model.dart';
import '../../../global_widgets/custom_app_bar.dart';
import '../../home/controllers/home_controller.dart';

import '../../quote/views/local_widgets/news_item_widget.dart';

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
            separatorBuilder: (_, _) => Divider(height: 1, color: context.dividerColor),
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
