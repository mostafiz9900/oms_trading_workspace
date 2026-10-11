import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '/app/app_pkg.dart';

class ContactUsController extends GetxController {
  // ==========================================================
  //  Global Variables (সব ডেটা এখান থেকে কন্ট্রোল হবে)
  // ==========================================================
  final String contactNumber = "01940660088";
  final String contactWhatsApp = "01940660088";
  final String supportEmail = "contact@benemoysecurities.com";
  final String websiteUrl = "https://benemoysecurities.com";
  final String officeAddressShort = "Praasad Paltan Square (9th Floor), 3/11 Naya Paltan, Motijheel, Dhaka-1000";
  final String officeAddressFull =
      "Praasad Paltan Square (9th Floor), 3/11 Naya Paltan, Box Culvert Road, Motijheel, Dhaka-1000, Bangladesh";
  final String tradingHours = "Sunday - Thursday (10:00 AM - 2:00 PM)";

  final String androidLink =
      "https://play.google.com/store/apps/details?id=com.benemoysecurity.app&pcampaignid=web_share";
  final String iosLink = "https://apps.apple.com/us/app/benemoy/id6751455371";

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Helpers.snackbarForErorr2(bodyText: 'Could not launch dialer');
    }
  }

  Future<void> launchWhatsApp(String phone) async {
    final String whatsappUrl = "https://wa.me/88$phone";
    final Uri launchUri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      Helpers.snackbarForErorr2(bodyText: 'WhatsApp is not installed');
    }
  }

  Future<void> launchEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support Inquiry - Benemoy Securities Ltd&body=Hello Support Team,',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Helpers.snackbarForErorr2(bodyText: 'Could not open email app');
    }
  }

  Future<void> launchMap() async {
    //  ভেরিয়েবল ব্যবহার করা হলো
    final String addressQuery = Uri.encodeComponent(officeAddressFull);
    final String mapUrl = "https://www.google.com/maps/search/?api=1&query=$addressQuery";
    final Uri launchUri = Uri.parse(mapUrl);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      Helpers.snackbarForErorr2(bodyText: 'Could not open the map');
    }
  }

  Future<void> launchWebsite() async {
    //  ভেরিয়েবল ব্যবহার করা হলো
    final Uri launchUri = Uri.parse(websiteUrl);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      Helpers.snackbarForErorr2(bodyText: 'Could not open website');
    }
  }

  void shareAndroidApp() {
    //  গ্লোবাল ভেরিয়েবল ব্যবহার করা হলো
    final String shareText =
        "Experience the best stock market trading with Benemoy Securities!\n\nDownload our Android app now:\n📱 $androidLink";

    SharePlus.instance.share(ShareParams(text: shareText, subject: 'Download Benemoy App (Android)'));
  }

  void shareIosApp() {
    //  গ্লোবাল ভেরিয়েবল ব্যবহার করা হলো
    final String shareText =
        "Experience the best stock market trading with Benemoy Securities!\n\nDownload our iOS app now:\n🍏 $iosLink";

    SharePlus.instance.share(ShareParams(text: shareText, subject: 'Download Benemoy App (iOS)'));
  }

  void copyToClipboard(String text, String itemType) {
    Clipboard.setData(ClipboardData(text: text));

    Get.rawSnackbar(
      message: '$itemType copied to clipboard',
      backgroundColor: const Color(0xFF22C665),
      snackPosition: SnackPosition.BOTTOM,
      borderRadius: 8,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
