import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(settings: settings, onDidReceiveNotificationResponse: _onNotificationTap);
  }

  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      print('Notification tapped with payload: $payload');
      // You can handle navigation here
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'benemoy_channel',
      'Benemoy Notifications',
      channelDescription: 'Notification channel for Benemoy app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(id: id, title: title, body: body, notificationDetails: details, payload: payload);
  }

  static Future<void> showBigImageNotification({
    required int id,
    required String title,
    required String body,
    required String imageUrl,
    String? payload,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'benemoy_image_channel',
      'Benemoy Image Notifications',
      channelDescription: 'Notification channel for images',
      importance: Importance.high,
      priority: Priority.high,
      // styleInformation: BigPictureStyleInformation(
      // NetworkPathAndroidBitmap(imageUrl),
      // contentTitle: title,
      // summaryText: body,
      // ),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    NotificationDetails details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(id: id, title: title, body: body, notificationDetails: details, payload: payload);
  }
}
