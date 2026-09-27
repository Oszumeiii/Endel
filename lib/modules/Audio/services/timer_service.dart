import 'package:rvc_mobile_application/modules/focus/domain/enums/focus_mode.dart';

abstract interface class FocusTimerService {
  void configure({
    required FocusMode mode,
    required Duration duration,
  });

  void start();

  void pause();

  void resume();

  void reset();

  Duration get remaining;

  Duration get elapsed;

  bool get isRunning;

  void dispose();
}
