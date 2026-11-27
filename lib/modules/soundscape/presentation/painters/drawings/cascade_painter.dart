import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';
import 'visual_effects_helper.dart';

/// 6. CASCADE: Các sợi mảnh chạy dọc suốt chiều cao khung hình như rèm ánh sáng xoắn mềm.
class CascadeVisualPainter extends VisualPainterStrategy {
  const CascadeVisualPainter();

  // Hằng số chất lượng và tốc độ (chậm hơn Silk)
  static const double _kQuality = 1.0;
  static const double _kSpeedScale = 0.35;

  static final Paint _threadPaint = Paint()
    ..style = PaintingStyle.stroke
    ..blendMode = BlendMode.plus
    ..isAntiAlias = true;

  static final Paint _flowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4
    ..blendMode = BlendMode.plus
    ..isAntiAlias = true;

  static final Paint _glowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.6
    ..blendMode = BlendMode.plus
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.5)
    ..isAntiAlias = true;

  static final Path _threadPath = Path();
  static final Path _flowPath = Path();
  static final Path _glowPath = Path();

  static double _hash(int i, int salt) {
    final x = math.sin(i * 12.9898 + salt * 78.233) * 43758.5453;
    return x - x.floorToDouble();
  }

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

    final minDim = math.min(size.width, size.height);
    if (minDim <= 0) return;

    // 1. Nền và khí quyển
    VisualEffectsHelper.drawBackdrop(
      canvas,
      size,
      config.primaryColor,
      config.accentColor,
      intensity: activityFactor,
    );

    VisualEffectsHelper.drawAtmosphere(
      canvas,
      size,
      center,
      config.primaryColor,
      config.accentColor,
      intensity: activityFactor * 0.9,
      audioReactiveFactor: audioReactiveFactor,
    );

    final t = time * _kSpeedScale;
    final playScale = isPlaying ? 1.0 : 0.4;
    final audioScale = 0.97 + 0.03 * audioReactiveFactor.clamp(0.0, 2.0);
    final activityMod = 0.68 + 0.32 * activityFactor.clamp(0.0, 1.5);
    final deform = config.deformationIntensity.clamp(0.4, 1.8);

    final bandCount = config.layerCount.clamp(2, 3);
    final threadCount = (48 * _kQuality).round().clamp(24, 48);
    final segments = (80 * _kQuality).round().clamp(45, 90);

    final yStart = -0.05 * size.height;
    final yEnd = 1.05 * size.height;
    final ySpan = yEnd - yStart;
    final swayAmp = minDim * 0.065 * deform * playScale * audioScale;

    _glowPath.reset();

    // 2. Vẽ 2-3 dải rèm sợi dọc
    for (int b = 0; b < bandCount; b++) {
      final bRatio = bandCount > 1 ? b / (bandCount - 1) : 0.5;
      final driftX =
          math.sin(t * 0.25 + _hash(b, 1) * math.pi * 2.0) *
          minDim *
          0.03 *
          playScale;
      final baseX = size.width * (0.24 + 0.52 * bRatio) + driftX;

      final f1 = (0.0045 + b * 0.0008);
      final f2 = (0.0072 + b * 0.0011);
      final twist = 2.6 + b * 0.5;
      final twist2 = -1.9 + b * 0.4;
      final bandPhase = b * 1.75;

      // Dải chẵn chảy xuống, dải lẻ chảy lên chậm hơn
      final flowDir = b.isEven ? 1.0 : -0.65;
      final flowPhase = ((t * 0.28 * flowDir + b * 0.35) % 1.0 + 1.0) % 1.0;

      // Tạo shader ánh sáng chảy dọc 1 lần cho cả dải
      final bandColor =
          Color.lerp(config.primaryColor, config.accentColor, bRatio * 0.5) ??
          config.primaryColor;
      final flowAlpha = (0.20 * activityMod).clamp(0.0, 0.26);
      final bandRect = Rect.fromLTWH(0, yStart, size.width, ySpan);
      _flowPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          bandColor.withValues(alpha: flowAlpha * 0.4),
          bandColor.withValues(alpha: flowAlpha),
          bandColor.withValues(alpha: flowAlpha * 0.4),
          Colors.transparent,
        ],
        stops: [
          0.0,
          (flowPhase - 0.25).clamp(0.02, 0.96),
          flowPhase.clamp(0.04, 0.97),
          (flowPhase + 0.25).clamp(0.05, 0.99),
          1.0,
        ],
      ).createShader(bandRect);

      _flowPath.reset();

      for (int k = 0; k < threadCount; k++) {
        final u = threadCount > 1 ? k / (threadCount - 1) : 0.5;
        _threadPath.reset();

        double prevX = 0.0;
        double prevY = 0.0;

        for (int s = 0; s <= segments; s++) {
          final ny = s / segments;
          final y = yStart + ny * ySpan;

          // Làm mượt biên độ ở hai đầu trên/dưới khung
          final clampedNy = (y / size.height).clamp(0.0, 1.0);
          final envelope = math.pow(math.sin(math.pi * clampedNy), 0.8);

          // Bề rộng dải phình - thắt dọc theo chiều đứng
          final widthY =
              (0.10 + 0.07 * math.sin(y * 0.004 + t * 0.4 + bandPhase)) *
              size.width;
          final x =
              baseX +
              widthY *
                  (u - 0.5) *
                  2.0 *
                  math.cos(y * f1 + t * 0.6 + u * twist + bandPhase) +
              swayAmp *
                  envelope *
                  math.sin(y * f2 + t + u * twist2 + bandPhase);

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
        final alpha = ((0.10 + 0.12 * edgeFade) * activityMod).clamp(0.0, 0.22);

        _threadPaint
          ..color = threadColor.withValues(alpha: alpha)
          ..strokeWidth = 0.8 + 0.2 * edgeFade;
        canvas.drawPath(_threadPath, _threadPaint);

        // Gom một số sợi chính vào dải ánh sáng chảy dọc
        if (k % 6 == 0) {
          _flowPath.addPath(_threadPath, Offset.zero);
        }

        // Gom 6-8 sợi biên của dải đầu tiên vào 1 glowPath (1 MaskFilter.blur/frame)
        if (b == 0 && (k <= 2 || k >= threadCount - 3)) {
          _glowPath.addPath(_threadPath, Offset.zero);
        }
      }

      canvas.drawPath(_flowPath, _flowPaint);
      _flowPaint.shader = null;
    }

    // 3. Lớp glow mềm cho các sợi biên
    final glowAlpha = (0.14 * activityMod).clamp(0.0, 0.20);
    _glowPaint.color = config.primaryColor.withValues(alpha: glowAlpha);
    canvas.drawPath(_glowPath, _glowPaint);
  }
}
