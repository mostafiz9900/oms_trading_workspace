import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:oms_shared/oms_shared.dart';

import '../firebase_options.dart';
import 'app.dart';
import 'house_profile.dart';

/// Shared startup for both entry points (main_uat.dart, main_prod.dart).
Future<void> bootstrap(OmsEnvironment environment) => runOmsApp(
  environment: environment,
  profile: houseProfile,
  firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  firebaseBackgroundHandler: _firebaseBackgroundHandler,
  app: () => const App(),
  reportError: _reportToCrashlytics,
);

/// Sends uncaught errors from release builds to Firebase Crashlytics.
void _reportToCrashlytics(Object error, StackTrace? stack, {required bool fatal}) {
  // Debug builds only log; errors before Firebase is ready cannot be sent.
  if (kDebugMode || Firebase.apps.isEmpty) return;
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: fatal);
}

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) =>
    NotificationService.handleBackgroundMessage(
      message,
      DefaultFirebaseOptions.currentPlatform,
    );
