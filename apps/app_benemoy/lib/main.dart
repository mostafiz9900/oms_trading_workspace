import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:oms_shared/oms_shared.dart';

import 'firebase_options.dart';
import 'house_profile.dart';

void main() => runOmsApp(
  profile: benemoyProfile,
  firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  firebaseBackgroundHandler: _firebaseBackgroundHandler,
);

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) =>
    NotificationService.handleBackgroundMessage(
      message,
      DefaultFirebaseOptions.currentPlatform,
    );
