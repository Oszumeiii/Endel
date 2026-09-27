import 'timer_strategy.dart';

class StopwatchTimerStrategy implements TimerStrategy {
  DateTime? _startedAt;
  Duration _elapsedBeforePause = Duration.zero;

  bool _isRunning = false;

  @override
  bool get isRunning => _isRunning;

  @override
  Duration get elapsed {
    if (!_isRunning) {
      return _elapsedBeforePause;
    }

    return _elapsedBeforePause + DateTime.now().difference(_startedAt!);
  }

  @override
  Duration get remaining => Duration.zero;

  @override
  void start() {
    _startedAt = DateTime.now();
    _elapsedBeforePause = Duration.zero;
    _isRunning = true;
  }

  @override
  void pause() {
    if (!_isRunning) return;

    _elapsedBeforePause = elapsed;
    _isRunning = false;
  }

  @override
  void resume() {
    if (_isRunning) return;

    _startedAt = DateTime.now();
    _isRunning = true;
  }

  @override
  void reset() {
    _startedAt = null;
    _elapsedBeforePause = Duration.zero;
    _isRunning = false;
  }

  @override
  void dispose() {
    _startedAt = null;
  }
}
