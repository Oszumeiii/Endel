import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../domain/entities/soundscape_item.dart';
import '../domain/services/audio_player_service.dart';

/// JustAudio implementation with looping playback and cancellable fades.
class JustAudioPlayerService implements AudioPlayerService {
  JustAudioPlayerService({AudioPlayer? player})
    : _player = player ?? AudioPlayer() {
    _initStreams();
  }

  final AudioPlayer _player;
  final StreamController<AudioEngineStatus> _statusController =
      StreamController<AudioEngineStatus>.broadcast();

  AudioEngineStatus _currentStatus = AudioEngineStatus.idle;
  StreamSubscription? _playerStateSubscription;
  String? _loadedSoundscapeId;
  int _fadeGeneration = 0;
  bool _errorLatched = false;

  void _initStreams() {
    _playerStateSubscription = _player.playerStateStream.listen(
      (state) {
        if (_errorLatched) return;
        if (state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering) {
          _updateStatus(AudioEngineStatus.loading);
        } else if (state.playing) {
          _updateStatus(AudioEngineStatus.playing);
        } else if (state.processingState == ProcessingState.idle) {
          _updateStatus(AudioEngineStatus.idle);
        } else {
          _updateStatus(AudioEngineStatus.paused);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('[JustAudioPlayerService] Player stream failed: $error');
        _updateStatus(AudioEngineStatus.error);
      },
    );
  }

  void _updateStatus(AudioEngineStatus status) {
    if (status == AudioEngineStatus.error) {
      _errorLatched = true;
    } else if (_errorLatched && status != AudioEngineStatus.loading) {
      return;
    } else if (status == AudioEngineStatus.loading) {
      _errorLatched = false;
    }
    if (_currentStatus == status || _statusController.isClosed) return;
    _currentStatus = status;
    _statusController.add(status);
  }

  @override
  Stream<AudioEngineStatus> get statusStream => _statusController.stream;

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  AudioEngineStatus get currentStatus => _currentStatus;

  @override
  Future<void> playSoundscape(
    SoundscapeItem soundscape, {
    Duration fadeInDuration = const Duration(milliseconds: 1500),
  }) async {
    _cancelFade();
    _errorLatched = false;
    _updateStatus(AudioEngineStatus.loading);

    try {
      if (_player.playing) {
        await _fadeVolume(
          from: _player.volume,
          to: 0,
          duration: const Duration(milliseconds: 350),
        );
      }
      await _player.stop();
      if (soundscape.isRemote) {
        await _player.setUrl(soundscape.audioPath);
      } else {
        await _player.setAsset(soundscape.audioPath);
      }
      _loadedSoundscapeId = soundscape.id;
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(0);
      _startPlayer();
      _updateStatus(AudioEngineStatus.playing);
      _fadeVolumeInBackground(fadeInDuration);
    } catch (error, stackTrace) {
      debugPrint(
        '[JustAudioPlayerService] Failed to load or play soundscape: '
        '$error\n$stackTrace',
      );
      _loadedSoundscapeId = null;
      _updateStatus(AudioEngineStatus.error);
      rethrow;
    }
  }

  void _startPlayer() {
    unawaited(
      _player.play().catchError((Object error, StackTrace stackTrace) {
        if (error is PlayerInterruptedException) return;
        debugPrint('[JustAudioPlayerService] Playback failed: $error');
        _updateStatus(AudioEngineStatus.error);
      }),
    );
  }

  void _fadeVolumeInBackground(Duration duration) {
    unawaited(
      _fadeVolume(from: _player.volume, to: 1, duration: duration).catchError((
        Object error,
        StackTrace stackTrace,
      ) {
        debugPrint(
          '[JustAudioPlayerService] Fade-in failed: $error\n$stackTrace',
        );
        _updateStatus(AudioEngineStatus.error);
      }),
    );
  }

  @override
  Future<void> pause() async {
    _cancelFade();
    _errorLatched = false;
    try {
      if (_player.playing) {
        await _fadeVolume(
          from: _player.volume,
          to: 0,
          duration: const Duration(milliseconds: 400),
        );
      }
      await _player.pause();
      await _player.setVolume(1);
      _updateStatus(AudioEngineStatus.paused);
    } catch (error, stackTrace) {
      debugPrint('[JustAudioPlayerService] Pause failed: $error\n$stackTrace');
      _updateStatus(AudioEngineStatus.error);
      rethrow;
    }
  }

  @override
  Future<void> resume() async {
    if (_loadedSoundscapeId == null) {
      throw StateError('Cannot resume before a soundscape has been loaded.');
    }

    _cancelFade();
    _errorLatched = false;
    try {
      await _player.setVolume(0);
      _startPlayer();
      _updateStatus(AudioEngineStatus.playing);
      _fadeVolumeInBackground(const Duration(milliseconds: 600));
    } catch (error, stackTrace) {
      debugPrint('[JustAudioPlayerService] Resume failed: $error\n$stackTrace');
      _updateStatus(AudioEngineStatus.error);
      rethrow;
    }
  }

  @override
  Future<void> fadeOut({required Duration duration}) async {
    if (!_player.playing) return;
    await _fadeVolume(from: _player.volume, to: 0, duration: duration);
  }

  @override
  Future<void> stop({
    Duration fadeOutDuration = const Duration(milliseconds: 1000),
  }) async {
    _cancelFade();
    _errorLatched = false;
    try {
      if (_player.playing) {
        await _fadeVolume(
          from: _player.volume,
          to: 0,
          duration: fadeOutDuration,
        );
      }
      await _player.stop();
      await _player.seek(Duration.zero);
      _loadedSoundscapeId = null;
      _updateStatus(AudioEngineStatus.idle);
    } catch (error, stackTrace) {
      debugPrint('[JustAudioPlayerService] Stop failed: $error\n$stackTrace');
      _updateStatus(AudioEngineStatus.error);
      rethrow;
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    _cancelFade();
    await _player.setVolume(volume.clamp(0.0, 1.0).toDouble());
  }

  void _cancelFade() {
    _fadeGeneration++;
  }

  Future<void> _fadeVolume({
    required double from,
    required double to,
    required Duration duration,
  }) async {
    final generation = ++_fadeGeneration;
    if (duration <= Duration.zero) {
      await _player.setVolume(to.clamp(0.0, 1.0).toDouble());
      return;
    }

    const stepInterval = Duration(milliseconds: 50);
    final steps = (duration.inMilliseconds ~/ stepInterval.inMilliseconds)
        .clamp(1, 300);
    final delay = Duration(milliseconds: duration.inMilliseconds ~/ steps);

    for (var step = 1; step <= steps; step++) {
      await Future<void>.delayed(delay);
      if (generation != _fadeGeneration) return;
      final progress = step / steps;
      final volume = from + ((to - from) * progress);
      await _player.setVolume(volume.clamp(0.0, 1.0).toDouble());
    }
  }

  @override
  Future<void> dispose() async {
    _cancelFade();
    await _playerStateSubscription?.cancel();
    await _player.dispose();
    await _statusController.close();
  }
}
