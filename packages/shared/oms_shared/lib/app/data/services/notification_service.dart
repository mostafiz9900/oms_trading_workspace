import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../app_pkg.dart';
import 'local_notification_service.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// [backgroundHandler] must be a top-level `@pragma('vm:entry-point')`
  /// function in the app that calls [handleBackgroundMessage] with the app's
  /// own Firebase options (background isolates cannot see injected state).
  static Future<void> initialize({required BackgroundMessageHandler backgroundHandler}) async {
    // Initialize local notifications
    await LocalNotificationService.initialize();

    // Request permissions
    await _requestPermissions();

    // Get FCM token
    final token = await _getToken();
    if (token != null) {
      await _saveToken(token);
    }

    // Setup message handlers
    _setupForegroundHandler();
    _setupBackgroundHandler(backgroundHandler);
    _setupTerminatedHandler();

    // Token refresh listener
    _fcm.onTokenRefresh.listen((token) {
      printLog('🔄 Token refreshed: $token');
      _saveToken(token);
    });
  }

  static Future<void> _requestPermissions() async {
    NotificationSettings settings = await _fcm.requestPermission(alert: true, badge: true, sound: true);
    printLog('✅ Permission status: ${settings.authorizationStatus}');
  }

  static Future<String?> _getToken() async {
    try {
      if (Platform.isIOS) {
        // Wait for the APNS token to be available
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();

        int retryCount = 0;
        while (apnsToken == null && retryCount < 5) {
          await Future.delayed(const Duration(seconds: 1));
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          retryCount++;
        }

        if (apnsToken == null) {
          printLog("APNS token is still null after retries.");
          return null;
        }
      }

      // Internet connection ba network issue handle korar jonno try-catch
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      printLog("Failed to get Firebase FCM token: $e");
      return null;
    }
  }

  static Future<void> _saveToken(String token) async {
    await StorageService.save(StorageConstants.fcmToken, token);
    printLog('💾 Token saved: $token');
  }

  static void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      printLog('📨 Foreground message received$message');
      _showNotification(message);
    });
  }

  static void _setupBackgroundHandler(BackgroundMessageHandler backgroundHandler) {
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message, FirebaseOptions options) async {
    printLog('📨 Background message received');
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: options);
    }
    await LocalNotificationService.initialize();
    await _showNotification(message);
  }

  static void _setupTerminatedHandler() async {
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      printLog('📨 App opened from terminated state');
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      printLog('📨 App opened from background');
      _handleMessage(message);
    });
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;
    printLog('  📨 Data payload: $data');
    printLog('notification payload: ${notification?.toMap()}');

    if (notification != null) {
      final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      final imageUrl = data['imageUrl'] ?? notification.android?.imageUrl;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        await LocalNotificationService.showBigImageNotification(
          id: id,
          title: notification.title ?? AppConfig.houseName,
          body: notification.body ?? '',
          imageUrl: imageUrl,
          payload: data.isNotEmpty ? data.toString() : null,
        );
      } else {
        await LocalNotificationService.showNotification(
          id: id,
          title: notification.title ?? AppConfig.houseName,
          body: notification.body ?? '',
          payload: data.isNotEmpty ? data.toString() : null,
        );
      }
    }
  }

  static void _handleMessage(RemoteMessage message) {
    final data = message.data;
    final screen = data['screen'];

    if (screen != null) {
      // TODO: Navigate to specific screen based on your app's routes
      printLog('Navigate to: $screen');
    }
  }

  // Public methods
  static Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
    printLog('📡 Subscribed to: $topic');
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
    printLog('📡 Unsubscribed from: $topic');
  }
}
