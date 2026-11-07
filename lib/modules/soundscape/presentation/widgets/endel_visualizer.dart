import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../domain/entities/visual_theme_config.dart';
import '../../domain/enums/wave_style.dart';
import '../painters/visual_painter_factory.dart';
import '../painters/visual_painter_strategy.dart';

/// Bộ máy vẽ hoạt ảnh hình học & sóng âm biến dạng chuẩn phong cách Endel (60/120 FPS).
/// Thiết kế Clean Architecture: Sử dụng Strategy Pattern qua [VisualPainterFactory],
/// tách rời hoàn toàn thuật toán vẽ khỏi widget vòng đời UI.
///
/// Các cải tiến đồ họa Endel:
/// - Chuyển động tích lũy vi sai liên tục (Continuous Differential Time Accumulation)
/// - Nội suy mượt mà giữa trạng thái Chơi (Playing 1.0) và Tạm dừng (Idle Breathing 0.25)
/// - Không bao giờ đóng băng đột ngột khi dừng nhạc (Không bị Abrupt Freezing)
/// - Phản hồi âm thanh thực tế (Audio Reactivity): đồng bộ với vị trí phát nhạc, BPM và âm lượng
/// - Tự động dừng ticker khi vào nền để tiết kiệm pin tối đa.
class EndelVisualizer extends StatefulWidget {
  const EndelVisualizer({
    super.key,
    required this.isPlaying,
    required this.themeConfig,
    required this.activeWaveStyle,
    this.audioPositionStream,
    this.audioVolumeStream,
    this.bpm = 60,
  });

  final bool isPlaying;
  final VisualThemeConfig themeConfig;
  final WaveStyle activeWaveStyle;

  /// Luồng thời gian phát của bài nhạc (phục vụ đồng bộ pha nhịp âm)
  final Stream<Duration>? audioPositionStream;

  /// Luồng âm lượng thực tế (phục vụ phản hồi fade-in / fade-out)
  final Stream<double>? audioVolumeStream;

  /// Tần số BPM của soundscape
  final int bpm;

  @override
  State<EndelVisualizer> createState() => _EndelVisualizerState();
}

class _EndelVisualizerState extends State<EndelVisualizer>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final Ticker _ticker;
  late final AnimationController _activityController;
  final ValueNotifier<double> _timeNotifier = ValueNotifier<double>(0.0);

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<double>? _volumeSubscription;
  Duration? _latestAudioPosition;
  DateTime? _audioSyncInstant;
  double _currentVolume = 1.0;
  double _audioReactiveFactor = 1.0;

  double _continuousTime = 0.0;
  Duration? _lastElapsed;

  bool _tickerModeEnabled = true;
  bool _animationsDisabled = false;
  bool _appIsResumed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _activityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      value: widget.isPlaying ? 1.0 : 0.25,
    );

    _initAudioSubscriptions();
    _ticker = createTicker(_onTick);
  }

  void _initAudioSubscriptions() {
    _positionSubscription?.cancel();
    _volumeSubscription?.cancel();

    _positionSubscription = widget.audioPositionStream?.listen((pos) {
      _latestAudioPosition = pos;
      _audioSyncInstant = DateTime.now();
    });

    _volumeSubscription = widget.audioVolumeStream?.listen((vol) {
      _currentVolume = vol.clamp(0.0, 1.0);
    });
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed != null) {
      final dt = (elapsed - _lastElapsed!).inMicroseconds / 1000000.0;
      // Giới hạn dt tối đa 50ms để ngăn nhảy vọt khung hình khi thiết bị lag
      final clampedDt = dt.clamp(0.0, 0.05);

      final speed = widget.themeConfig.waveSpeed > 0
          ? widget.themeConfig.waveSpeed
          : 1.0;
      final currentActivity = _activityController.value;

      // Khi chơi nhạc: tốc độ 100%. Khi tạm dừng: tốc độ giảm mượt về ~25% duy trì nhịp thở êm
      final speedFactor = 0.25 + 0.75 * currentActivity;
      _continuousTime += clampedDt * speed * speedFactor;

      // 4. AUDIO REACTIVITY: Đồng bộ pha nhịp đập thực tế từ âm thanh
      if (widget.isPlaying &&
          _latestAudioPosition != null &&
          _audioSyncInstant != null) {
        final elapsedSinceSync =
            DateTime.now().difference(_audioSyncInstant!).inMicroseconds /
            1000000.0;
        final currentAudioSeconds =
            (_latestAudioPosition!.inMicroseconds / 1000000.0) +
            elapsedSinceSync;
        final beatProgress = (currentAudioSeconds * (widget.bpm / 60.0)) % 1.0;
        // Đường cong xung nhịp âm học: đập mạnh tại đầu nhịp và tan nhanh
        final beatPulse = math.exp(-3.5 * beatProgress);
        final targetReactive = 1.0 + (0.22 * beatPulse * _currentVolume);
        // Bộ lọc thông thấp làm mịn xung (Spring Damper Filter)
        _audioReactiveFactor += (targetReactive - _audioReactiveFactor) * 0.35;
      } else {
        _audioReactiveFactor += (1.0 - _audioReactiveFactor) * 0.1;
      }

      _timeNotifier.value = _continuousTime;
    }
    _lastElapsed = elapsed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tickerModeEnabled = TickerMode.of(context);
    _animationsDisabled = MediaQuery.of(context).disableAnimations;
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant EndelVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _activityController.animateTo(
          1.0,
          duration: const Duration(milliseconds: 1400),
          curve: Curves.easeInOutCubic,
        );
      } else {
        _activityController.animateTo(
          0.25,
          duration: const Duration(milliseconds: 1800),
          curve: Curves.easeOutCubic,
        );
      }
    }

    if (widget.audioPositionStream != oldWidget.audioPositionStream ||
        widget.audioVolumeStream != oldWidget.audioVolumeStream) {
      _initAudioSubscriptions();
    }

    _syncTicker();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appIsResumed = state == AppLifecycleState.resumed;
    _syncTicker();
  }

  void _syncTicker() {
    if (!mounted) return;
    final shouldRun =
        _tickerModeEnabled && !_animationsDisabled && _appIsResumed;

    if (shouldRun && !_ticker.isActive) {
      _lastElapsed = null;
      _ticker.start();
    } else if (!shouldRun && _ticker.isActive) {
      _ticker.stop();
      _lastElapsed = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionSubscription?.cancel();
    _volumeSubscription?.cancel();
    _ticker.dispose();
    _activityController.dispose();
    _timeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final painterStrategy = VisualPainterFactory.getPainter(
      widget.activeWaveStyle,
    );

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_timeNotifier, _activityController]),
        builder: (context, child) {
          return CustomPaint(
            painter: _EndelMasterPainter(
              time: _timeNotifier.value,
              isPlaying: widget.isPlaying,
              activityFactor: _activityController.value,
              audioReactiveFactor: _audioReactiveFactor,
              config: widget.themeConfig,
              strategy: painterStrategy,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _EndelMasterPainter extends CustomPainter {
  const _EndelMasterPainter({
    required this.time,
    required this.isPlaying,
    required this.activityFactor,
    required this.audioReactiveFactor,
    required this.config,
    required this.strategy,
  });

  final double time;
  final bool isPlaying;
  final double activityFactor;
  final double audioReactiveFactor;
  final VisualThemeConfig config;
  final VisualPainterStrategy strategy;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius =
        math.min(size.width, size.height) * config.baseRadiusFactor;

    strategy.paint(
      canvas: canvas,
      size: size,
      center: center,
      baseRadius: baseRadius,
      time: time,
      isPlaying: isPlaying,
      config: config,
      activityFactor: activityFactor,
      audioReactiveFactor: audioReactiveFactor,
    );
  }

  @override
  bool shouldRepaint(covariant _EndelMasterPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.activityFactor != activityFactor ||
        oldDelegate.audioReactiveFactor != audioReactiveFactor ||
        oldDelegate.strategy != strategy ||
        oldDelegate.config != config;
  }
}
