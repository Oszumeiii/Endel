import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/visual_theme_config.dart';
import '../../domain/enums/wave_style.dart';
import '../painters/visual_painter_factory.dart';
import '../painters/visual_painter_strategy.dart';

/// Bộ máy vẽ hoạt ảnh hình học & sóng âm biến dạng chuẩn phong cách Endel (60/120 FPS)
/// Thiết kế Clean Architecture: Sử dụng Strategy Pattern qua [VisualPainterFactory],
/// tách rời hoàn toàn thuật toán vẽ khỏi widget vòng đời UI.
class EndelVisualizer extends StatefulWidget {
  const EndelVisualizer({
    super.key,
    required this.isPlaying,
    required this.themeConfig,
    required this.activeWaveStyle,
  });

  final bool isPlaying;
  final VisualThemeConfig themeConfig;
  final WaveStyle activeWaveStyle;
  @override
  State<EndelVisualizer> createState() => _EndelVisualizerState();
}

class _EndelVisualizerState extends State<EndelVisualizer>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  bool _tickerModeEnabled = true;
  bool _animationsDisabled = false;
  bool _appIsResumed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..addStatusListener(_handleAnimationStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tickerModeEnabled = TickerMode.of(context);
    _animationsDisabled = MediaQuery.of(context).disableAnimations;
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant EndelVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final speed = widget.themeConfig.waveSpeed;
    final targetSeconds = (12 / (speed > 0 ? speed : 1.0)).clamp(3.0, 24.0);
    if (_controller.duration?.inMilliseconds !=
        (targetSeconds * 1000).round()) {
      _controller.duration = Duration(
        milliseconds: (targetSeconds * 1000).round(),
      );
    }
    _syncAnimation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appIsResumed = state == AppLifecycleState.resumed;
    _syncAnimation();
  }

  void _syncAnimation() {
    if (!mounted) return;
    final shouldAnimate =
        widget.isPlaying &&
        _tickerModeEnabled &&
        !_animationsDisabled &&
        _appIsResumed;
    if (shouldAnimate && !_controller.isAnimating) {
      if (_controller.value >= 1.0) {
        _controller.repeat();
      } else {
        _controller.forward();
      }
    } else if (!shouldAnimate && _controller.isAnimating) {
      _controller.stop(canceled: false);
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        widget.isPlaying &&
        _tickerModeEnabled &&
        !_animationsDisabled &&
        _appIsResumed) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final painterStrategy = VisualPainterFactory.getPainter(
      widget.activeWaveStyle,
    );

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final time = _controller.value * 2 * math.pi;
          return CustomPaint(
            painter: _EndelMasterPainter(
              time: time,
              isPlaying: widget.isPlaying,
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
    required this.config,
    required this.strategy,
  });

  final double time;
  final bool isPlaying;
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
    );
  }

  @override
  bool shouldRepaint(covariant _EndelMasterPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.strategy != strategy ||
        oldDelegate.config != config;
  }
}
