import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rvc_mobile_application/modules/focus/domain/enums/background_sound.dart';
import 'package:rvc_mobile_application/modules/focus/domain/enums/focus_mode.dart';
import 'package:rvc_mobile_application/modules/focus/domain/enums/focus_status.dart';
import 'package:rvc_mobile_application/modules/focus/presentation/cubit/focus_state.dart';
import 'package:rvc_mobile_application/modules/focus/services/audio_services.dart';
import 'package:rvc_mobile_application/modules/focus/services/focus_timer_settings.dart';
import 'package:rvc_mobile_application/modules/focus/services/timer_strategy.dart';
import 'package:rvc_mobile_application/modules/focus/services/timer_strategy_factory.dart';

class FocusCubit extends Cubit<FocusState> {
  FocusCubit({
    TimerStrategyFactory? strategyFactory,
    AudioService? audioService,
  })  : _strategyFactory = strategyFactory ?? TimerStrategyFactory(),
        _audioService = audioService ?? AudioServiceImpl(),
        super(
          FocusState(
            selectedDuration: FocusTimerSettings.currentDuration,
            remaining: FocusTimerSettings.currentDuration,
          ),
        );

  final TimerStrategyFactory _strategyFactory;
  final AudioService _audioService;

  TimerStrategy? _strategy;
  Timer? _ticker;

  static const Duration _tickInterval = Duration(milliseconds: 250);

  @override
  Future<void> close() async {
    _stopTicking();
    _strategy?.dispose();
    await _audioService.stopSound();
    await _audioService.dispose();
    await super.close();
  }

  void selectMode(FocusMode mode) {
    if (mode == state.mode) return;

    _stopTicking();
    _strategy?.dispose();
    _strategy = null;

    emit(
      state.copyWith(
        mode: mode,
        status: FocusStatus.idle,
        remaining: mode == FocusMode.countdown
            ? state.selectedDuration
            : Duration.zero,
        elapsed: Duration.zero,
      ),
    );
  }

  void selectDuration(Duration duration) {
    if (duration <= Duration.zero) return;
    if (state.status == FocusStatus.running ||
        state.status == FocusStatus.paused) {
      return;
    }

    FocusTimerSettings.setDuration(duration);
    _strategy?.dispose();
    _strategy = null;

    emit(
      state.copyWith(
        selectedDuration: duration,
        remaining: state.mode == FocusMode.countdown
            ? duration
            : Duration.zero,
        elapsed: Duration.zero,
      ),
    );
  }

  Future<void> selectSound(BackgroundSound sound) async {
    emit(state.copyWith(sound: sound));
    await _playSelectedSound(sound);
  }

  Future<void> start() async {
    if (state.status == FocusStatus.running) return;

    _strategy ??= _createStrategy();
    _strategy!.start();

    emit(state.copyWith(status: FocusStatus.running));
    _startTicking();
    await _playSelectedSound(state.sound);
  }

  Future<void> pause() async {
    if (state.status != FocusStatus.running) return;

    _strategy?.pause();
    _stopTicking();
    _emitTick();
    emit(state.copyWith(status: FocusStatus.paused));
    // Giữ âm nền tiếp tục phát khi tạm dừng (ambient), không restart lại.
  }

  Future<void> resume() async {
    if (state.status != FocusStatus.paused) return;

    _strategy?.resume();
    emit(state.copyWith(status: FocusStatus.running));
    _startTicking();
  }

  Future<void> reset() async {
    _stopTicking();
    _strategy?.reset();
    await _audioService.stopSound();

    emit(
      state.copyWith(
        status: FocusStatus.idle,
        remaining: state.mode == FocusMode.countdown
            ? state.selectedDuration
            : Duration.zero,
        elapsed: Duration.zero,
      ),
    );
  }

  TimerStrategy _createStrategy() {
    return _strategyFactory.create(
      mode: state.mode,
      duration: state.selectedDuration,
    );
  }

  Future<void> _playSelectedSound(BackgroundSound sound) async {
    switch (sound) {
      case BackgroundSound.none:
      case BackgroundSound.tick:
        await _audioService.stopSound();
        return;
      case BackgroundSound.whiteNoise:
        await _audioService.playSound('audio/white_noise.mp3');
        return;
      case BackgroundSound.rain:
        await _audioService.playSound('audio/rain.mp3');
        return;
    }
  }

  void _startTicking() {
    _ticker?.cancel();
    _ticker = Timer.periodic(_tickInterval, (_) => _emitTick());
  }

  void _stopTicking() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _emitTick() {
    final strategy = _strategy;
    if (strategy == null) return;

    final remaining = strategy.remaining;
    final isCompleted =
        state.mode == FocusMode.countdown && remaining == Duration.zero;

    emit(
      state.copyWith(
        remaining: remaining,
        elapsed: strategy.elapsed,
        status: isCompleted ? FocusStatus.completed : state.status,
      ),
    );

    if (isCompleted) {
      _stopTicking();
      _audioService.stopSound();
    }
  }
}