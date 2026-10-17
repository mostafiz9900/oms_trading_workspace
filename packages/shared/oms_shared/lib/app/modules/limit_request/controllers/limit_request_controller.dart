import 'dart:io';

import '../../../core/utils/extensions/app_context.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../core/utils/helpers/log_helper.dart';
import '../../../core/values/app_config.dart';
import '../../../core/values/colors.dart';
import '../../../core/values/storage.dart';
import '../../../data/services/storage_service.dart';
import '../../../global_widgets/custom_edit_text_form_field.dart';
import '../../../global_widgets/shared_market_components.dart';
import '../../home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class LimitRequestController extends GetxController {
  final GetConnect _connect = GetConnect();
  final ScrollController scrollController = ScrollController();
  final homeController = Get.find<HomeController>();

  bool isLoading = false;
  bool isMoreLoading = false;

  int currentPage = 1;
  int totalPages = 1;

  List clientLimitList = [];

  final String baseUrl = "${AppConfig.baseUrl}api/broker_house/client-limit-requests/";
  late String token;

  /// form fields
  String selectedMarket = 'public';
  final TextEditingController amountController = TextEditingController();
  XFile? selectedFile;
  final ImagePicker _picker = ImagePicker();
  bool isSubmitting = false;
  bool isShortView = false;

  @override
  void onInit() {
    super.onInit();
    _initTokenAndApi();
    _scrollListener();
  }

  void _scrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 150 &&
          !isMoreLoading &&
          currentPage < totalPages) {
        fetchClientLimits(page: currentPage + 1);
      }
    });
  }

  Future<void> _initTokenAndApi() async {
    token = await StorageService.read(StorageConstants.token);

    _connect.httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Authorization'] = "Bearer $token"; // 🔥 only token
      request.headers['Accept'] = 'application/json';
      return request;
    });

    fetchClientLimits(page: 1);
  }

  // Toggle Method
  void toggleViewMode() {
    isShortView = !isShortView;
    update(); // UI আপডেট করবে
  }

  String formatDateTime(String rawDate) {
    try {
      final DateTime dateTime = DateTime.parse(rawDate);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return rawDate;
    }
  }

  Future<void> fetchClientLimits({required int page}) async {
    if (page == 1) {
      isLoading = true;
    } else {
      isMoreLoading = true;
    }
    update();
    var investorCode = homeController.userInfo.userDetail?.investorCode;
    printLog('investorCode:::: $investorCode');
    try {
      final Response response = await _connect.get(
        baseUrl,
        query: {"investor_code": investorCode, "page": page.toString()},
      );

      printLog('response ====: ${response.body}');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final List data = response.body['data'];

        if (page == 1) {
          clientLimitList = data;
        } else {
          clientLimitList.addAll(data);
        }

        currentPage = page;
        totalPages = response.body['total_pages'] ?? 1;
      }
    } on Exception catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading = false;
      isMoreLoading = false;
      update();
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    amountController.dispose();
    super.onClose();
  }

  void removeSelectedFile() {
    selectedFile = null;
    update();
  }

  /// open dialog
  /// open dialog (Upgraded Premium UI with Custom Dropdown & Scroll Fix)
  /// open dialog (Upgraded Premium UI: Same Row for Dropdown & Input)
  void openLimitRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, //  ফাঁকা জায়গায় ক্লিক করলে ডায়ালগ আর গায়েব হবে না
      builder: (_) {
        return Dialog(
          backgroundColor: context.bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: GetBuilder<LimitRequestController>(
            builder: (controller) {
              //  SingleChildScrollView অ্যাড করা হয়েছে, তাই কীবোর্ড ওপেন হলেও আর OverFlow/ফাঁটা এরর আসবে না!
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //  Header & Close Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Limit Request",
                            style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 18),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              controller.clearForm();
                              Get.back(); // ডায়ালগ ক্লোজ করবে
                            },
                            child: Icon(Icons.close, color: context.textColor, size: 24),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: context.dividerColor),
                      ),

                      //   Market & Amount on the SAME ROW
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2, //  প্রোপোরশনাল স্পেসিং
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Market",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CommonMinimalDropdown(
                                  currentValue: controller.selectedMarket,
                                  items: const ['public', 'block', 'Debt'],
                                  onSelected: (value) {
                                    controller.selectedMarket = value;
                                    controller.update();
                                  },
                                  widthDropdown: 90,
                                  heightDropdownButton: 45,
                                  isExpanded: true,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16), // মাঝখানের স্পেসিং
                          Expanded(
                            flex: 4, //  অ্যামাউন্ট ফিল্ডে টাইপ করার জন্য একটু বেশি জায়গা দেওয়া হলো
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: "Amount",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade500,
                                    ),
                                    children: const [
                                      TextSpan(
                                        text: "*",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const SizedBox(height: 8),
                                CustomEditTextFormField(
                                  controller: controller.amountController,
                                  keyboardType: TextInputType.number,
                                  hintText: "e.g. 50,000",
                                  onChanged: (value) {},
                                  borderRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      //  File Upload & Preview Section
                      Text(
                        "Upload Receipt(Accepted formates: JPG,PNG)",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 8),

                      if (controller.selectedFile == null)
                        InkWell(
                          onTap: () => controller.openFilePicker(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withAlpha(13),
                              border: Border.all(color: Colors.blueAccent.withAlpha(77), width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.cloud_upload_outlined, size: 36, color: Colors.blueAccent),
                                SizedBox(height: 8),
                                Text(
                                  "Tap to upload receipt",
                                  style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w700),
                                ),
                                SizedBox(height: 4),
                                Text("JPG, PNG support", style: TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: context.bgColor,
                            border: Border.all(color: context.borderSideColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: ColorConstants.success.withAlpha(26),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(Icons.image, color: ColorConstants.success, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.selectedFile!.name,
                                      style: Get.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: context.textColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Ready to submit",
                                      style: TextStyle(fontSize: 11, color: ColorConstants.success),
                                    ),
                                  ],
                                ),
                              ),
                              //  ফাইল রিমুভ করার বাটন
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                splashRadius: 20,
                                onPressed: () {
                                  controller.removeSelectedFile();
                                },
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 28),

                      //  Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.buttonColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          onPressed: controller.isSubmitting ? null : () => controller.submitLimitRequest(context),
                          child: controller.isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                )
                              : const Text(
                                  "Submit Request",
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// file picker
  void openFilePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () async {
                Get.back();
                selectedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                update();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () async {
                Get.back();
                selectedFile = await _picker.pickImage(source: ImageSource.gallery);
                update();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// -------- POST LIMIT REQUEST ----------
  Future<void> submitLimitRequest(BuildContext dialogContext) async {
    var investorCode = homeController.userInfo.userDetail?.investorCode;

    if (amountController.text.isEmpty) {
      Helpers.snackbarForErorr2(titleText: "Error", bodyText: "Amount is required. Please enter an amount.");
      return;
    }

    if (investorCode == null) {
      Helpers.snackbarForErorr2(titleText: "Error", bodyText: "Investor code not found. Please re-login.");
      return;
    }

    if (!await checkInternet()) return;
    if (isSubmitting) return;

    isSubmitting = true;
    update();

    try {
      //  ২. ডাইনামিক ম্যাপ তৈরি করা হলো
      Map<String, dynamic> requestData = {
        "requested_amount": amountController.text.trim(),
        "investor_code": investorCode,
        "market": selectedMarket,
      };

      //  ৩. যদি ইউজার ফাইল সিলেক্ট করে থাকে, তবেই সেটি ম্যাপে যুক্ত হবে
      if (selectedFile != null) {
        final file = File(selectedFile!.path);
        final fileName = selectedFile!.name;
        final ext = fileName.split('.').last.toLowerCase();
        final mimeType = (ext == 'png') ? 'image/png' : 'image/jpeg';

        requestData["receipt"] = MultipartFile(file, filename: fileName, contentType: mimeType);
      }

      // ম্যাপ থেকে FormData তৈরি করা হলো
      final formData = FormData(requestData);

      final Response response = await _connect.post(baseUrl, formData);

      //  ৪. Robust Response Handling
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (dialogContext.mounted) {
          Navigator.of(dialogContext).pop();
        } else {
          Get.back(); // Fallback
        }

        Helpers.snackBarForSuccess2(
          titleText: "Success",
          bodyText: response.body?['message'] ?? "Limit request submitted successfully",
        );
        clearForm();
        fetchClientLimits(page: 1);
      } else {
        String errorMsg = response.body?['message'] ?? "Failed to submit request. Please try again later.";
        Helpers.snackbarForErorr2(titleText: "Request Failed", bodyText: errorMsg);
      }
    } catch (e) {
      //  Catch Exception safely
      Helpers.snackbarForErorr2(titleText: "Exception", bodyText: "An unexpected error occurred: ${e.toString()}");
    } finally {
      isSubmitting = false;
      update();
    }
  }

  /// reset form
  void clearForm() {
    selectedMarket = 'block';
    amountController.clear();
    selectedFile = null;
    update();
  }
}
