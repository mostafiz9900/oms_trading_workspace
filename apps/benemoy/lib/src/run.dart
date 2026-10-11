import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:oms_shared/oms_shared.dart';

import '../firebase_options.dart';
import 'app.dart';
import 'house_profile.dart';

/// Shared startup for every Benemoy flavor entry point.
Future<void> runBenemoy(OmsEnvironment environment) => runOmsApp(
  environment: environment,
  profile: benemoyProfile,
  firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  firebaseBackgroundHandler: _firebaseBackgroundHandler,
  app: () => const App(),
);

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) =>
    NotificationService.handleBackgroundMessage(
      message,
      DefaultFirebaseOptions.currentPlatform,
    );
