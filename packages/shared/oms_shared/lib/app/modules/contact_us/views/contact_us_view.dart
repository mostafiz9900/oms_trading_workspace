import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/app/app_pkg.dart';
import '../controllers/contact_us_controller.dart';

class ContactUsView extends GetView<ContactUsController> {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {

    final bool isDark = context.isDark;

    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Contact Us',
        isBackButtonIcon: true,
        backButtonOnClick: () => Get.back(),
        right: const SizedBox(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "How can we help you?",
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.textColor,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Have questions about your trades, account, or the market? Our team at ${AppConfig.houseName} is here to assist you.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: context.textColor.withOpacity(0.6), height: 1.5),
              ),
            ),
            const SizedBox(height: 32),

            //  2. Support Section
            const _SectionTitle(title: "SUPPORT & INQUIRIES"),
            const SizedBox(height: 10),

            _ContactCard(
              icon: Icons.call_rounded,
              iconColor: Colors.green,
              title: "Call Us",
              subtitle: controller.contactNumber,
              actionText: "Call",
              isDark: isDark,
              onTap: () => controller.makePhoneCall(controller.contactNumber),
              onCopy: () => controller.copyToClipboard(controller.contactNumber, 'Phone number'),
            ),
            const SizedBox(height: 8),

            _ContactCard(
              icon: Icons.wechat_rounded,
              iconColor: const Color(0xFF25D366),
              title: "WhatsApp",
              subtitle: controller.contactWhatsApp, //  Variable
              actionText: "Chat",
              isDark: isDark,
              onTap: () => controller.launchWhatsApp(controller.contactWhatsApp),
              onCopy: () =>
                  controller.copyToClipboard(controller.contactWhatsApp, 'WhatsApp number'),
            ),
            const SizedBox(height: 8),

            _ContactCard(
              icon: Icons.email_rounded,
              iconColor: Colors.redAccent,
              title: "Email Support",
              subtitle: controller.supportEmail,
              actionText: "Email",
              isDark: isDark,
              onTap: () => controller.launchEmail(controller.supportEmail),
              onCopy: () => controller.copyToClipboard(controller.supportEmail, 'Email address'),
            ),

            const SizedBox(height: 24),

            //  3. Office & Website Section
            const _SectionTitle(title: "HEADQUARTERS & WEB"),
            const SizedBox(height: 12),

            _ContactCard(
              icon: Icons.location_on_rounded,
              iconColor: Colors.orange.shade600,
              title: "Head Office",
              subtitle: controller.officeAddressShort,
              actionText: "Map",
              isDark: isDark,
              onTap: () => controller.launchMap(),
              onCopy: () => controller.copyToClipboard(controller.officeAddressFull, 'Address'),
            ),
            const SizedBox(height: 8),

            _ContactCard(
              icon: Icons.language_rounded,
              iconColor: Colors.blue,
              title: "Official Website",
              subtitle: controller.websiteUrl,
              actionText: "Visit",
              isDark: isDark,
              onTap: () => controller.launchWebsite(),
              onCopy: () => controller.copyToClipboard(controller.websiteUrl, 'Website link'),
            ),

            const SizedBox(height: 24),

            //  4. Share App Section
            const _SectionTitle(title: "SHARE WITH FRIENDS"),
            const SizedBox(height: 12),

            _ContactCard(
              icon: Icons.android_rounded,
              iconColor: const Color(0xFF3DDC84),
              title: "Android App",
              subtitle: "Share Play Store link.",
              actionText: "Share",
              isDark: isDark,
              onTap: () => controller.shareAndroidApp(),
              onCopy: () => controller.copyToClipboard(controller.androidLink, 'Android app link'),
            ),
            const SizedBox(height: 8),

            _ContactCard(
              icon: Icons.apple_rounded,
              iconColor: isDark ? Colors.white : Colors.black87,
              title: "iOS App",
              subtitle: "Share App Store link.",
              actionText: "Share",
              isDark: isDark,
              onTap: () => controller.shareIosApp(),
              onCopy: () => controller.copyToClipboard(controller.iosLink, 'iOS app link'),
            ),
            const SizedBox(height: 32),

            //  5. Business Hours Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: context.textColor.withOpacity(0.05), shape: BoxShape.circle),
                    child: Icon(Icons.access_time_filled_rounded, color: Colors.grey.shade500, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Trading Hours",
                          style: TextStyle(fontWeight: FontWeight.w700, color: context.textColor, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.tradingHours,
                          style: TextStyle(color: context.textColor.withOpacity(0.6), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

//  Reusable Section Title Widget
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: context.textColor.withOpacity(0.4),
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

//  Reusable Custom Contact Card Widget (With Optimised Copy Option)
class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String actionText;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback? onCopy;

  const _ContactCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.isDark,
    required this.onTap,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161A33) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Left Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onCopy != null) ...[
                  GestureDetector(
                    onTap: onCopy,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.copy_rounded, size: 16, color: context.textColor.withOpacity(0.6)),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    actionText,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: iconColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
