import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../app_pkg.dart';
import 'package:get/get.dart';

class NewsView extends StatelessWidget {
  const NewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(isBackButtonIcon: true, titleText: 'News', right: Text("")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppSpace.spaceH16,
            Container(
              alignment: Alignment.centerLeft,
              height: 45,
              padding: const .symmetric(horizontal: 10),
              width: Get.width,
              decoration: BoxDecoration(color: ColorConstants.containerSecondLight),
              child: Text(
                'News & Announcements',
                textAlign: TextAlign.center,
                style: Get.textTheme.titleLarge?.copyWith(color: context.buttonColor, fontSize: 17),
              ),
            ),
            AppSpace.spaceH20,
            _NewsWidget(),
          ],
        ),
      ),
    );
  }
}

class _NewsWidget extends StatelessWidget {
  const _NewsWidget();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: "news",
      builder: (homeCon) {
        return homeCon.news == []
            ? const CustomLoaderWidget()
            : ListView.builder(
                itemCount: homeCon.news.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  NewsModel? model = homeCon.news.elementAt(index);
                  return model.tl == null
                      ? SizedBox()
                      : Container(
                          padding: const .symmetric(horizontal: 10, vertical: 10),
                          // color: model.seen == true ? Colors.white : ColorConstants.containerSecondLight,
                          child: InkWell(
                            onTap: () {
                              printLog('mode: ${model.toMap()}');
                              printLog('mode: ${model.nt}');
                              showNewsBottomSheet(context, model);
                            },
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: .start,
                                  mainAxisAlignment: .start,
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 43,
                                      padding: const .all(10),
                                      decoration: BoxDecoration(
                                        color: ColorConstants.buttonColorLight,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: SvgPicture.asset(AssetsConstants.alertIconSvg, width: 20, height: 23),
                                    ),
                                    AppSpace.spaceW8,
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: .start,
                                        children: [
                                          Text(
                                            model.tl ?? "",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Get.textTheme.bodyLarge?.copyWith(),
                                          ),
                                          AppSpace.spaceH6,
                                          if (model.dt != null) ...[
                                            Text(
                                              '${Helpers.calculateTimeDifferenceBetween(startDate: DateTime.parse('${model.dt}'))} Ago',
                                              style: Get.textTheme.bodySmall?.copyWith(),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                AppSpace.spaceH10,
                                Divider(height: 1, color: hexToColor('#DADADA')),
                              ],
                            ),
                          ),
                        );
                },
              );
      },
    );
  }

  void showNewsBottomSheet(BuildContext context, NewsModel news) {
    Get.bottomSheet(
      Container(
        padding: const .all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                mainAxisAlignment: .start,
                crossAxisAlignment: .start,
                children: [
                  Expanded(
                    child: Text(news.tl ?? "", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 24, color: Colors.red),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text("Date: ${news.dt}"),
              Text("Time: ${news.t}"),
              Text("News ID: ${news.nid}"),
              Text("FID: ${news.fid}"),
              const Divider(height: 20),
              Text(news.nt ?? "", style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
      isDismissible: false,
    );
  }
}
