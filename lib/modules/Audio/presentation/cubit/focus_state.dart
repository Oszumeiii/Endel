import 'package:rvc_mobile_application/modules/focus/domain/enums/background_sound.dart';
import 'package:rvc_mobile_application/modules/focus/domain/enums/focus_status.dart';
import 'package:rvc_mobile_application/modules/focus/domain/enums/focus_mode.dart';
import 'package:rvc_mobile_application/modules/focus/services/focus_timer_settings.dart';

class FocusState {
  final FocusMode mode;
  final Duration selectedDuration;
  final BackgroundSound sound;

  final FocusStatus status;
  final Duration remaining;
  final Duration elapsed;

  const FocusState({
    this.mode = FocusMode.countdown,
    this.selectedDuration = const Duration(minutes: 30),
    this.sound = BackgroundSound.none,
    this.status = FocusStatus.idle,
    this.remaining = const Duration(minutes: 30),
    this.elapsed = Duration.zero,
  });

  static Duration get defaultDuration => FocusTimerSettings.currentDuration;

  /// Thời gian hiển thị chính (countdown: remaining, stopwatch: elapsed).
  Duration get displayTime =>
      mode == FocusMode.countdown ? remaining : elapsed;

  /// Tiến trình vòng tròn (0.0 → 1.0).
  ///
  /// - Countdown: lượng thời gian còn lại so với tổng (giảm dần).
  /// - Stopwatch: thời gian đã trôi qua so với mốc đã chọn (tăng dần).
  double get progress {
    if (mode == FocusMode.countdown) {
      if (selectedDuration.inMilliseconds == 0) return 0;
      return (remaining.inMilliseconds / selectedDuration.inMilliseconds)
          .clamp(0.0, 1.0);
    }

    if (selectedDuration.inMilliseconds == 0) return 0;
    return (elapsed.inMilliseconds / selectedDuration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  /// Subtitle dưới đồng hồ (countdown: "30 MIN SESSION").
  String get sessionLabel {
    if (mode == FocusMode.stopwatch) return 'STOPWATCH';
    final minutes = selectedDuration.inMinutes == 0
        ? 1
        : selectedDuration.inMinutes;
    return '$minutes MIN SESSION';
  }

  FocusState copyWith({
    FocusMode? mode,
    Duration? selectedDuration,
    BackgroundSound? sound,
    FocusStatus? status,
    Duration? remaining,
    Duration? elapsed,
  }) {
    return FocusState(
      mode: mode ?? this.mode,
      selectedDuration: selectedDuration ?? this.selectedDuration,
      sound: sound ?? this.sound,
      status: status ?? this.status,
      remaining: remaining ?? this.remaining,
      elapsed: elapsed ?? this.elapsed,
    );
  }

  factory FocusState.initial() {
    return const FocusState();
  }
}