import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';
import 'visual_effects_helper.dart';

/// 5. ACTIVITY: Các dải xoắn bện double-helix chuyển động dọc năng động nhưng mềm mại.
class ActivityVisualPainter extends VisualPainterStrategy {
  const ActivityVisualPainter();

  static final Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..blendMode = BlendMode.plus
    ..isAntiAlias = true;

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
    // 1. Nền gradient sâu thẳm
    VisualEffectsHelper.drawBackdrop(
      canvas,
      size,
      config.primaryColor,
      config.accentColor,
      intensity: activityFactor,
    );

    // 2. Ánh sáng khí quyển năng động hơn nhẹ
    VisualEffectsHelper.drawAtmosphere(
      canvas,
      size,
      center,
      config.primaryColor,
      config.accentColor,
      intensity: activityFactor * 1.1,
      audioReactiveFactor: audioReactiveFactor,
    );

    // 3. Hạt vi mô trôi nhanh hơn Relax một chút
    VisualEffectsHelper.drawAmbientParticles(
      canvas,
      size,
      time * 0.8,
      config.primaryColor,
      intensity: activityFactor * 0.9,
      audioReactiveFactor: audioReactiveFactor,
      count: 9,
    );

    final layers = config.layerCount.clamp(3, 6);
    final playScale = isPlaying ? 1.0 : 0.4;
    final audioScale = 0.92 + 0.08 * audioReactiveFactor;
    final intensity =
        config.deformationIntensity *
        (0.4 + 0.6 * activityFactor) *
        playScale *
        audioReactiveFactor;

    final halfHeight = size.height * 0.48;
    final spacing = layers > 1 ? (size.width * 0.76) / (layers - 1) : 0.0;
    const points = 110;

    final bounds = Rect.fromLTWH(
      0,
      center.dy - halfHeight,
      size.width,
      halfHeight * 2,
    );

    for (int layer = 0; layer < layers; layer++) {
      final dir = layer % 2 == 0 ? 1.0 : -1.0;
      // Nhanh hơn Relax ~1.8 lần và chịu tác động của activityFactor
      final layerSpeed =
          (0.35 + layer * 0.1) * 1.8 * (0.75 + 0.25 * activityFactor);
      final layerTime = time * layerSpeed * dir;
      final baseX = center.dx + (layer - (layers - 1) / 2.0) * spacing;
      final depthFactor = (layer + 1) / layers;

      final strandA = <Offset>[];
      final strandB = <Offset>[];

      for (int i = 0; i <= points; i++) {
        final progress = i / points;
        final envelope = math.pow(math.sin(progress * math.pi), 1.1);

        final waveA =
            math.sin(progress * 2 * math.pi * 2.2 + layerTime) *
            18.0 *
            intensity;
        final waveB =
            math.cos(progress * 2 * math.pi * 3.8 - layerTime * 1.4 + 0.8) *
            10.0 *
            intensity;
        final waveC =
            math.sin(progress * 2 * math.pi * 1.5 + layerTime * 1.7 + 1.6) *
            6.0 *
            intensity;

        // Hệ số phình-thắt tạo nhịp bện double-helix dọc theo thân dải
        final thickness =
            0.5 +
            0.5 * math.sin(progress * 2 * math.pi * 2.0 + layerTime * 0.8);
        final offset = (waveA + waveB + waveC) * thickness * envelope;
        final y = center.dy - halfHeight + (progress * halfHeight * 2.0);

        strandA.add(Offset(baseX + offset, y));
        strandB.add(Offset(baseX - offset, y));
      }

      // 4. Dải lụa mềm giữa hai sợi xoắn bện (tối đa 6 blur/frame vì layers <= 6)
      final ribbon = VisualEffectsHelper.ribbonPath(strandA, strandB);
      final fillAlpha =
          ((0.14 + depthFactor * 0.06) * activityFactor * audioScale).clamp(
            0.0,
            0.20,
          );
      final blurSigma = 10.0 + depthFactor * 4.0;

      VisualEffectsHelper.drawSoftFill(
        canvas,
        ribbon,
        bounds,
        config.primaryColor,
        config.accentColor,
        alpha: fillAlpha,
        blur: blurSigma,
      );

      // 5. Hai sợi viền mảnh mượt bằng smoothPath
      final pathA = VisualEffectsHelper.smoothPath(strandA);
      final pathB = VisualEffectsHelper.smoothPath(strandB);

      final strokeAlpha =
          ((0.22 + depthFactor * 0.28) *
                  (0.35 + 0.65 * activityFactor) *
                  audioScale)
              .clamp(0.0, 0.50);

      _strokePaint
        ..strokeWidth = 1.0 + depthFactor * 0.5
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            config.primaryColor.withValues(alpha: strokeAlpha * 0.45),
            config.primaryColor.withValues(alpha: strokeAlpha),
            config.primaryColor.withValues(alpha: strokeAlpha * 0.45),
            Colors.transparent,
          ],
          stops: const [0.0, 0.14, 0.5, 0.86, 1.0],
        ).createShader(bounds);

      canvas.drawPath(pathA, _strokePaint);
      canvas.drawPath(pathB, _strokePaint);

      // 6. Một dải sáng ngắn trượt dọc sợi chính (không dùng chấm tròn)
      final rawSlide = (layerTime * 0.18 + layer * 0.23) % 1.0;
      final slidePos = rawSlide < 0 ? rawSlide + 1.0 : rawSlide;
      final s0 = (slidePos - 0.14).clamp(0.0, 1.0);
      final s1 = slidePos.clamp(0.0, 1.0);
      final s2 = (slidePos + 0.14).clamp(0.0, 1.0);
      final slideAlpha = (0.35 * activityFactor * audioScale).clamp(0.0, 0.35);

      _strokePaint
        ..strokeWidth = 1.6
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            config.primaryColor.withValues(alpha: slideAlpha),
            Colors.transparent,
          ],
          stops: [s0, s1, s2],
        ).createShader(bounds);

      canvas.drawPath(pathA, _strokePaint);
    }

    _strokePaint
      ..shader = null
      ..blendMode = BlendMode.srcOver;
  }
}
