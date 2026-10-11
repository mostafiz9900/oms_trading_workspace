import 'package:oms_shared/app/app_pkg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class OtpVerifyScreen extends HookConsumerWidget {
  const OtpVerifyScreen({super.key, required this.email});
  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otpDurationAsync = ref.watch(otpDurationProvider);

    final otpController = useTextEditingController();
    final focusNode = useFocusNode();

    void submitOtp() {
      String otp = otpController.text;
      if (otp.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter the complete 6-digit OTP', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      FocusScope.of(context).unfocus();
      Get.find<AuthController>().verifyOtpForgot(email, otp);
      debugPrint('OTP entered: $otp');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                SvgPicture.asset(context.bannerLogo, width: 80, height: 80, fit: BoxFit.contain),
                const SizedBox(height: 40),

                Text(
                  'Enter 6-digit OTP',
                  style: Get.textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "We have sent a verification code to\n$email",
                  textAlign: TextAlign.center,
                  style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 32),

                HookBuilder(
                  builder: (innerContext) {
                    useListenable(otpController);
                    useListenable(focusNode);

                    final text = otpController.text;

                    return SizedBox(
                      height: 55,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (index) {
                              final isFilled = index < text.length;
                              final char = isFilled ? text[index] : '';

                              // কোন বক্সটি এখন একটিভ আছে তা বের করার লজিক
                              final isActive =
                                  focusNode.hasFocus && (index == text.length || (index == 5 && text.length == 6));

                              return Container(
                                width: 45,
                                height: 55,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: context.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isActive
                                        ? Colors
                                              .blue // একটিভ বক্সের বর্ডার
                                        : (isFilled ? Colors.blue.withOpacity(0.5) : Colors.grey.shade700),
                                    width: isActive ? 2 : 1.5,
                                  ),
                                ),
                                child: Text(
                                  char,
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.textColor),
                                ),
                              );
                            }),
                          ),

                          Positioned.fill(
                            child: TextField(
                              controller: otpController,
                              focusNode: focusNode,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              autofocus: true,
                              cursorColor: Colors.transparent, // কীবোর্ড কার্সার লুকানো
                              showCursor: false,
                              enableInteractiveSelection: false, // কপি/পেস্ট পপআপ অফ রাখা হলো
                              style: const TextStyle(color: Colors.transparent, fontSize: 1), // টেক্সট অদৃশ্য
                              decoration: const InputDecoration(
                                counterText: '', // maxLength এর কাউন্টার লুকানো
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                fillColor: Colors.transparent,
                                filled: true,
                              ),
                              onChanged: (val) {
                                // ৬ ডিজিট পূরণ হলেই কীবোর্ড নামিয়ে দিবে
                                if (val.length == 6) {
                                  FocusScope.of(context).unfocus();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Action Button
                GetBuilder<AuthController>(
                  builder: (authCon) {
                    return SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        isLoading: authCon.verifyOtpLoading,
                        onPressed: submitOtp,
                        title: 'Verify OTP',
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Countdown Widget
                Center(
                  child: otpDurationAsync.when(
                    data: (minutes) {
                      if (minutes == 0) {
                        return const Text("Failed to fetch OTP duration");
                      }
                      final notifier = ref.read(countDownProvider(2).notifier);
                      if (!notifier.state.isFinite || notifier.state == minutes * 60) {
                        notifier.start();
                      }
                      return CircularCountdownWidget(apiMinutes: minutes, email: email);
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (err, _) => Text("Error: $err"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//  Circular Countdown Widget
class CircularCountdownWidget extends ConsumerWidget {
  final int apiMinutes;
  final double size;
  final double strokeWidth;
  final String email;

  const CircularCountdownWidget({
    super.key,
    required this.apiMinutes,
    this.size = 70,
    this.strokeWidth = 5,
    required this.email,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seconds = ref.watch(countDownProvider(apiMinutes));
    final totalSeconds = apiMinutes * 60;
    final progress = seconds / totalSeconds;
    final minutesText = (seconds ~/ 60).toString().padLeft(2, '0');
    final secondsText = (seconds % 60).toString().padLeft(2, '0');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: strokeWidth,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation(Colors.blue),
              ),
            ),
            Text(
              "$minutesText:$secondsText",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textColor),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: seconds == 0
              ? () {
                  Get.find<AuthController>().sentOtpForForgotPassword(email, isReset: true);
                  ref.read(countDownProvider(apiMinutes).notifier).reset();
                  ref.read(countDownProvider(apiMinutes).notifier).start();
                }
              : null,
          child: Text(
            "Resend OTP",
            style: TextStyle(color: seconds == 0 ? Colors.green : Colors.grey, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
