/// Shared timeout settings for automatic logout after an app background pause.
class SessionTimeoutConfig {
  static const Duration backgroundLogoutTimeout = Duration(minutes: 5);
  static const String backgroundedAtStorageKey = 'session_backgrounded_at';
}
