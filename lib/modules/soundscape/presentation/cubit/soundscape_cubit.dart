import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/soundscape_repository_impl.dart';
import '../../domain/entities/soundscape_item.dart';
import '../../domain/enums/soundscape_category.dart';
import '../../domain/enums/wave_style.dart';
import '../../domain/repositories/soundscape_repository.dart';
import '../../domain/services/audio_player_service.dart';
import '../../services/just_audio_player_service.dart';
import 'soundscape_state.dart';

class SoundscapeCubit extends Cubit<SoundscapeState> {
  SoundscapeCubit({
    SoundscapeRepository? repository,
    AudioPlayerService? audioService,
  }) : _repository = repository ?? const SoundscapeRepositoryImpl(),
       _audioService = audioService ?? JustAudioPlayerService(),
       super(_createInitialState(repository ?? const SoundscapeRepositoryImpl())) {
    _init();
  }

  static const minimumCustomDuration = Duration(minutes: 5);
  static const maximumCustomDuration = Duration(hours: 8);
  static const _endFadeDuration = Duration(seconds: 15);

  final SoundscapeRepository _repository;
  final AudioPlayerService _audioService;
  final Stopwatch _tickerStopwatch = Stopwatch();

  StreamSubscription<AudioEngineStatus>? _audioStatusSubscription;
  Timer? _tickerTimer;
  Duration _lastTickerElapsed = Duration.zero;
  String? _loadedSoundscapeId;
  bool _isFadingOutAtEnd = false;
  bool _isPlaybackTransitionInProgress = false;

  static SoundscapeState _createInitialState(SoundscapeRepository repo) {
    final defaultItem = repo.getDefaultSoundscape();
    final items = repo.getByCategory(defaultItem.category);
    return SoundscapeState(
      selectedSoundscape: defaultItem,
      availableSoundscapes: items,
      selectedCategory: defaultItem.category,
    );
  }

  void _init() {
    if (_audioService.currentStatus != AudioEngineStatus.idle) {
      emit(state.copyWith(audioStatus: _audioService.currentStatus));
    }
    _audioStatusSubscription = _audioService.statusStream.listen(
      _handleAudioStatus,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('[SoundscapeCubit] Audio status stream failed: $error');
        _stopTicker();
        emit(state.copyWith(audioStatus: AudioEngineStatus.error));
      },
    );
  }

  void _handleAudioStatus(AudioEngineStatus status) {
    emit(state.copyWith(audioStatus: status));
    if (status == AudioEngineStatus.playing) {
      _startTicker();
    } else {
      _stopTicker();
    }
  }

  /// Chọn danh mục âm thanh.
  Future<void> selectCategory(SoundscapeCategory category) async {
    if (state.selectedCategory == category) return;

    final items = _repository.getByCategory(category);
    if (items.isEmpty) return;

    await _selectSoundscape(items.first, items: items);
  }

  /// Chọn một soundscape cụ thể trong danh mục.
  Future<void> selectSoundscape(SoundscapeItem soundscape) async {
    if (state.selectedSoundscape.id == soundscape.id) return;
    await _selectSoundscape(soundscape);
  }

  Future<void> _selectSoundscape(
    SoundscapeItem soundscape, {
    List<SoundscapeItem>? items,
  }) async {
    final wasPlaying = state.isPlaying;
    emit(
      state.copyWith(
        selectedSoundscape: soundscape,
        selectedCategory: soundscape.category,
        availableSoundscapes:
            items ?? _repository.getByCategory(soundscape.category),
      ),
    );

    if ((wasPlaying || state.isLoading) &&
        !_isPlaybackTransitionInProgress) {
      _isPlaybackTransitionInProgress = true;
      try {
        await _playSelectedSoundscape();
      } finally {
        _isPlaybackTransitionInProgress = false;
      }
    }
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Bắt đầu phiên mới hoặc tiếp tục phiên đang tạm dừng.
  Future<void> play() async {
    if (state.isLoading ||
        state.isPlaying ||
        _isPlaybackTransitionInProgress) {
      return;
    }

    _isPlaybackTransitionInProgress = true;
    try {
      _isFadingOutAtEnd = false;
      if (state.remainingDuration != null &&
          state.remainingDuration! <= Duration.zero) {
        emit(
          state.copyWith(
            remainingDuration: () => state.selectedDuration,
            elapsedDuration: Duration.zero,
          ),
        );
      }

      if (state.audioStatus == AudioEngineStatus.paused &&
          _loadedSoundscapeId == state.selectedSoundscape.id) {
        await _runAudioAction(_audioService.resume);
        return;
      }

      await _playSelectedSoundscape();
    } finally {
      _isPlaybackTransitionInProgress = false;
    }
  }

  Future<void> _playSelectedSoundscape() async {
    while (true) {
      final soundscape = state.selectedSoundscape;
      await _runAudioAction(() => _audioService.playSoundscape(soundscape));
      if (state.audioStatus == AudioEngineStatus.error) return;

      _loadedSoundscapeId = soundscape.id;
      if (state.selectedSoundscape.id == soundscape.id) return;
    }
  }

  Future<void> pause() async {
    if (state.audioStatus != AudioEngineStatus.playing ||
        _isPlaybackTransitionInProgress) {
      return;
    }
    _isPlaybackTransitionInProgress = true;
    _stopTicker();
    if (state.remainingDuration != null &&
        state.remainingDuration! <= _endFadeDuration) {
      _isFadingOutAtEnd = false;
    }
    try {
      await _runAudioAction(_audioService.pause);
    } finally {
      _isPlaybackTransitionInProgress = false;
    }
  }

  /// Stops the current session and resets the next play to the start.
  Future<void> stop() async {
    _stopTicker();
    _isFadingOutAtEnd = false;
    await _runAudioAction(
      () => _audioService.stop(fadeOutDuration: Duration.zero),
    );
    _loadedSoundscapeId = null;
    emit(
      state.copyWith(
        remainingDuration: () => state.selectedDuration,
        elapsedDuration: Duration.zero,
      ),
    );
  }

  /// Timer changes restart the countdown from the selection time without
  /// interrupting audio playback.
  void selectDuration(Duration? duration) {
    if (duration != null &&
        (duration < minimumCustomDuration ||
            duration > maximumCustomDuration)) {
      throw ArgumentError.value(
        duration,
        'duration',
        'Must be between 5 minutes and 8 hours.',
      );
    }

    emit(
      state.copyWith(
        selectedDuration: () => duration,
        remainingDuration: () => duration,
        elapsedDuration: Duration.zero,
      ),
    );
    _isFadingOutAtEnd = false;

    if (state.isPlaying) {
      unawaited(_runAudioAction(() => _audioService.setVolume(1.0)));
    }
  }

  void toggleControlsVisibility() {
    emit(state.copyWith(isControlsVisible: !state.isControlsVisible));
  }

  /// Thiết lập kiểu ảnh động thủ công. Truyền null để tự động chọn theo track (Auto).
  void setManualWaveStyle(WaveStyle? waveStyle) {
    emit(state.copyWith(manualWaveStyle: () => waveStyle));
  }

  void _startTicker() {
    if (_tickerTimer != null) return;
    _tickerStopwatch
      ..reset()
      ..start();
    _lastTickerElapsed = Duration.zero;
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _tick();
    });
  }

  void _stopTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = null;
    _tickerStopwatch.stop();
  }

  void _tick() {
    final elapsed = _tickerStopwatch.elapsed;
    final delta = elapsed - _lastTickerElapsed;
    if (delta <= Duration.zero) return;
    _lastTickerElapsed = elapsed;

    final newElapsed = state.elapsedDuration + delta;
    if (state.isEndless) {
      emit(state.copyWith(elapsedDuration: newElapsed));
      return;
    }

    final currentRemaining = state.remainingDuration ?? Duration.zero;
    final newRemaining = currentRemaining - delta;
    if (newRemaining <= Duration.zero) {
      _stopTicker();
      emit(
        state.copyWith(
          remainingDuration: () => Duration.zero,
          elapsedDuration: state.selectedDuration ?? newElapsed,
        ),
      );
      unawaited(_finishSession());
      return;
    }

    emit(
      state.copyWith(
        remainingDuration: () => newRemaining,
        elapsedDuration: newElapsed,
      ),
    );

    if (newRemaining <= _endFadeDuration && !_isFadingOutAtEnd) {
      _isFadingOutAtEnd = true;
      unawaited(
        _runAudioAction(
          () => _audioService.fadeOut(duration: newRemaining),
        ),
      );
    }
  }

  Future<void> _finishSession() async {
    await _runAudioAction(
      () => _audioService.stop(fadeOutDuration: Duration.zero),
    );
    _loadedSoundscapeId = null;
    _isFadingOutAtEnd = false;
  }

  Future<void> _runAudioAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stackTrace) {
      debugPrint('[SoundscapeCubit] Audio action failed: $error\n$stackTrace');
      _stopTicker();
      emit(state.copyWith(audioStatus: AudioEngineStatus.error));
    }
  }

  @override
  Future<void> close() async {
    _stopTicker();
    await _audioStatusSubscription?.cancel();
    await _audioService.dispose();
    return super.close();
  }
}
