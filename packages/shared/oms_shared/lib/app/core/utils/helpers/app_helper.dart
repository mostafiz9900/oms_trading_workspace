import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:crypto/crypto.dart' as crypto_info;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../app_pkg.dart';

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

  static Color getChangeColor(num? d) {
    if (d == null) return Colors.grey; // default
    if (d > 0) return Colors.green; // gain
    if (d < 0) return Colors.red; // loss
    return Colors.grey; // unchanged / zero
  }

  static IconData getTrendIcon(num? d) {
    if (d == null || d == 0) return Icons.remove; // neutral
    if (d > 0) return Icons.arrow_drop_up; // up arrow
    return Icons.arrow_drop_down; // down arrow
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

  // Save biometric enabled flag
  static Future<void> setBiometricEnabled(bool enabled) async {
    await StorageService.save(StorageConstants.biometricEnabled, enabled ? 'true' : 'false');
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

  static formatDisplayDate(String date) {
    try {
      // ইনপুট ফরম্যাট: 15/07/2026
      final DateFormat inputFormat = DateFormat("dd/MM/yyyy");
      // আউটপুট ফরম্যাট: 15-Jul-26
      final DateFormat outputFormat = DateFormat("dd-MMM-yy");

      final DateTime dateTime = inputFormat.parse(date);
      return outputFormat.format(dateTime);
    } catch (e) {
      // এরর হলে মূল স্ট্রিংটিই রিটার্ন করবে
      return date;
    }
  }

  static String formatNumber(num number) {
    return NumberFormat.compact().format(number);
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

  static int calculateHoursAgo(String timeString) {
    // Get the current date and time
    DateTime now = DateTime.now();

    // Split the time string into hours, minutes, seconds, and milliseconds
    List<String> timeParts = timeString.split(":");
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);
    List<String> secondsParts = timeParts[2].split(".");
    int seconds = int.parse(secondsParts[0]);
    int milliseconds = int.parse(secondsParts[1]);

    // Create a DateTime object for the provided time, using today's date
    DateTime parsedTime = DateTime(now.year, now.month, now.day, hours, minutes, seconds, milliseconds);

    // Calculate the difference in hours
    Duration difference = now.difference(parsedTime);

    // Return the difference in hours
    return difference.inHours;
  }

  static String calculateTimeDifferenceBetween({required DateTime startDate, DateTime? endDate}) {
    DateTime currentDate = endDate ?? DateTime.now();
    int seconds = currentDate.difference(startDate).inSeconds;
    if (seconds < 60) {
      return '$seconds second';
    } else if (seconds >= 60 && seconds < 3600) {
      return '${currentDate.difference(startDate).inMinutes.abs()} minute';
    } else if (seconds >= 3600 && seconds < 86400) {
      return '${currentDate.difference(startDate).inHours} hour';
    } else {
      return '${currentDate.difference(startDate).inDays} days';
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

  static List<DateTime> getNextNDays(int n) {
    List<DateTime> dates = [];
    DateTime now = DateTime.now();
    for (int i = 1; i <= n; i++) {
      dates.add(now.add(Duration(days: i)));
    }
    return dates;
  }

  static double? toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static BoxDecoration customCircularDecoretion(BuildContext context, Color? color, double value) {
    return BoxDecoration(color: color, borderRadius: BorderRadius.circular(value));
  }

  static void showCustomDialog(BuildContext context, {required Widget child}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'custom_dialog',
      barrierColor: Colors.black.withOpacity(0.5),
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

  static void openDialog(void Function()? onPressed) {
    Get.dialog(
      AlertDialog(
        title: const Text("sebaghar"),
        content: const Text("yourAreNotOldPatient"),
        actions: [
          TextButton(onPressed: onPressed, child: const Text("ok")),
        ],
      ),
    );
  }

  static AppBar customAppBar({
    String? title,
    bool? search,
    bool? appointmentBack,
    onPressed,
    bool? searchDoctor,
    closeSearch,
    searchSaved,
    hintText,
    enabled,
    editController,
    keyboardType,
    clearSearch,
    onchangeSearch,
  }) {
    return AppBar(
      backgroundColor: Get.theme.primaryColor,
      centerTitle: false,
      scrolledUnderElevation: 0.0,
      automaticallyImplyLeading: false,
      title: searchDoctor == true
          ? Row(
              children: [
                IconButton(
                  onPressed: closeSearch,
                  icon: Icon(Icons.arrow_back, color: Get.theme.iconTheme.color),
                ),
                //change
                Flexible(
                  child: TextFormField(
                    keyboardType: keyboardType,
                    controller: editController,
                    autofocus: true,
                    onChanged: onchangeSearch,
                    enabled: enabled,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(color: Colors.white),
                      hintText: hintText,
                      border: InputBorder.none,
                    ),
                    onSaved: searchSaved,
                  ),
                ),
                IconButton(
                  onPressed: clearSearch,
                  icon: Icon(Icons.close, color: Get.theme.iconTheme.color),
                ),
              ],
            )
          : Row(
              children: [
                Flexible(
                  flex: 1,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => appointmentBack == true ? Get.offNamed(Routes.HOME) : Get.back(),
                        icon: Icon(Icons.arrow_back, color: Get.theme.iconTheme.color),
                      ),
                      Text(title!.tr, style: Get.theme.appBarTheme.titleTextStyle),
                    ],
                  ),
                ),
                search == true
                    ? IconButton(
                        onPressed: onPressed,
                        icon: Icon(Icons.search, color: Get.theme.iconTheme.color),
                      )
                    : Container(),
              ],
            ),
    );
  }

  static BoxDecoration createButtonDecoration({double? radius}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius ?? 0.0),
      color: Colors.grey.withAlpha((0.13 * 255).toInt()),
    );
  }

  static BoxDecoration createDropdownButtonDecoration({double? radius}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius ?? 0.0),
      color: Colors.white,
    );
  }

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
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

  static void snackBarForSuccess({dynamic titleText, dynamic bodyText, double? topMargin}) {
    Get.snackbar(
      titleText,
      bodyText,
      snackPosition: SnackPosition.TOP,
      margin: .only(top: topMargin ?? Get.height * 0.0, left: Get.width * 0.05, right: Get.width * 0.05),
      backgroundColor: Colors.black,
      colorText: Colors.white,
    );
  }

  static void showSnackBarBuild({required BuildContext context, required String message}) {
    final snackBar = SnackBar(
      backgroundColor: Get.theme.primaryColor,
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

  //Time Of Day
  static Future dayOfTime(BuildContext context) async {
    final TimeOfDay? timePicker = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: Get.theme.primaryColor,
              headerForegroundColor: Colors.white,
              backgroundColor: Colors.white,
            ),
            colorScheme: ColorScheme.light(
              primary: Get.theme.primaryColor,
              // <-- SEE HERE  onPrimary: Colors.white, // <-- SEE HERE
              onSecondary: Get.theme.primaryColor, // <-- SEE HERE  secondary: Get.theme.primaryColor, // <-- SEE HERE
            ),
            textButtonTheme: const TextButtonThemeData(
            ),
          ),
          child: child!,
        );
      },
    );

    return '${int.parse(timePicker!.hourOfPeriod.toString().split('.')[0]) <= 9 ? "0${int.parse(timePicker.hourOfPeriod.toString().split('.')[0])}" : int.parse(timePicker.hourOfPeriod.toString().split('.')[0])} :${timePicker.minute <= 9 ? "0${timePicker.minute}" : timePicker.minute} ${timePicker.period.toString().split('.')[1]}';
  }

  //Time Of Day
  static Future dayOfTimeDiagonstic(BuildContext context) async {
    final TimeOfDay? timePicker = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: Get.theme.primaryColor,
              headerForegroundColor: Colors.white,
              backgroundColor: Colors.white,
            ),
            colorScheme: ColorScheme.light(
              primary: Get.theme.primaryColor,
              // <-- SEE HERE  onPrimary: Colors.white, // <-- SEE HERE
              onSecondary: Get.theme.primaryColor, // <-- SEE HERE  secondary: Get.theme.primaryColor, // <-- SEE HERE
            ),
            textButtonTheme: const TextButtonThemeData(
            ),
          ),
          child: child!,
        );
      },
    );

    return '${int.parse(timePicker!.hourOfPeriod.toString().split('.')[0]) <= 9 ? "0${int.parse(timePicker.hourOfPeriod.toString().split('.')[0])}" : int.parse(timePicker.hourOfPeriod.toString().split('.')[0])} :${timePicker.minute <= 9 ? "0${timePicker.minute}" : timePicker.minute} ${timePicker.period.toString().split('.')[1]}';
  }

  // Date picker
  static Future<String?> datePickerShow([String? dateFormate]) async {
    DateTime? pickedDate = await showDatePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: Get.theme.primaryColor,
              headerForegroundColor: Colors.white,
              backgroundColor: Colors.white,
            ),
            colorScheme: ColorScheme.light(
              primary: Get.theme.primaryColor,
              // <-- SEE HERE  onPrimary: Colors.white, // <-- SEE HERE
              onSecondary: Get.theme.primaryColor, // <-- SEE HERE  secondary: Get.theme.primaryColor, // <-- SEE HERE
            ),
            textButtonTheme: const TextButtonThemeData(
            ),
          ),
          child: child!,
        );
      },
      context: Get.overlayContext!,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      printLog(pickedDate);
      String formattedDate = DateFormat(dateFormate ?? 'yyyy-MM-dd').format(pickedDate);
      printLog(formattedDate);

      return formattedDate;
    } else {}
    return null;
  }

  static Future<DateTime?> showDateTimePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    initialDate ??= DateTime.now();
    firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
    lastDate ??= firstDate.add(const Duration(days: 365 * 200));

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      barrierDismissible: false,
      helpText: "selectDate.",
      cancelText: "cancel",
      confirmText: "ok",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: Get.theme.primaryColor,
              headerForegroundColor: Colors.white,
              backgroundColor: Colors.white,
            ),
            colorScheme: ColorScheme.light(
              primary: Get.theme.primaryColor,
              // <-- SEE HERE  onPrimary: Colors.white, // <-- SEE HERE
              onSecondary: Get.theme.primaryColor, // <-- SEE HERE  secondary: Get.theme.primaryColor, // <-- SEE HERE
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                backgroundColor: WidgetStateColor.resolveWith((states) => ColorConstants.primaryColorLight),
                foregroundColor: WidgetStateColor.resolveWith((states) => Colors.white),
                overlayColor: WidgetStateColor.resolveWith((states) => ColorConstants.primaryColorLight),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return null;

    if (!context.mounted) return selectedDate;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
      barrierDismissible: false,
      cancelText: "cancel",
      confirmText: "ok",
      helpText: "selectDate",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // This uses the _timePickerTheme defined above
            timePickerTheme: timePickerTheme,
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                backgroundColor: WidgetStateColor.resolveWith((states) => ColorConstants.primaryColorLight),
                foregroundColor: WidgetStateColor.resolveWith((states) => Colors.white),
                overlayColor: WidgetStateColor.resolveWith((states) => ColorConstants.primaryColorLight),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    var result = selectedTime == null
        ? selectedDate
        : DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
    return result;
  }

  static final timePickerTheme = TimePickerThemeData(
    hourMinuteShape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      side: BorderSide(color: ColorConstants.primaryColorLight, width: 2),
    ),
    dayPeriodBorderSide: BorderSide(color: ColorConstants.primaryColorLight, width: 4),
    hourMinuteColor: WidgetStateColor.resolveWith(
      (states) => states.contains(WidgetState.selected) ? ColorConstants.primaryColorLight : Colors.blueGrey.shade200,
    ),
    hourMinuteTextColor: WidgetStateColor.resolveWith(
      (states) => states.contains(WidgetState.selected) ? Colors.white : ColorConstants.primaryColorLight,
    ),
    dialHandColor: ColorConstants.primaryColorLight,
    entryModeIconColor: ColorConstants.primaryColorLight,
  );

  static Future<String?> datePickerShowForBirthDay([String? dateFormate]) async {
    DateTime? pickedDate = await showDatePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorConstants.primaryColorLight,
              onPrimary: Colors.white,
              onSurface: ColorConstants.primaryColorLight,
            ),
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Colors.red)),
          ),
          child: child!,
        );
      },
      context: Get.overlayContext!,
      initialDate: DateTime(DateTime.now().year - 18),
      firstDate: DateTime(1950),
      lastDate: DateTime(DateTime.now().year - 18),
    );

    if (pickedDate != null) {
      printLog(pickedDate);
      String formattedDate = DateFormat(dateFormate ?? 'yyyy-MM-dd').format(pickedDate);
      printLog(formattedDate);

      return formattedDate;
    } else {}
    return null;
  }

  static monthYear(String dateStart) {
    DateFormat inputFormat = DateFormat('dd/MM/yyyy hh:mm:ss a');
    DateTime input = inputFormat.parse(dateStart);
    String result = DateFormat('MM/yyyy').format(input);
    return result;
  }

  static String formatTime(String time) {
    String dateTime = DateFormat.jm().format(DateFormat("hh:mm:ss").parse(time));
    return dateTime;
  }

  static String checkCardNumber(String cardnumber) {
    String number = "";
    final String stripped = cardnumber.replaceAll(RegExp(r'[^\d]'), '');
    if (stripped.length > 8) {
      final String middle = cardnumber.substring(4, 6).trim();
      final String middle1 = cardnumber.substring(6, cardnumber.length - 8).trim().replaceAll(RegExp(r'\d'), 'X');
      final String middle2 = cardnumber.substring(8, cardnumber.length - 4).trim().replaceAll(RegExp(r'\d'), 'X');
      number =
          stripped.substring(0, 4) +
          " " +
          middle +
          "" +
          middle1 +
          " " +
          middle2 +
          ' ' +
          stripped.substring(stripped.length - 4);
    }

    return number;
  }

  static String cardMaskingStart(String cardnumber) {
    String number = "";

    final String stripped = cardnumber.replaceAll(RegExp(r'[^\d]'), '');
    if (stripped.length > 8) {
      final String middle = cardnumber
          .trim()
          .substring(6, cardnumber.length - 4)
          .replaceAll(RegExp(r'\d'), '*')
          .replaceAll(" ", "");

      number = stripped.substring(0, 6) + middle + stripped.substring(stripped.length - 4);
    }
    return number.trim();
  }

  static void checkLogin({required VoidCallback onPressed}) async {
    if (await StorageService.read(StorageConstants.userInfo) == null) {
      Helpers.openAuthAlertDialog(() {
        Get.offAndToNamed(Routes.LOGIN);
      });
    } else {
      onPressed();
    }
  }

  static openAuthAlertDialog(VoidCallback? onPressed) {
    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        elevation: 0.0,
        titlePadding: .zero,

        //আপনাকে লগইন করতে হবে।\n আপনি কি রাজি?
        insetPadding: .zero,
        contentPadding: .zero,
        actionsPadding: .zero,
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSpace.spaceH10,
              const Text("youUstLoginDoYouAgree", textAlign: TextAlign.center),
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
                        child: const Text("no", style: TextStyle(color: Colors.black)),
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
                        child: const Text("yes", style: TextStyle(color: Colors.white)),
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
  static openDropdownShare(
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
                          border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
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

  static openLoginAlertDialog(VoidCallback? onPressed) {
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

  static openCustomAlertDialog(VoidCallback? onPressed, {String? title, String? bodyText}) {
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

  static openWelcomeDialog(VoidCallback? onPressed) {
    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        elevation: 0.0,
        titlePadding: .zero,
        insetPadding: .zero,
        contentPadding: .zero,
        actionsPadding: .zero,
        actions: [
          SizedBox(
            width: Get.width - 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSpace.spaceH30,
                ClipRRect(
                  borderRadius: BorderRadius.circular(60 / 2),
                  child: Image.asset(AssetsConstants.appLogo, height: 60, width: 60),
                ),
                AppSpace.spaceH10,
                const Text("welcomeToSebaGhar"),
                AppSpace.spaceH10,
                const Text("youHaveSuccessfullyChangedYourFamilyAccount", textAlign: TextAlign.center),
                AppSpace.spaceH10,
                Row(
                  mainAxisAlignment: .spaceAround,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: ColorConstants.primaryColorLight),
                          child: const Text("ok", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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

  static String? validateEmail(String? value) {
    const pattern =
        r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);
    return value!.isNotEmpty && !regex.hasMatch(value) ? 'Enter a valid email address' : null;
  }

  static Text appDiveder() {
    return Text(
      "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------",
      style: TextStyle(color: Colors.grey.shade300),
      maxLines: 1,
      overflow: TextOverflow.visible,
    );
  }

  static String handleErrorApi(Response response) {
    var statusCode = response.statusCode;
    switch (statusCode) {
      case 400:
        printLog('Bad request status code : $statusCode');
        return "Bad request status code : $statusCode";
      case 401:
        printLog('Unauthorized status code : $statusCode');
        return "Unauthorized status code : $statusCode";
      case 404:
        printLog('Not found status code : $statusCode');
        return "Not found status code : $statusCode";
      default:
        printLog('Unknown error occurred status code : $statusCode');
        return "Unknown error occurred status code : $statusCode";
    }
  }

  static String handleErrorException(error) {
    if (error is SocketException) {
      printLog('Network error : $error');
      return "Network error : $error";
    } else if (error is TimeoutException) {
      printLog('Request timed out : $error');
      return "Request timed out : $error";
    } else {
      printLog('Unknown error $error');
      return "Unknown error : $error";
    }
  }

  static Future<String?> picImage(ImageSource type) async {
    try {
      final imagePicker = await ImagePicker().pickImage(
        source: type == ImageSource.camera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
        maxHeight: 500,
        maxWidth: 450,
      );
      if (imagePicker == null) return null;
      final imageTemp = File(imagePicker.path);
      final bytes = File(imagePicker.path).readAsBytesSync();
      String img64 = base64Encode(bytes);
      var imgDecode64 = base64Decode(img64);
      printLog(imgDecode64);
      printLog(imagePicker.path);
      printLog(imageTemp);

      return img64;
    } on PlatformException catch (e) {
      printLog("Failed to pick image: $e");
    }
    return null;
  }

  static Future<File?> tokeImageForFile(ImageSource type) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? imagePicker = await picker.pickImage(
        source: type == ImageSource.camera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
        maxHeight: 500,
        maxWidth: 450,
      );
      if (imagePicker == null) return null;
      final imageTemp = File(imagePicker.path);
      return imageTemp;
    } on PlatformException catch (e) {
      printLog("Failed to pick image: $e");
    }
    return null;
  }

  static Future<File?> selectVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickMedia();
    if (pickedFile != null) {
      final videoFile = File(pickedFile.path);
      return videoFile;
    }
    return null;
  }

  static Future<String?> saveBitmapToExtFilesDir(ui.Image bitmap, String fileName) async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      return null; // Handle case where external storage is unavailable
    }
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    try {
      await file.create(recursive: true); // Ensure directory exists
      final sink = file.openWrite(mode: FileMode.write);
      await saveImageToJPEGFile(bitmap, filePath);
      await sink.flush();
      await sink.close();
      return filePath;
    } catch (e) {
      printLog('Error saving bitmap: $e'); // Log for debugging
      return null;
    }
  }

  static Future<void> saveImageToJPEGFile(ui.Image image, String filePath, {int quality = 100}) async {
    Uint8List? bytes = await encodeToJpeg(image, quality);
    File(filePath).writeAsBytesSync(bytes!);
  }

  static Future<Uint8List?> encodeToJpeg(ui.Image image, int quality) async {
    try {
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) {
        throw Exception("Failed to convert image to byte data.");
      }

      var byteList = byteData.buffer;

      img.Image imgImage = img.Image.fromBytes(width: image.width, height: image.height, bytes: byteList);

      return img.encodeJpg(imgImage, quality: quality);
    } catch (e) {
      printLog("Error encoding image to JPEG: $e");
      return null;
    }
  }
}
