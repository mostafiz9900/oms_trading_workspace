/// Shared OMS trading application. A broker-house app only supplies its
/// [HouseProfile], Firebase options, native config, brand assets and a
/// `--dart-define-from-file` environment profile.
library;

export 'package:broker_config/broker_config.dart'
    show HouseProfile, HouseContact, HouseStoreListing, OmsEnvironment;

export 'app/data/services/notification_service.dart' show NotificationService;
export 'bootstrap.dart' show OmsErrorReporter, runOmsApp;
