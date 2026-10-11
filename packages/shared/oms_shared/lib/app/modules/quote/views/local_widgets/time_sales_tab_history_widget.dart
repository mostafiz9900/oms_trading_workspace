import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app_pkg.dart';
import '../../../../global_widgets/empty_widget.dart';

class TimeSalesTabHistoryWidget extends StatelessWidget {
  const TimeSalesTabHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: 'timeAndSalesHistory',
      initState: (_) {
      },
      builder: (homeCon) {
        return Column(
          children: [
            AppSpace.spaceH10,
            Container(
              height: 38,
              padding: const .symmetric(horizontal: 12),
              decoration: BoxDecoration(color: context.tapBg),
              child: const Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: _TableTitleTextWidget(title: 'Price', textAlign: TextAlign.center),
                  ),
                  Expanded(
                    flex: 3,
                    child: _TableTitleTextWidget(title: 'Volume', textAlign: TextAlign.center),
                  ),
                  Expanded(
                    flex: 2,
                    child: _TableTitleTextWidget(title: 'Trades', textAlign: TextAlign.center),
                  ),
                  Expanded(
                    flex: 3,
                    child: _TableTitleTextWidget(title: 'Value', textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
            AppSpace.spaceH10,
            Expanded(
              child: homeCon.timeAndSalesHistory == []
                  ? const CustomLoaderWidget()
                  : homeCon.timeAndSalesHistory.isEmpty
                  ? EmptyWidget()
                  : ListView.builder(
                      itemCount: homeCon.timeAndSalesHistory.length,
                      itemBuilder: (context, index) {
                        final reverseIndex = homeCon.timeAndSalesHistory.length - 1 - index;
                        final model = homeCon.timeAndSalesHistory[reverseIndex];
                        return Container(
                          padding: const .symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: index % 2 == 0 ? context.evenColor : context.oddColor),
                          child: Row(
                            mainAxisAlignment: .spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _TableTitleTextWidget(title: '${model.p ?? ''}', textAlign: TextAlign.center),
                              ),
                              Expanded(
                                flex: 3,
                                child: _TableTitleTextWidget(
                                  title: NumberFormatter.bdFormat(model.v ?? 0.0, decimalPlaces: 0),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: _TableTitleTextWidget(
                                  title:
                                      model.tds ?? "",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: _TableTitleTextWidget(
                                  title: NumberFormatter.croreFormat('${model.vl ?? 0.0}'),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _TableTitleTextWidget extends StatelessWidget {
  const _TableTitleTextWidget({required this.title, this.textAlign});
  final String title;
  final TextAlign? textAlign;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: textAlign,
      style: Get.textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
    );
  }
}
