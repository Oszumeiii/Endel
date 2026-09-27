import 'package:flutter/foundation.dart';

class FocusTimerSettings {
  FocusTimerSettings._();

  static const Duration _defaultDuration = Duration(minutes: 30);

  static final List<Duration> _durations = [
    const Duration(minutes: 5),
    const Duration(minutes: 15),
    const Duration(minutes: 30),
    const Duration(minutes: 45),
    const Duration(minutes: 60),
    const Duration(minutes: 90),
  ];

  static final ValueNotifier<Duration> duration =
      ValueNotifier(_defaultDuration);

  static Duration get currentDuration => duration.value;

  static List<Duration> get durations => List.unmodifiable(_durations);

  static void addDuration(Duration value) {
    if (value <= Duration.zero) return;

    final exists = _durations.any(
      (item) => item.inMilliseconds == value.inMilliseconds,
    );

    if (!exists) {
      _durations.add(value);
      _durations.sort((a, b) => a.compareTo(b));
    }

    duration.value = value;
  }

  static void setDuration(Duration value) {
    if (value <= Duration.zero) return;

    final exists = _durations.any(
      (item) => item.inMilliseconds == value.inMilliseconds,
    );

    if (!exists) {
      _durations.add(value);
      _durations.sort((a, b) => a.compareTo(b));
    }

    duration.value = value;
  }

  static void reset() {
    _durations
      ..clear()
      ..addAll([
        const Duration(minutes: 5),
        const Duration(minutes: 15),
        const Duration(minutes: 30),
        const Duration(minutes: 45),
        const Duration(minutes: 60),
        const Duration(minutes: 90),
      ]);
    duration.value = _defaultDuration;
  }
}
