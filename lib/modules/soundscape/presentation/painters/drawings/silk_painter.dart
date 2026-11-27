import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';
import 'visual_effects_helper.dart';

/// 3. SILK: Nhiều sợi mảnh song song lệch pha dần tạo dải lụa xoắn 3D mềm mại.
class SilkVisualPainter extends VisualPainterStrategy {
  const SilkVisualPainter();

  static final Paint _threadPaint = Paint()
    ..style = PaintingStyle.stroke
    ..blendMode = BlendMode.plus
    ..isAntiAlias = true;

  static final Paint _glowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.4
    ..blendMode = BlendMode.plus
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0)
    ..isAntiAlias = true;

  static final Path _threadPath = Path();
  static final Path _glowPath = Path();

  @override
  void paint({
    required Canvas canvas,
    required Size size,
    required Offset center,
    required double baseRadius,
    required double time,
    required bool isPlaying,
    required VisualThemeConfig config,
    double activityFactor = 1.0,
    double audioReactiveFactor = 1.0,
  }) {
    if (size.isEmpty) return;

    // 1. Nền gradient sâu thẳm
    VisualEffectsHelper.drawBackdrop(
      canvas,
      size,
      config.primaryColor,
      config.accentColor,
      intensity: activityFactor,
    );

    // 2. Ánh sáng khí quyển
    VisualEffectsHelper.drawAtmosphere(
      canvas,
      size,
      center,
      config.primaryColor,
      config.accentColor,
      intensity: activityFactor,
      audioReactiveFactor: audioReactiveFactor,
    );

    final t = time * 0.4;
    final playScale = isPlaying ? 1.0 : 0.4;
    final audioScale = 0.97 + 0.03 * audioReactiveFactor.clamp(0.0, 2.0);
    final minDim = math.min(size.width, size.height);

    final ribbonCount = config.layerCount.clamp(2, 3);
    const threadCount = 48;
    const segments = 76;

    _glowPath.reset();

    // 3. Vẽ 2-3 dải lụa xoắn 3D
    for (int r = 0; r < ribbonCount; r++) {
      final rRatio = ribbonCount > 1 ? r / (ribbonCount - 1) : 0.5;
      final baseCenterY = size.height * (0.32 + 0.36 * rRatio);
      final tilt = (r.isEven ? -1.0 : 1.0) * size.height * 0.08;
      final twist = 2.4 + r * 0.45;
      final twist2 = -1.8 + r * 0.35;
      final freq1 = 4.6 + r * 0.7;
      final freq2 = 7.8 + r * 0.9;

      final ampA =
          minDim *
          0.11 *
          config.deformationIntensity.clamp(0.4, 1.8) *
          (0.65 + 0.35 * activityFactor) *
          playScale *
          audioScale;
      final ampB = ampA * 0.42;
      final spread = minDim * 0.08 * playScale;
      final ribbonPhase = r * 1.85;

      for (int k = 0; k < threadCount; k++) {
        final u = k / (threadCount - 1);
        _threadPath.reset();

        double prevX = 0.0;
        double prevY = 0.0;

        for (int s = 0; s <= segments; s++) {
          final nx = s / segments;
          final x = nx * size.width;
          final envelope = 0.25 + 0.75 * math.sin(nx * math.pi);

          // Phình - thắt dọc theo dải như lụa bị xoắn trong không gian
          final widthMod =
              0.55 + 0.45 * math.cos(nx * math.pi * 2.5 + t * 0.5 + r * 1.1);
          final y =
              baseCenterY +
              (nx - 0.5) * tilt +
              (u - 0.5) * spread * widthMod +
              ampA *
                  envelope *
                  math.sin(nx * freq1 + t + ribbonPhase + u * twist) +
              ampB *
                  envelope *
                  math.sin(nx * freq2 - t * 0.7 + ribbonPhase + u * twist2);

          if (s == 0) {
            _threadPath.moveTo(x, y);
          } else if (s == segments) {
            _threadPath.quadraticBezierTo(prevX, prevY, x, y);
          } else {
            final midX = (prevX + x) * 0.5;
            final midY = (prevY + y) * 0.5;
            _threadPath.quadraticBezierTo(prevX, prevY, midX, midY);
          }
          prevX = x;
          prevY = y;
        }

        final threadColor =
            Color.lerp(config.primaryColor, config.accentColor, u) ??
            config.primaryColor;
        final edgeFade = 1.0 - (u - 0.5).abs() * 0.45;
        final alpha =
            ((0.10 + 0.12 * edgeFade) * (0.5 + 0.5 * activityFactor)).clamp(
              0.0,
              0.22,
            );

        _threadPaint
          ..color = threadColor.withValues(alpha: alpha)
          ..strokeWidth = 0.8 + 0.2 * edgeFade;
        canvas.drawPath(_threadPath, _threadPaint);

        // Gom các sợi biên của dải đầu tiên vào 1 glowPath (chỉ 1 blur cho cả frame)
        if (r == 0 && (k <= 2 || k >= threadCount - 3)) {
          _glowPath.addPath(_threadPath, Offset.zero);
        }
      }
    }

    // 4. Lớp glow nhẹ cho 6 sợi biên (tối đa 1 MaskFilter.blur mỗi frame)
    final glowAlpha = (0.14 * (0.5 + 0.5 * activityFactor)).clamp(0.0, 0.20);
    _glowPaint.color = config.primaryColor.withValues(alpha: glowAlpha);
    canvas.drawPath(_glowPath, _glowPaint);
  }
}
