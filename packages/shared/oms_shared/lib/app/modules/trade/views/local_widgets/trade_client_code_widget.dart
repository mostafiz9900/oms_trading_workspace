import '../../../../core/utils/extensions/app_context.dart';
import '../../../../core/values/space.dart';
import '../../../home/controllers/home_controller.dart';

import 'package:material_ui/material_ui.dart';
import 'package:getxify/getxify.dart';

class TradeClientCodeWidget extends StatelessWidget {
  const TradeClientCodeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration = BoxDecoration(
      border: Border.all(width: 1, color: context.borderSideColor),
      borderRadius: BorderRadius.circular(4),
    );
    return GetBuilder<HomeController>(
      id: 'user_balance_update',
      builder: (homeConBalance) {
        if (homeConBalance.userBalanceData == null) return const SizedBox();
        final user = homeConBalance.userBalanceData;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  decoration: decoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Client Code',
                        style: Get.context!.textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        homeConBalance.userInfo.userDetail?.investorCode ?? "",
                        style: Get.context!.textTheme.titleLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpace.spaceW10,
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  decoration: decoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balance',
                        style: Get.context!.textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'BDT ${double.parse('${user?.amount ?? 0}').toStringAsFixed(2)}',
                        maxLines: 1,
                        style: Get.context!.textTheme.titleLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
