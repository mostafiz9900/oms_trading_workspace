import 'package:material_ui/material_ui.dart';
import 'package:getxify/getxify.dart';

import '../../../../core/utils/extensions/app_context.dart';
import '../../../../core/utils/extensions/date_time_extensions.dart';
import '../../../../core/utils/helpers/app_helper.dart';
import '../../../../core/utils/helpers/log_helper.dart';
import '../../../../data/models/response/news_model.dart';

class NewsItemWidget extends StatelessWidget {
  final NewsModel model;
  const NewsItemWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    printLog('model news: ${model.toMap()}');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((model.tl ?? "").isNotEmpty)
            Text(
              model.tl!,
              style: Get.context!.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: context.buttonColor,
              ),
            ),
          if (model.dt != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  Helpers.getTimeAgoFromDateTime('${model.dt}', '${model.t}'),
                  style: Get.context!.textTheme.bodySmall,
                ),
                Text(
                  "${model.dt?.standardDate}",
                  style: Get.context!.textTheme.bodySmall,
                ),
              ],
            ),
          ],
          if ((model.nt ?? "").isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              model.nt!,
              textAlign: TextAlign.justify,
              style: Get.context!.textTheme.bodyMedium?.copyWith(
                color: context.textColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
