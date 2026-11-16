/// Shared timeout settings for automatic logout after an app background pause.
class SessionTimeoutConfig {
  static const Duration backgroundLogoutTimeout = Duration(minutes: 3);
  static const String backgroundedAtStorageKey = 'session_backgrounded_at';
}
