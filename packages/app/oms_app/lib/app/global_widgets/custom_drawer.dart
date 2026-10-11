import 'dart:math';

import 'package:flutter_hooks/flutter_hooks.dart';

import '/app/app_pkg.dart';

import 'package:oms_app/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../modules/home/controllers/password_reset_controller.dart';

import '../modules/home/views/notification_view.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCon = Get.find<HomeController>();
    final ThemeServices themeController = Get.find();
    bool isDark = Get.isDarkMode;
    Widget customDivider = Divider(color: Colors.grey.shade300, height: 1, thickness: 1, indent: 1, endIndent: 1);
    return GetBuilder<HomeController>(
      builder: (homeCon) {
        return Drawer(
          elevation: 0,
          // backgroundColor: isDark?hexToColor('#1C2546F0'):HexColor('#FFFFFF'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: SafeArea(
            child: Column(
              // padding: .zero,
              children: [
                AppSpace.spaceH12,
                SvgPicture.asset(context.bannerLogo, height: 40),
                AppSpace.spaceH10,
                customDivider,
                AppSpace.spaceH6,
                Column(
                  children: [
                    // Text('', style: Get.textTheme.bodyMedium!.copyWith(color: ColorConstants.black)),
                    if (homeCon.userInfo.userDetail?.investorName != null) ...[
                      Text(
                        homeCon.userInfo.userDetail?.investorName ?? "",
                        textAlign: TextAlign.center,
                        style: Get.textTheme.bodyLarge!.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: context.textColor,
                        ),
                      ),
                      AppSpace.spaceH6,
                      customDivider,
                    ],
                  ],
                ),

                AppSpace.spaceH6,
                Expanded(
                  child: ListView(
                    // padding: .symmetric(horizontal: 15),
                    children: [
                      itemHeader(context, title: 'Requests'),
                      customDrawerItem(
                        context,
                        image: Assets.svgImageOrderList,
                        title: 'Limit Request',
                        isLogin: true,
                        onTap: () async {
                          Get.back();
                          Get.toNamed(Routes.LIMIT_REQUEST);
                        },
                      ),
                      customDrawerItem(
                        context,
                        image: Assets.svgImageWatchListIcon,
                        title: 'Withdraw Request',
                        isLogin: true,
                        onTap: () async {
                          Get.back();
                          Get.toNamed(Routes.WITHDRAWAL_REQUEST);
                        },
                      ),
                      AppSpace.spaceH8,
                      itemHeader(context, title: 'Market'),
                      customDrawerItem(
                        context,
                        image: Assets.svgImageMarketLine,
                        title: 'Market',
                        onTap: () {
                          Get.back();
                          homeCon.changeCurrentIndex(0);
                        },
                      ),
                      customDrawerItem(
                        context,
                        image: Assets.svgImageTopStocks,
                        title: 'Top Stocks',
                        onTap: () {
                          Get.back();
                          Get.toNamed(Routes.TOP_SHARE, arguments: 'Gainer');
                        },
                      ),
                      customDrawerItem(
                        context,
                        image: Assets.svgImageLoveIcon,
                        title: 'Favorites',
                        onTap: () {
                          Get.back();
                          // Get.to(()=>FavMarketView());
                          homeCon.changeCurrentIndex(3);
                        },
                      ),
                      AppSpace.spaceH8,
                      itemHeader(context, title: 'Indices'),
                      customDrawerItem(
                        context,
                        image: Assets.svgImageTopStocks,
                        title: 'Watch List',
                        onTap: () {
                          Get.back();
                          homeCon.changeCurrentIndex(2);
                        },
                      ),
                      AppSpace.spaceH8,
                      itemHeader(context, title: 'Quote'),
                      customDrawerItem(
                        context,
                        image: Assets.svgImageQuoteIcon,
                        title: 'Market Depth',
                        onTap: () {
                          Get.back();
                          homeCon.changeTabQuote(0);
                          homeCon.changeCurrentIndex(1);
                        },
                      ),
                      customDrawerItem(
                        context,
                        image: Assets.svgImageTimeAndSales,
                        title: 'Time And Sales',
                        onTap: () {
                          Get.back();
                          homeCon.changeTabQuote(1);
                          homeCon.changeCurrentIndex(1);
                        },
                      ),
                      customDrawerItem(
                        context,
                        image: Assets.svgImageOrderList,
                        title: 'News',
                        onTap: () {
                          Get.back();
                          // Get.to(()=> NewsView());
                          int uniqueId = Random().nextInt(1000000);
                          homeCon.subscribeTimeAndSalesNews('news', '$uniqueId');
                          Get.to(() => NotificationView());
                        },
                      ),
                      AppSpace.spaceH8,
                      itemHeader(context, title: 'Trade'),
                      customDrawerItem(
                        context,
                        image: Assets.svgImagePortfolioIcon,
                        title: 'Portfolio',
                        onTap: () {
                          Get.back();
                          homeCon.changeCurrentIndex(4);
                        },
                      ),
                      customDrawerItem(
                        context,
                        image: Assets.svgImageOrderList,
                        title: 'Order List',
                        onTap: () {
                          Get.back();
                          homeCon.changeTabPortfolio(1);
                          homeCon.changeCurrentIndex(4);
                        },
                      ),
                      customDrawerItem(
                        context,
                        image: Assets.svgImageAccountSummary,
                        title: 'Account Summary',
                        onTap: () {
                          Get.back();
                          homeCon.changeTabPortfolio(2);
                          homeCon.changeCurrentIndex(4);
                        },
                      ),
                      customDrawerItem(
                        context,
                        image: Assets.svgImageTradeIcon,
                        title: 'Trade',
                        onTap: () {
                          Get.back();
                          homeCon.changeCurrentIndex(5);
                        },
                      ),
                      customDrawerItem(
                        context,
                        image: Assets.svgImageMarketLine,
                        title: 'News',
                        onTap: () {
                          Get.back();
                          int uniqueId = Random().nextInt(1000000);
                          Get.find<HomeController>().subscribeTimeAndSalesNews('news', '$uniqueId');
                          Get.to(() => NotificationView());
                        },
                      ),
                      customDrawerItem(
                        context,
                        image: Assets.svgImageHelp,
                        title: 'Contact Us',
                        onTap: () {
                          Get.back();
                          Get.toNamed(Routes.CONTACT_US);
                        },
                      ),

                      // customDrawerItem(
                      //   context,
                      //   image: Assets.svgImageTradeIcon,
                      //   title: 'Chart',
                      //   onTap: () {
                      //     Get.back();
                      //     // Get.to(() => TradingViewPage());
                      //     Get.to(() => ProfessionalStockChart());
                      //     // launchOnlyDseChart('GP');
                      //   },
                      // ),
                      AppSpace.spaceH8,
                      // itemHeader(context, title: 'Help'),
                      if (homeCon.userInfo.id != null) ...[
                        customDrawerItem(
                          context,
                          image: GetPlatform.isIOS ? Assets.svgImageFaceId : Assets.svgImageFingerScan,
                          title: homeCon.userInfo.b == false ? "Biometric Enable" : 'Biometric Disable',
                          onTap: () async {
                            printLog('${homeCon.userInfo.b}');
                            Get.back();
                            if (await StorageService.read(StorageConstants.token) == null) {
                              Helpers.showLoginRequiredDialog();
                            } else {
                              Get.back();
                              final success = await homeCon.enableDisableBiometric(context);
                              printLog('success:: $success');
                              if (success) {
                                // ref.refresh(refreshTokenProvider);
                                // Get.offAll(() => const HomePage());
                                Helpers.snackBarForSuccess2(bodyText: "Biometric auth seccess");
                              } else {
                                Helpers.snackbarForErorr2(bodyText: "Biometric auth failed");
                              }
                            }
                          },
                        ),
                        CheckTokenWidget(
                          child: customDrawerItem(
                            context,
                            image: Assets.svgImageChangePassword,
                            title: 'Change Password',
                            onTap: () {
                              Get.back();
                              printLog(homeCon.userInfo.toJson());
                              // showResetPasswordBottomSheet(context);
                              showChangePasswordBottomSheet(context);
                            },
                          ),
                        ),
                      ],

                      Padding(
                        padding: .only(left: 10),
                        child: ListTile(
                          leading: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            color: isDark ? Colors.amber : Colors.blueGrey,
                          ),
                          title: Text(
                            isDark ? "Switch to Light" : "Switch to Dark",
                            style: Get.textTheme.bodyMedium!.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: context.textColor,
                            ),
                          ),
                          trailing: Switch(
                            value: isDark,
                            onChanged: (val) {
                              Get.back();
                              themeController.toggleTheme();
                            },
                          ),
                        ),
                      ),

                      // customDrawerItem(
                      //   context,
                      //   image: Assets.svgImageAboutUs,
                      //   title: 'About Us',
                      //   onTap: () {
                      //     Get.back();
                      //   },
                      // ),
                      // customDrawerItem(
                      //   context,
                      //   image: Assets.svgImageHelp,
                      //   title: 'Help',
                      //   onTap: () {
                      //     Get.back();
                      //   },
                      // ),
                      // customDrawerItem(context,
                      //     image: Assets.svgImageLogout,
                      //     title: 'Log out',
                      //     onTap: (){
                      //   StorageService.read(StorageConstants.refreshToken).then((value) {
                      //     if(value!=null){
                      //       printLog('is login');
                      //     }else{
                      //       printLog('after loign');
                      //     }
                      //   });
                      // }),
                      // CheckTokenWidget(child:
                      customDrawerItem(
                        context,
                        image: Assets.svgImageLogout,
                        title: homeCon.userInfo.id == null ? 'Login' : 'Log out',
                        onTap: () {
                          Get.back();
                          if (homeCon.userInfo.id == null) {
                            Get.offNamed(Routes.LOGIN);
                          } else {
                            showLogoutDialog(context);
                          }
                        },
                      ),

                      // ),
                      AppSpace.spaceH20,
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showChangePasswordBottomSheet(BuildContext context) {
    // 🚀 1. Controller ইনিশিয়ালাইজ করা হলো এবং HomeRepository পাস করা হলো
    final passResetCon = Get.put(PasswordResetController(Get.find<HomeController>().homeRepository));

    // 🚀 2. ডায়ালগ ওপেন হওয়ার আগে আগের ডেটা ক্লিয়ার করা হলো
    passResetCon.oldPasswordController.clear();
    passResetCon.passwordController.clear();
    passResetCon.confirmPasswordController.clear();

    Get.bottomSheet(
      GetBuilder<PasswordResetController>(
        builder: (controller) {
          // 🚀 FIX: Builder অ্যাড করা হলো যাতে বটম শিটের নিজস্ব ফ্রেশ context (ctx) পাওয়া যায়।
          // এর ফলে update() কল হলেও আর ক্র্যাশ করবে না।
          return Builder(
            builder: (ctx) {
              return Container(
                padding: const .all(16),
                decoration: BoxDecoration(
                  color: ctx.bgColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SingleChildScrollView(
                      child: Form(
                        key: controller.formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Change Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),

                            // 🟢 Old Password
                            CustomEditTextFormField(
                              controller: controller.oldPasswordController,
                              hintText: 'Old Password',
                              onChanged: (value) {},
                              passwordVisible: !controller.oldPasswordVisible,
                              keyboardType: TextInputType.text,
                              prefixIcon: AssetsConstants.passwordIconSvg,
                              suffixIcon: controller.oldPasswordVisible
                                  ? AssetsConstants.passwordInvisibelSvg
                                  : AssetsConstants.passwordVisibleSvg,
                              suffixOnTap: controller.toggleOldPassword,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your old password';
                                }
                                return null;
                              },
                            ),
                            AppSpace.spaceH10,

                            // 🟢 New Password
                            CustomEditTextFormField(
                              controller: controller.passwordController,
                              hintText: 'Password',
                              onChanged: (value) {},
                              passwordVisible: !controller.passwordVisible,
                              keyboardType: TextInputType.text,
                              prefixIcon: AssetsConstants.passwordIconSvg,
                              suffixIcon: controller.passwordVisible
                                  ? AssetsConstants.passwordInvisibelSvg
                                  : AssetsConstants.passwordVisibleSvg,
                              suffixOnTap: controller.togglePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Password is required';
                                if (value.length < 8) return 'Must be at least 8 characters long';
                                if (!RegExp(r'(?=.*?[A-Z])').hasMatch(value)) {
                                  return 'Must contain at least 1 uppercase letter';
                                }
                                if (!RegExp(r'(?=.*?[0-9])').hasMatch(value)) return 'Must contain at least 1 number';
                                if (!RegExp(r'(?=.*?[!@#\$&*~])').hasMatch(value)) {
                                  return 'Must contain at least 1 special character';
                                }
                                return null;
                              },
                            ),
                            AppSpace.spaceH10,

                            // 🟢 Confirm Password
                            CustomEditTextFormField(
                              controller: controller.confirmPasswordController,
                              hintText: 'Confirm Password',
                              onChanged: (value) {},
                              passwordVisible: !controller.confirmPasswordVisible,
                              keyboardType: TextInputType.text,
                              prefixIcon: AssetsConstants.passwordIconSvg,
                              suffixIcon: controller.confirmPasswordVisible
                                  ? AssetsConstants.passwordInvisibelSvg
                                  : AssetsConstants.passwordVisibleSvg,
                              suffixOnTap: controller.toggleConfirmPassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please confirm your password';
                                if (value != controller.passwordController.text) return 'Passwords do not match';
                                return null;
                              },
                            ),

                            AppSpace.spaceH30,

                            // 🟢 Submit Button
                            CustomButton(
                              isLoading: controller.isLoading,
                              onPressed: () {
                                if (controller.formKey.currentState?.validate() ?? false) {
                                  controller.changePassword();
                                }
                              },
                              title: AppTranslations.login.tr,
                            ),
                            AppSpace.spaceH20,
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: -10,
                      top: -15,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ); // 🚀 Builder End
        },
      ),
      isScrollControlled: true,
      isDismissible: false,
    );
  }
  /*   void showResetPasswordBottomSheet(BuildContext context) {
    // Get.put(PasswordResetController());
    final oldPasswordController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    Get.bottomSheet(
      GetBuilder<PasswordResetController>(
        init: Get.find<PasswordResetController>(),
        builder: (passResetCon) {
          return Builder(
            builder: (ctx) {
              return Container(
                padding: const .all(16),
                decoration: BoxDecoration(
                  color: ctx.bgColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Stack(
                  children: [
                    Form(
                      key: passResetCon.formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Change Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          CustomEditTextFormField(
                            controller: oldPasswordController,
                            hintText: 'Old Password',
                            onChanged: (value) {},
                            passwordVisible: !passResetCon.oldPasswordVisible,
                            keyboardType: TextInputType.text,
                            prefixIcon: AssetsConstants.passwordIconSvg,
                            suffixIcon: passResetCon.oldPasswordVisible
                                ? AssetsConstants.passwordInvisibelSvg
                                : AssetsConstants.passwordVisibleSvg,
                            // validator: (text)=>validateField(text!),
                            suffixOnTap: () {
                              passResetCon.oldPasswordVisible = !passResetCon.oldPasswordVisible;
                              passResetCon.update();
                            },
                          ),
                          AppSpace.spaceH10,
                          CustomEditTextFormField(
                            controller: passwordController,
                            hintText: 'Password',
                            onChanged: (value) {},
                            passwordVisible: !passResetCon.passwordVisible,
                            keyboardType: TextInputType.text,
                            prefixIcon: AssetsConstants.passwordIconSvg,
                            suffixIcon: passResetCon.passwordVisible
                                ? AssetsConstants.passwordInvisibelSvg
                                : AssetsConstants.passwordVisibleSvg,
                            // validator: (text)=>validateField(text!),
                            suffixOnTap: () {
                              passResetCon.passwordVisible = !passResetCon.passwordVisible;
                              passResetCon.update();
                            },
                          ),
                          AppSpace.spaceH10,
                          CustomEditTextFormField(
                            controller: confirmPasswordController,
                            hintText: 'Confirm Password',
                            onChanged: (value) {},
                            passwordVisible: !passResetCon.confirmPasswordVisible,
                            keyboardType: TextInputType.text,
                            prefixIcon: AssetsConstants.passwordIconSvg,
                            suffixIcon: passResetCon.confirmPasswordVisible
                                ? AssetsConstants.passwordInvisibelSvg
                                : AssetsConstants.passwordVisibleSvg,
                            // validator: (text)=>validateField(text!),
                            suffixOnTap: () {
                              passResetCon.confirmPasswordVisible = !passResetCon.confirmPasswordVisible;
                              passResetCon.update();
                            },
                            // validator: (value){
                            //   if (passwordController != confirmPasswordController) {
                            //     // Get.snackbar('Validation Error', 'Passwords do not match');
                            //     return 'Passwords do not match';
                            //   }
                            //   return null;
                            // },
                          ),

                          AppSpace.spaceH30,
                          CustomButton(
                            isLoading: passResetCon.isLoading,
                            onPressed: () {
                              if (oldPasswordController.text.isEmpty) {
                                Helpers.snackbarForErorr2(bodyText: 'Please enter old password');
                              } else if (passwordController.text.isEmpty) {
                                Helpers.snackbarForErorr2(bodyText: 'Please enter password');
                              } else if (passwordController.text != confirmPasswordController.text) {
                                Helpers.snackbarForErorr2(bodyText: 'Passwords do not match');
                              } else {
                                // passResetCon.changePassword(oldPasswordController.text, passwordController.text);
                              }
                            },
                            title: AppTranslations.login.tr,
                          ),
                          AppSpace.spaceH20,
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    Positioned(
                      right: -10,
                      top: -15,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      isScrollControlled: true,
      isDismissible: false,
    );
  } */

  Widget itemHeader(BuildContext context, {required String title}) {
    return Container(
      height: 40,
      color: ColorConstants.secondaryColorLight,
      padding: .only(left: 30),
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: Get.textTheme.titleMedium!.copyWith(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
      ),
    );
  }

  Widget customDrawerItem(
    BuildContext context, {
    required String image,
    required String title,
    required VoidCallback onTap,
    bool isLogin = false, // ডিফল্টভাবে false থাকবে
  }) {
    return InkWell(
      onTap: () async {
        // 🚀 যদি বাটনটিতে লগিন রিকোয়ার্ড (isLogin: true) হয়
        if (isLogin) {
          var token = await StorageService.read(StorageConstants.token);
          if (token == null) {
            Helpers.showLoginRequiredDialog();
            return; // টোকেন না থাকলে এখানেই থেমে যাবে, onTap কল হবে না
          }
        }

        // 🚀 যদি isLogin false হয় অথবা টোকেন থাকে, তবেই onTap কল হবে
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 30, top: 10), // 🚀 Syntax Fixed
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomSvgIcon(assetName: image, size: 20, color: context.textColor),
            AppSpace.spaceW6,
            Text(
              title,
              style: Get.textTheme.bodyMedium!.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: context.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final refreshTokenProvider = FutureProvider<String?>((ref) {
  return StorageService.read(StorageConstants.refreshToken).then((value) => value as String?);
});

class CheckTokenWidget extends ConsumerWidget {
  const CheckTokenWidget({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenAsync = ref.watch(refreshTokenProvider);

    return tokenAsync.when(
      data: (refreshToken) => refreshToken != null ? child : const SizedBox(),
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}
