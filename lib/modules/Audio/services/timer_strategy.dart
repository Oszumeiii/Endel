abstract interface class TimerStrategy {
  Duration get remaining;

  Duration get elapsed;

  bool get isRunning;

  void start();

  void pause();

  void resume();

  void reset();

  void dispose();
}
