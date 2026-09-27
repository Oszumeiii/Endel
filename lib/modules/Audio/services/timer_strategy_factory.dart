import 'package:rvc_mobile_application/modules/focus/domain/enums/focus_mode.dart';

import 'countdown_timer_strategy.dart';
import 'stopwatch_timer_strategy.dart';
import 'timer_strategy.dart';

class TimerStrategyFactory {
  TimerStrategy create({
    required FocusMode mode,
    required Duration duration,
  }) {
    switch (mode) {
      case FocusMode.countdown:
        return CountdownTimerStrategy(
          duration: duration,
        );

      case FocusMode.stopwatch:
        return StopwatchTimerStrategy();
    }
  }
}
