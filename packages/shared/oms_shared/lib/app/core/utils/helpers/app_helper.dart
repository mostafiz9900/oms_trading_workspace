import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:crypto/crypto.dart' as crypto_info;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../extensions/app_context.dart';
import 'hex_color.dart';
import 'log_helper.dart';
import '../../values/app_config.dart';
import '../../values/colors.dart';
import '../../values/dimens.dart';
import '../../values/space.dart';
import '../../values/storage.dart';
import '../../../data/models/response/user_profile.dart';
import '../../../data/services/storage_service.dart';
import '../../../routes/app_routes.dart';

final uuid = Uuid();

class Helpers {
  Helpers._();
  static String get _uniqueKey => "${AppConfig.houseId}_app";
  static final Uuid _uuid = Uuid();
  static final Random _random = Random.secure();
  static Future<String> getDeviceIdUuid() async {
    String? deviceId = await StorageService.read(StorageConstants.deviceIdKey);
    if (deviceId == null) {
      deviceId = uuid.v4();
      await StorageService.save(StorageConstants.deviceIdKey, deviceId);
    }
    return deviceId;
  }

  static Future<String> getSecureDeviceIdLogin() async {
    // Missing key → empty id (the server rejects it) instead of a TypeError.
    String deviceId = await StorageService.read(StorageConstants.deviceSecIdKey) ?? '';
    printLog('shat key:: $deviceId');
    return deviceId;
  }

  static Future<String?> getSecureDeviceId() async {
    String? deviceId = await StorageService.read(StorageConstants.deviceSecIdKey);
    var res = StorageService.getMap(StorageConstants.userInfo);
    if (deviceId == null && res != null) {
      UserProfile? user = UserProfile.fromJson(res);
      // Generate UUID
      final uuidPart = _uuid.v4();
      // Generate random bytes
      final randomBytes = List<int>.generate(16, (_) => _random.nextInt(256));
      final randomPart = base64Url.encode(randomBytes);
      // Current timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      // Combine all parts with the secret key
      final combined = "${user.id}$uuidPart$randomPart$timestamp$_uniqueKey";
      // Hash with SHA-256
      final digest = crypto_info.sha256.convert(utf8.encode(combined)).toString();
      printLog('shat key:: $digest');
      // Save hashed device ID
      await StorageService.save(StorageConstants.deviceSecIdKey, digest);
      return digest;
    }
    printLog('shat key:: $deviceId');

    return deviceId;
  }

  static String formatTimeToString(String rawTime) {
    try {
      final parts = rawTime.split('.');
      final mainTime = parts[0]; // "13:23:34"
      return mainTime; // fraction part remove
    } catch (e) {
      return rawTime; // fallback
    }
  }

  static DateTime parseTst(String rawTime) {
    try {
      final now = DateTime.now();
      final dateStr =
          "${now.year.toString().padLeft(4, '0')}-"
          "${now.month.toString().padLeft(2, '0')}-"
          "${now.day.toString().padLeft(2, '0')} $rawTime";
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  static List<T> sortByTstDesc<T>(List<T> list, String Function(T) getTst) {
    // Parse each timestamp once, not twice per comparison.
    final keyed = [for (final e in list) (e, parseTst(getTst(e)))];
    keyed.sort((a, b) => b.$2.compareTo(a.$2)); // descending
    for (var i = 0; i < list.length; i++) {
      list[i] = keyed[i].$1;
    }
    return list;
  }

  // Check if biometric is enabled
  static Future<bool> isBiometricEnabled() async {
    final value = await StorageService.read(StorageConstants.biometricEnabled);
    return value == 'true';
  }

  static String? formatCustomDateTime({required String? rawDate, String outputPattern = 'yyyy-MM-dd hh:mm a'}) {
    if (rawDate == null || rawDate.isEmpty) return null;

    try {
      // Split by dash
      final parts = rawDate.split('-');
      if (parts.length != 2) return null;

      final datePart = parts[0]; // e.g., "20250728"
      final timePart = parts[1]; // e.g., "09:06:32.609"

      // Parse date
      final year = int.parse(datePart.substring(0, 4));
      final month = int.parse(datePart.substring(4, 6));
      final day = int.parse(datePart.substring(6, 8));

      // Parse time
      final timeWithMillis = timePart.split('.');
      final time = timeWithMillis[0].split(':');
      final hour = int.parse(time[0]);
      final minute = int.parse(time[1]);
      final second = int.parse(time[2]);
      final millisecond = timeWithMillis.length > 1 ? int.parse(timeWithMillis[1]) : 0;

      final dateTime = DateTime(year, month, day, hour, minute, second, millisecond);

      return DateFormat(outputPattern).format(dateTime);
    } catch (e) {
      return null;
    }
  }

  static String formatDouble(double value) {
    return value.toStringAsFixed(2);
  }

  static String? convertTimestampToLocalTime(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) {
      return null;
    }
    try {
      String formattedTimestamp = '${timestamp.replaceFirst('-', 'T')}Z';
      DateTime dateTimeUtc = DateTime.parse(formattedTimestamp);
      DateTime dateTimeLocal = dateTimeUtc.toLocal();
      String formattedLocalTime = DateFormat('hh:mm:ss a').format(dateTimeLocal);
      return formattedLocalTime;
    } catch (e) {
      printLog('Error parsing timestamp "$timestamp": $e');
      return null;
    }
  }

  static String getTimeAgoFromDateTime(String date, String time) {
    try {
      // Combine date and time into a full DateTime

      String cleanDate = date.split(' ').first.trim();
      DateTime dateTime = DateTime.parse("$cleanDate $time");
      // Calculate difference from now
      final diff = DateTime.now().difference(dateTime);

      if (diff.inDays > 0) {
        return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes} min ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      // Return fallback text if parse fails
      return 'Invalid date/time';
    }
  }

  static double? toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static void showCustomDialog(BuildContext context, {required Widget child}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'custom_dialog',
      barrierColor: Colors.black.withAlpha(128),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Center(
            child: Theme(data: Theme.of(context), child: child),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0), // 👈 ফিক্সড ব্লার (অ্যানিমেট হবে না)
            child: ScaleTransition(
              scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              child: child,
            ),
          ),
        );
      },
    );
  }

  static void customShowDialog(
    BuildContext context, {
    List<Widget>? children,
    String? title,
    double? fontSize,
    bool? barrierDismissible,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible ?? true,
      builder: (context) {
        final double screenHeight = MediaQuery.of(context).size.height;

        return Dialog(
          backgroundColor: context.bgColor, // Apnar extension theke ashbe
          insetPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.80, // সর্বোচ্চ ৮০% হাইট
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Title & Close Button ---
                Padding(
                  // Padding top ebon bottom aro komiye 4.0 kora holo
                  padding: const EdgeInsets.only(left: 16.0, right: 12.0, top: 4.0, bottom: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title ?? "Select Option",
                          style: Get.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: fontSize ?? 18,
                            color: context.titleTextAlertDialog, // Apnar extension theke ashbe
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero, // Default padding remove kora holo
                        constraints: const BoxConstraints(), // Default touch target constraint remove kora holo
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close_rounded, size: 22),
                        color: Colors.grey[600],
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, thickness: 1),

                // --- Content Area ---
                if (children != null && children.isNotEmpty)
                  Flexible(
                    child: Column(mainAxisSize: MainAxisSize.min, children: children),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String sha256(String text, int length) {
    var sha256 = crypto_info.sha256;
    List<int> bytes = utf8.encode(text);
    List<int> digest = sha256.convert(bytes).bytes;
    String hexString = digest.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    if (length < hexString.length) {
      return hexString.substring(0, length);
    } else {
      return hexString;
    }
  }

  static void snackbarForErorr({String? titleText, required String bodyText, double? topMargin}) {
    Get.snackbar(
      "",
      "",
      titleText: const SizedBox.shrink(),
      messageText: Text(
        bodyText,
        style: const TextStyle(color: Colors.white, fontSize: AppDimens.space15),
      ),
      snackPosition: SnackPosition.TOP,
      maxWidth: Get.width * 0.7,
      padding: const .only(
        bottom: AppDimens.space15,
        left: AppDimens.space12,
        right: AppDimens.space10,
        top: AppDimens.space5,
      ),
      margin: .only(top: AppDimens.space25, left: Get.width * 0.05, right: Get.width * 0.05),
      borderRadius: AppDimens.space4,
      backgroundColor: Colors.red.withAlpha((0.9 * 255).toInt()),
      colorText: Colors.white,
    );
  }

  static void toast(String error) async {
    await Fluttertoast.showToast(
      msg: error,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static void toastError(String error) async {
    await Fluttertoast.showToast(
      msg: error,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static void snackbarForErorr2({String? titleText, required String bodyText, double? topMargin}) {
    Get.snackbar(
      "",
      "",
      titleText: const SizedBox.shrink(),
      messageText: Text(bodyText, style: const TextStyle(color: Colors.white, fontSize: 15)),
      snackPosition: SnackPosition.TOP,
      maxWidth: Get.width * 0.7,
      padding: const .only(bottom: 15, left: 12, right: 10, top: 5),
      margin: .only(top: 25, left: Get.width * 0.05, right: Get.width * 0.05),
      borderRadius: 4,
      backgroundColor: Colors.red.withAlpha((0.9 * 255).toInt()),
      colorText: Colors.white,
    );
  }

  static Future<void> snackBarForSuccess2({String? titleText, required String bodyText, double? topMargin}) async {
    Get.snackbar(
      "",
      "",
      titleText: const SizedBox.shrink(),
      messageText: Text(bodyText, style: const TextStyle(color: Colors.white, fontSize: 15)),
      snackPosition: SnackPosition.TOP,
      maxWidth: Get.width * 0.7,
      padding: const .only(bottom: 15, left: 12, right: 10, top: 5),
      margin: .only(top: 25, left: Get.width * 0.05, right: Get.width * 0.05),
      borderRadius: 4,
      backgroundColor: Colors.green.withAlpha((0.8 * 255).toInt()),
      colorText: Colors.white,
    );
  }

  //                                             ? ctx.textColor
  //                                             : topShareControl.activeSector == model
  //                                             ? ColorConstants.blueColor
  //                                               ? ctx.textColor
  //                                               : topShareControl.activeSector == model
  //                                               ? ColorConstants.blueColor
  //                                 : title == "Sort By"
  //                                             ? ctx.textColor
  //                                             : topShareControl.activeSortByCompany == model
  //                                             ? ColorConstants.blueColor
  //                                               ? ctx.textColor
  //                                               : topShareControl.activeSortByCompany == model
  //                                               ? ColorConstants.blueColor
  //                                 : title == "Order By"
  //                                             ? ctx.textColor
  //                                             : topShareControl.activeSortByAscDesc == model
  //                                             ? ColorConstants.blueColor
  //                                               ? ctx.textColor
  //                                               : topShareControl.activeSortByAscDesc == model
  //                                               ? ColorConstants.blueColor
  static dynamic openDropdownShare(
    BuildContext ctx, {
    required String title,
    required List<String> menuLists,
    required String? selectedValue,
    required Function(String) onSelected,
    required double? height,
  }) {
    Get.dialog(
      Padding(
        padding: const EdgeInsets.all(20),
        child: AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          backgroundColor: Theme.of(ctx).cardColor, // আপনার অ্যাপের কালার অনুযায়ী পরিবর্তন করুন
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(15),
                width: Get.width,
                child: Text(
                  title,
                  style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              // List
              SizedBox(
                height: height ?? 100,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: menuLists.length,
                  itemBuilder: (context, index) {
                    final model = menuLists[index];
                    final isSelected = (model == selectedValue);

                    return InkWell(
                      onTap: () {
                        onSelected(model);
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(51))),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check, color: isSelected ? Colors.blue : Colors.transparent, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              model,
                              style: TextStyle(
                                color: isSelected ? Colors.blue : ctx.textColor,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static dynamic openLoginAlertDialog(VoidCallback? onPressed) {
    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
        elevation: 0.0,
        titlePadding: .zero,
        insetPadding: .zero,
        actionsPadding: .zero,
        title: Container(
          width: double.infinity,
          padding: .all(16),
          decoration: BoxDecoration(
            color: Get.isDarkMode
                ? ColorConstants.primaryColorDark
                : ColorConstants.primaryColor, // 👈 Title background color here
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: const Text(
            'Are You Sure?',
            style: TextStyle(
              color: Colors.white, // 👈 Title text color
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        contentPadding: const .fromLTRB(20, 20, 20, 0),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSpace.spaceH30,
              Text("You must login first !", textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
              AppSpace.spaceH10,
              Container(
                padding: const .only(right: 10, left: 10, top: 10),
                child: Row(
                  mainAxisAlignment: .spaceAround,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HexColor("#F70042"),
                          minimumSize: const Size(80, 40),
                          padding: const .symmetric(vertical: 5),
                          textStyle: const TextStyle(fontSize: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
                        ),
                        child: Text("No", style: Get.textTheme.titleSmall?.copyWith(color: Colors.white)),
                      ),
                    ),
                    AppSpace.spaceW20,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HexColor("#22C665"),
                          minimumSize: const Size(80, 40),
                          padding: const .symmetric(vertical: 5),
                          textStyle: const TextStyle(fontSize: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
                        ),
                        child: Text("Yes", style: Get.textTheme.titleSmall?.copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpace.spaceH10,
            ],
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  static void showLoginRequiredDialog() {
    openLoginAlertDialog(() {
      Get.back(); // 👈 ডায়ালগ বন্ধ করুন
      Future.delayed(const Duration(milliseconds: 150), () {
        Get.offNamed(Routes.LOGIN);
      });
    });
  }

  static dynamic openCustomAlertDialog(VoidCallback? onPressed, {String? title, String? bodyText}) {
    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
        elevation: 0.0,
        titlePadding: .zero,
        insetPadding: .zero,
        actionsPadding: .zero,
        contentPadding: const .fromLTRB(20, 20, 20, 0),
        title: Container(
          width: double.infinity,
          padding: .all(16),
          decoration: BoxDecoration(
            color: Get.isDarkMode
                ? ColorConstants.tapBgDark
                : ColorConstants.primaryColor, // 👈 Title background color here
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: Text(
            title ?? 'Are You Sure?',
            style: TextStyle(
              color: Colors.white, // 👈 Title text color
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSpace.spaceH30,
              Text(bodyText ?? 'Are You Sure?', textAlign: TextAlign.center),
              AppSpace.spaceH10,
              Container(
                padding: const .only(right: 10, left: 10, top: 10),
                child: Row(
                  mainAxisAlignment: .spaceAround,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          minimumSize: const Size(80, 40),
                          padding: const .symmetric(vertical: 5),
                          textStyle: const TextStyle(fontSize: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
                        ),
                        child: const Text("No", style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    AppSpace.spaceW20,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Get.theme.primaryColor,
                          minimumSize: const Size(80, 40),
                          padding: const .symmetric(vertical: 5),
                          textStyle: const TextStyle(fontSize: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
                        ),
                        child: const Text("Yes", style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpace.spaceH10,
            ],
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  //passwordVisivilityMethod
  static IconButton passwordVisivilityMethod(void Function()? onPressed, bool isVisible) {
    return IconButton(
      splashColor: Colors.transparent,
      onPressed: onPressed,
      icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility),
    );
  }

}
