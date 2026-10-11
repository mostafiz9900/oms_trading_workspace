import 'package:oms_shared/app/data/models/response/user_balance.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// আপনার প্রোজেক্টের মডেল এবং অন্যান্য ইম্পোর্টগুলো এখানে ঠিকঠাক আছে কি না দেখে নিবেন
import '../../../app_pkg.dart';
import '../../../data/models/request/withdraw_request.dart';
import '../../../data/models/response/withdraw_model.dart';

class WithdrawalRequestController extends GetxController {
  HomeController homeController = Get.find<HomeController>();

  // ==========================================
  // 🟢 State Variables (For GetBuilder)
  // ==========================================
  bool isFetching = false;
  bool isSubmitting = false;
  List<WithdrawModel> withdrawList = [];

  // 🟢 Form Controllers
  final TextEditingController amountController = TextEditingController();
  final TextEditingController narrationController = TextEditingController();
  UserBalance? userBalance;
  @override
  void onInit() {
    super.onInit();
    userBalance = homeController.userBalanceData;
    printLog('withdrawal request : controller init: ${homeController.userInfo.toJson()}');
    fetchWithdrawList();
  }

  @override
  void onClose() {
    amountController.dispose();
    narrationController.dispose();
    super.onClose();
  }

  // ==========================================
  // 🟢 1. Fetch Withdraw List
  // ==========================================
  Future<void> fetchWithdrawList() async {
    if (!await checkInternet()) return;

    isFetching = true;
    update(); // UI আপডেট করার জন্য update() কল করা হলো (GetBuilder)
    var investorCode = homeController.userInfo.userDetail?.investorCode;

    if (investorCode == null || investorCode.isEmpty) {
      Helpers.snackbarForErorr2(titleText: "Error", bodyText: "Investor code not found. Please re-login.");
      return;
    }
    try {
      final response = await homeController.homeRepository.getWithdrawList(investorCode);

      if (response.data != null) {
        withdrawList = response.data!;
      } else {
        Helpers.snackbarForErorr2(
          titleText: "Error",
          bodyText: response.errorMessage ?? "Failed to load withdraw list",
        );
      }
    } catch (e) {
      Helpers.snackbarForErorr2(titleText: "Exception", bodyText: "Something went wrong: ${e.toString()}");
    } finally {
      isFetching = false;
      update(); // স্পিনার বন্ধ করে লিস্ট দেখানোর জন্য update()
    }
  }

  // ==========================================
  // 🟢 2. Create Withdraw Request
  // ==========================================
  Future<void> submitWithdrawRequest(BuildContext context) async {
    // 1. Validation Check
    double enteredAmount = double.tryParse(amountController.text.trim()) ?? 0.0;
    double availableAmount = userBalance?.amount ?? 0.0;

    if (amountController.text.trim().isEmpty || enteredAmount <= 0) {
      Helpers.snackbarForErorr2(titleText: "Validation Error", bodyText: "Please enter a valid withdraw amount.");
      return;
    }

    if (enteredAmount > availableAmount) {
      Helpers.snackbarForErorr2(
        titleText: "Validation Error",
        bodyText: "Withdraw amount cannot exceed your available balance.",
      );
      return;
    }

    // Narration Required Validation
    if (narrationController.text.trim().isEmpty) {
      Helpers.snackbarForErorr2(
        titleText: "Validation Error",
        bodyText: "Please enter a narration for your withdrawal.",
      );
      return;
    }
    // 2. Get Investor Code
    var investorCode = homeController.userInfo.userDetail?.investorCode;

    if (investorCode == null || investorCode.isEmpty) {
      Helpers.snackbarForErorr2(titleText: "Error", bodyText: "Investor code not found. Please re-login.");
      return;
    }

    // 3. Internet & Duplicate Submission Check
    if (!await checkInternet()) return;
    if (isSubmitting) return;

    isSubmitting = true;
    update();

    try {
      // 4. Map Data to WithdrawRequest Model
      WithdrawRequest requestData = WithdrawRequest(
        investorCode: investorCode,
        withdrawRequest: amountController.text.trim(),
        narration: narrationController.text.trim().isEmpty ? null : narrationController.text.trim(),
      );

      // 5. Call API
      final response = await homeController.homeRepository.createWithdraw(requestData);

      if (response.data != null) {
        // Context Safety (যদি ডায়ালগ থেকে রিকোয়েস্ট করা হয়)
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        Helpers.snackBarForSuccess2(
          titleText: "Success",
          bodyText: response.data ?? "Withdraw request submitted successfully",
        );

        clearForm();
        fetchWithdrawList(); // অটো রিফ্রেশ
      } else {
        Helpers.snackbarForErorr2(
          titleText: "Request Failed",
          bodyText: response.errorMessage ?? "Failed to submit request",
        );
      }
    } catch (e) {
      Helpers.snackbarForErorr2(titleText: "Exception", bodyText: "Something went wrong: ${e.toString()}");
    } finally {
      isSubmitting = false;
      update();
    }
  }

  // ==========================================
  // 🟢 3. Clear Form Helper
  // ==========================================
  void clearForm() {
    amountController.clear();
    narrationController.clear();
    update();
  }
}
