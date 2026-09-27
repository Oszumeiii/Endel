import 'timer_strategy.dart';

class CountdownTimerStrategy implements TimerStrategy {
  CountdownTimerStrategy({
    required this.duration,
  });

  final Duration duration;

  DateTime? _endTime;
  Duration _pausedRemaining = Duration.zero;

  bool _isRunning = false;

  @override
  bool get isRunning => _isRunning;

  @override
  Duration get remaining {
    if (!_isRunning) {
      return _pausedRemaining;
    }

    final value = _endTime!.difference(DateTime.now());

    if (value.isNegative) {
      return Duration.zero;
    }

    return value;
  }

  @override
  Duration get elapsed {
    return duration - remaining;
  }

  @override
  void start() {
    _endTime = DateTime.now().add(duration);
    _isRunning = true;
  }

  @override
  void pause() {
    if (!_isRunning) return;

    _pausedRemaining = remaining;
    _isRunning = false;
  }

  @override
  void resume() {
    if (_isRunning) return;

    _endTime = DateTime.now().add(_pausedRemaining);
    _isRunning = true;
  }

  @override
  void reset() {
    _endTime = null;
    _pausedRemaining = duration;
    _isRunning = false;
  }

  @override
  void dispose() {
    _endTime = null;
  }
}
