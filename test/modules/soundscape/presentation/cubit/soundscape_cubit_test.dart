import 'dart:async';

import 'package:rvc_mobile_application/modules/soundscape/data/soundscape_registry.dart';
import 'package:rvc_mobile_application/modules/soundscape/domain/entities/soundscape_item.dart';
import 'package:rvc_mobile_application/modules/soundscape/domain/enums/soundscape_category.dart';
import 'package:rvc_mobile_application/modules/soundscape/domain/enums/wave_style.dart';
import 'package:rvc_mobile_application/modules/soundscape/domain/services/audio_player_service.dart';
import 'package:rvc_mobile_application/modules/soundscape/presentation/cubit/soundscape_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeAudioPlayerService audioService;
  late SoundscapeCubit cubit;

  setUp(() {
    audioService = _FakeAudioPlayerService();
    cubit = SoundscapeCubit(audioService: audioService);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('resume continues the loaded track without reloading it', () async {
    await cubit.play();
    await _flushStatusEvents();
    await cubit.pause();
    await _flushStatusEvents();

    await cubit.play();
    await _flushStatusEvents();

    expect(audioService.playedSoundscapes, hasLength(1));
    expect(audioService.resumeCalls, 1);
    expect(cubit.state.isPlaying, isTrue);
  });

  test('changing the timer while playing keeps audio playing', () async {
    await cubit.play();
    await _flushStatusEvents();

    cubit.selectDuration(const Duration(minutes: 30));
    await _flushStatusEvents();

    expect(cubit.state.selectedDuration, const Duration(minutes: 30));
    expect(cubit.state.remainingDuration, const Duration(minutes: 30));
    expect(cubit.state.elapsedDuration, Duration.zero);
    expect(cubit.state.isPlaying, isTrue);
    expect(audioService.stopCalls, 0);
  });

  test('pausing freezes the countdown until playback resumes', () async {
    cubit.selectDuration(const Duration(minutes: 5));
    await cubit.play();
    await _flushStatusEvents();
    await Future<void>.delayed(const Duration(milliseconds: 1100));

    await cubit.pause();
    await _flushStatusEvents();
    final remainingAtPause = cubit.state.remainingDuration;
    await Future<void>.delayed(const Duration(milliseconds: 500));

    expect(cubit.state.remainingDuration, remainingAtPause);
    expect(cubit.state.isPaused, isTrue);
  });

  test('selecting a new track while paused loads it on resume', () async {
    await cubit.play();
    await _flushStatusEvents();
    await cubit.pause();
    await _flushStatusEvents();

    final newTrack = SoundscapeRegistry.getByCategory(
      cubit.state.selectedCategory,
    ).last;
    await cubit.selectSoundscape(newTrack);
    await cubit.play();
    await _flushStatusEvents();

    expect(audioService.playedSoundscapes, [
      cubit.state.availableSoundscapes.first,
      newTrack,
    ]);
    expect(audioService.resumeCalls, 0);
    expect(cubit.state.isPlaying, isTrue);
  });

  test('a track chosen while loading becomes the track that plays', () async {
    final loadGate = Completer<void>();
    audioService.playGate = loadGate;

    final startingPlayback = cubit.play();
    await _flushStatusEvents();
    final newTrack = cubit.state.availableSoundscapes.last;
    await cubit.selectSoundscape(newTrack);
    audioService.playGate = null;
    loadGate.complete();
    await startingPlayback;
    await _flushStatusEvents();

    expect(audioService.playedSoundscapes, [
      cubit.state.availableSoundscapes.first,
      newTrack,
    ]);
    expect(cubit.state.selectedSoundscape.id, newTrack.id);
    expect(cubit.state.isPlaying, isTrue);
  });

  test('rejects zero, negative, and out-of-range durations', () {
    expect(() => cubit.selectDuration(Duration.zero), throwsArgumentError);
    expect(
      () => cubit.selectDuration(const Duration(minutes: -1)),
      throwsArgumentError,
    );
    expect(
      () => cubit.selectDuration(const Duration(hours: 9)),
      throwsArgumentError,
    );
  });

  test('audio failures are exposed to the UI state', () async {
    audioService.failNextPlay = true;

    await cubit.play();

    expect(cubit.state.hasError, isTrue);
  });

  test('selecting category updates category and available soundscapes', () async {
    await cubit.selectCategory(SoundscapeCategory.activity);
    expect(cubit.state.selectedCategory, SoundscapeCategory.activity);
    expect(cubit.state.selectedSoundscape.category, SoundscapeCategory.activity);
    expect(cubit.state.availableSoundscapes.every((s) => s.category == SoundscapeCategory.activity), isTrue);

    await cubit.selectCategory(SoundscapeCategory.adhd);
    expect(cubit.state.selectedCategory, SoundscapeCategory.adhd);
    expect(cubit.state.selectedSoundscape.category, SoundscapeCategory.adhd);
  });

  test('manual visual selection overrides track theme and reverts to auto cleanly', () {
    expect(cubit.state.isAutoVisual, isTrue);
    expect(cubit.state.activeWaveStyle, cubit.state.selectedSoundscape.themeConfig.waveStyle);

    cubit.setManualWaveStyle(WaveStyle.constellation);
    expect(cubit.state.isAutoVisual, isFalse);
    expect(cubit.state.manualWaveStyle, WaveStyle.constellation);
    expect(cubit.state.activeWaveStyle, WaveStyle.constellation);

    cubit.setManualWaveStyle(null);
    expect(cubit.state.isAutoVisual, isTrue);
    expect(cubit.state.manualWaveStyle, isNull);
    expect(cubit.state.activeWaveStyle, cubit.state.selectedSoundscape.themeConfig.waveStyle);
  });
}

Future<void> _flushStatusEvents() async {
  await Future<void>.delayed(Duration.zero);
}

class _FakeAudioPlayerService implements AudioPlayerService {
  final StreamController<AudioEngineStatus> _statusController =
      StreamController<AudioEngineStatus>.broadcast();
  final List<SoundscapeItem> playedSoundscapes = [];
  AudioEngineStatus _currentStatus = AudioEngineStatus.idle;
  Completer<void>? playGate;
  bool failNextPlay = false;
  int resumeCalls = 0;
  int stopCalls = 0;

  @override
  AudioEngineStatus get currentStatus => _currentStatus;

  @override
  Stream<Duration> get positionStream => const Stream<Duration>.empty();

  @override
  Stream<double> get volumeStream => const Stream<double>.empty();

  @override
  Stream<AudioEngineStatus> get statusStream => _statusController.stream;

  void _setStatus(AudioEngineStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  @override
  Future<void> playSoundscape(
    SoundscapeItem soundscape, {
    Duration fadeInDuration = const Duration(milliseconds: 1500),
  }) async {
    playedSoundscapes.add(soundscape);
    _setStatus(AudioEngineStatus.loading);
    if (failNextPlay) {
      failNextPlay = false;
      throw StateError('Audio asset could not be loaded.');
    }
    await playGate?.future;
    _setStatus(AudioEngineStatus.playing);
  }

  @override
  Future<void> pause() async {
    _setStatus(AudioEngineStatus.paused);
  }

  @override
  Future<void> resume() async {
    resumeCalls++;
    _setStatus(AudioEngineStatus.playing);
  }

  @override
  Future<void> fadeOut({required Duration duration}) async {}

  @override
  Future<void> stop({
    Duration fadeOutDuration = const Duration(milliseconds: 1000),
  }) async {
    stopCalls++;
    _setStatus(AudioEngineStatus.idle);
  }

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> dispose() async {
    await _statusController.close();
  }
}
