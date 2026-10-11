import '/app/app_pkg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';


class CommonWidget {
  static AppBar appBar(
    BuildContext context,
    String title,
    IconData? backIcon,
    Color color, {
    void Function()? callback,
  }) {
    return AppBar(
      leading: backIcon == null
          ? null
          : IconButton(
              icon: Icon(backIcon, color: color),
              onPressed: () {
                if (callback != null) {
                  callback();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(color: color, fontFamily: 'Rubik'),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
    );
  }

  static Widget buySell({
    required VoidCallback onTap,
    double fontSize = 14,
    Color? buyColor,
    Color? sellColor,
    EdgeInsets padding = const .only(right: 10),
    BuildContext? context,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: RichText(
          text: TextSpan(
            text: "Buy",
            style: Get.textTheme.bodySmall?.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              color: buyColor ?? ColorConstants.success,
            ),
            children: [
              TextSpan(
                text: '/',
                style: Get.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: fontSize,
                  color: context != null ? context.textColor : Colors.black,
                ),
              ),
              TextSpan(
                text: 'Sell',
                style: Get.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: fontSize,
                  color: sellColor ?? ColorConstants.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static SizedBox rowHeight({double height = 30}) {
    return SizedBox(height: height);
  }

  static SizedBox rowWidth({double width = 30}) {
    return SizedBox(width: width);
  }

  static void toast(String error) async {
    await Fluttertoast.showToast(
      msg: error,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  static BoxDecoration customCircularDecoration(BuildContext context, Color? color, double value) {
    return BoxDecoration(color: color, borderRadius: BorderRadius.circular(value));
  }
}

class CustomSvgIcon extends StatelessWidget {
  final String assetName;
  final double size;
  final Color? color;

  const CustomSvgIcon({super.key, required this.assetName, this.size = 24.0, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        assetName,
        width: size,
        height: size,
        colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
        fit: BoxFit.contain,
      ),
    );
  }
}

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Consumer(
        builder: (context, ref, child) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            backgroundColor: context.bgColor,
            child: Padding(
              padding: const .all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.logout, size: 50, color: Colors.red),
                  const SizedBox(height: 15),
                  const Text("Logout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text(
                    "Are you sure you want to log out?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: .end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red[300]),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Cancel", style: Get.textTheme.bodyMedium!.copyWith(color: Colors.white)),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: context.buttonColor),
                        onPressed: () async {
                          Get.back();
                          Get.find<HomeController>().logout(context);
                        },
                        child: Text("Logout", style: Get.textTheme.bodyMedium!.copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

