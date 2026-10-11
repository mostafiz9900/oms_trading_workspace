part of '../home_controller.dart';

/// Balance and user info for portfolio, position and account widgets.
mixin PortfolioMixin on HomeState {
  void changeTabPortfolio(int index) {
    currentTabIndexPortfolio = index;
    update();
  }

  @override
  void userBalance() async {
    // 🚀 ১. MAGIC FIX: উইজেট বিল্ড হওয়ার সময় "markNeedsBuild" ক্র্যাশ ঠেকানোর জন্য
    await Future.delayed(Duration.zero);

    isUserBalanceLoading = true;
    update(); // এখন নিশ্চিন্তে আপডেট কল করতে পারেন, ক্র্যাশ করবে না!

    try {
      // 🛡️ সেফটি চেক: যদি সকেট ডিসকানেক্ট থাকে, তবে রিকানেক্ট করবে
      if (!isSocketConnected(AppConfig.userBalanceSocketId)) {
        printLog('🔌 Balance socket disconnected. Reconnecting...');
        await _initializeUserBalanceWebSocket();

        // 🚀 ২. SMART RETRY: সার্ভার স্লো থাকলে ১ সেকেন্ডে কানেক্ট নাও হতে পারে।
        // তাই আমরা ১ সেকেন্ড করে সর্বোচ্চ ৩ বার (Total 3 seconds) চেক করবো।
        int retryCount = 0;
        while (!isSocketConnected(AppConfig.userBalanceSocketId) &&
            retryCount < 3) {
          await Future.delayed(const Duration(seconds: 1));
          retryCount++;
          printLog(
            '⏳ Waiting for balance socket connection... Attempt: $retryCount',
          );
        }
      }

      // 🛡️ ডাবল ভেরিফিকেশন: লুপ শেষ হওয়ার পর চেক করা যে কানেক্ট হলো কি না
      if (isSocketConnected(AppConfig.userBalanceSocketId)) {
        printLog('🔄 ✅ User balance socket is successfully connected.');

        // যদি আগে থেকেই কানেক্টেড থাকে এবং ডেটা থাকে, তবে অযথাই লোডার ঘুরবে না
        if (userBalanceData != null) {
          isUserBalanceLoading = false;
          update();
          return;
        }
      } else {
        // ৩ সেকেন্ড পরও যদি কানেক্ট না হয়, তবেই ফেইল দেখাবে
        printLog(
          '❌ Failed to connect User Balance Socket after 3 seconds of delay.',
        );
        isUserBalanceLoading = false;
        update();
      }
    } catch (e) {
      printLog('❌ Exception in userBalance: $e');
      isUserBalanceLoading = false;
      update();
    }
  }

  // ==========================================
  // ==========================================
  @override
  void _handleUserBalanceMessage(dynamic message) {
    printLog('📩 User Balance Socket Message Received: $message');
    try {
      final jsonResponse = jsonDecode("$message");
      final data = jsonResponse[AppConstants.data];

      if (data != null) {
        printLog('🧾 User Balance Data :: $data');
        var response = userBalanceFromJson(data);

        // সেফটি চেক: রেসপন্স List ফাঁকা কি না চেক করা
        if (response.isNotEmpty) {
          userBalanceData = response.first;
        }
      }
    } catch (e) {
      printLog('❌ Error parsing user balance socket data: $e');
    } finally {
      // 🚀 finally ব্লক ব্যবহার করা হলো, যাতে ডাটা আসুক বা এরর হোক—
      // সব শেষেই যেন গ্যারান্টিডভাবে লোডার অফ হয় এবং UI আপডেট হয়।
      isUserBalanceLoading = false;
      update(['user_balance_update']);
    }
  }

  @override
  void getUserInfo() async {
    try {
      var res = StorageService.getMap(StorageConstants.userInfo);
      if (res != null) {
        UserProfile? user = UserProfile.fromJson(res);
        printLog('User profile loaded: ${user.toJson()}');
        userInfo = user;
        isUserInfoLoaded = true;
        update();
      } else {
        printLog('User info not found in storage');
        isUserInfoLoaded = true; // Still mark as loaded but empty
      }
    } catch (e) {
      printLog('Error loading user info: $e');
      isUserInfoLoaded = true;
    }
  }

}
