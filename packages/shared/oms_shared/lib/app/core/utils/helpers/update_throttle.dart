import 'dart:async';

/// Limits how often a live-data UI refresh runs.
///
/// The first call after a quiet [interval] runs at once; calls inside the
/// interval are collapsed into one trailing run [interval] after the last
/// call, so the screen always ends on the latest data. This is the same
/// leading + trailing pattern the market list and index list already use.
class UpdateThrottle {
  UpdateThrottle({
    this.interval = const Duration(milliseconds: 500),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final Duration interval;
  final DateTime Function() _now;
  DateTime? _lastRun;
  Timer? _trailing;

  void run(void Function() action) {
    final now = _now();
    _trailing?.cancel();
    final last = _lastRun;
    if (last == null || now.difference(last) > interval) {
      _lastRun = now;
      action();
    } else {
      _trailing = Timer(interval, action);
    }
  }

  /// Marks [action]-equivalent work as just done (e.g. an immediate refresh
  /// done elsewhere) and drops any pending trailing run.
  void reset() {
    _trailing?.cancel();
    _lastRun = _now();
  }

  void cancel() => _trailing?.cancel();
}
