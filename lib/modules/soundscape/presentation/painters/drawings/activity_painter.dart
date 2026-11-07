import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';
import 'visual_effects_helper.dart';

/// 4. ACTIVITY: Dải sóng động học và luồng quỹ đạo năng lượng (Kinetic Flux)
/// Tái hiện chuẩn xác phong cách Endel Activity:
/// - Cặp dải sóng xoắn bện kép (Double-helix Braided Ribbons)
/// - Hạt photon năng lượng di chuyển tốc độ cao để lại vệt sáng (Phosphorescent Light Trails)
/// - Trục xoáy động lực trung tâm tỏa xung nhịp đều đặn theo nhịp vận động
/// - Đồng bộ nhịp bước/nhịp âm thực tế (Audio Cadence Reactivity)
class ActivityVisualPainter extends VisualPainterStrategy {
  const ActivityVisualPainter();

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
    // 1. Ánh sáng khí quyển
    VisualEffectsHelper.drawAtmosphere(
      canvas,
      size,
      center,
      config.primaryColor,
      config.accentColor,
      intensity: activityFactor * 1.1,
      audioReactiveFactor: audioReactiveFactor,
    );

    // 2. Hạt bụi không gian năng động
    VisualEffectsHelper.drawAmbientParticles(
      canvas,
      size,
      time * 1.4,
      config.primaryColor,
      intensity: activityFactor,
      audioReactiveFactor: audioReactiveFactor,
      count: 28,
    );

    final intensity =
        config.deformationIntensity *
        (0.4 + 0.6 * activityFactor) *
        audioReactiveFactor;
    final layers = config.layerCount.clamp(3, 6);
    final halfHeight = size.height * 0.48;
    final spacing = size.width * 0.78 / (layers - 1);
    const points = 150;

    for (int layer = 0; layer < layers; layer++) {
      final dir = layer % 2 == 0 ? 1.0 : -1.0;
      final layerSpeed = 1.0 + (layer * 0.35);
      final layerTime = time * layerSpeed * dir;
      final horizontalOffset = (layer - (layers - 1) / 2.0) * spacing;
      final depthFactor = (layer + 1) / layers;

      final path = Path();
      final pointsList = <Offset>[];

      for (int i = 0; i <= points; i++) {
        final progress = i / points;
        final envelope = math.pow(math.sin(progress * math.pi), 1.1);

        final waveA =
            math.sin(progress * 2 * math.pi * 2.5 + layerTime) * 16 * intensity;
        final waveB =
            math.cos(progress * 2 * math.pi * 4.2 - layerTime * 1.5) *
            9 *
            intensity;
        final waveC =
            math.sin(progress * 2 * math.pi * 1.8 + layerTime * 2.0) *
            6 *
            intensity;

        final x =
            center.dx +
            horizontalOffset +
            (waveA + waveB + waveC) * envelope;
        final y = center.dy - halfHeight + (progress * halfHeight * 2.0);

        pointsList.add(Offset(x, y));

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      // Tô dải lụa sóng với hiệu ứng chuyển sắc
      final strokeAlpha =
          ((0.20 + depthFactor * 0.65) *
                  (0.35 + 0.65 * activityFactor) *
                  (0.92 + 0.08 * audioReactiveFactor))
              .clamp(0.0, 1.0);
      final strokeGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          config.primaryColor.withValues(alpha: strokeAlpha * 0.4),
          config.primaryColor.withValues(alpha: strokeAlpha),
          config.primaryColor.withValues(alpha: strokeAlpha * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.15, 0.5, 0.85, 1.0],
      );

      final shaderRect = Rect.fromLTWH(
        0,
        center.dy - halfHeight,
        size.width,
        halfHeight * 2,
      );

      // Phát quang hào quang dải sóng
      if (layer % 2 == 0) {
        final glowPaint = Paint()
          ..shader = strokeGradient.createShader(shaderRect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0)
          ..isAntiAlias = true;
        canvas.drawPath(path, glowPaint);
      }

      // Nét vẽ chính
      final corePaint = Paint()
        ..shader = strokeGradient.createShader(shaderRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3 + (depthFactor * 0.7)
        ..isAntiAlias = true;
      canvas.drawPath(path, corePaint);

      // 3. CÁC HẠT NĂNG LƯỢNG PHOTON DI CHUYỂN DỌC THEO SÓNG
      final beadCount = 2;
      for (int b = 0; b < beadCount; b++) {
        final beadCycle =
            (layerTime * 0.25 + (b * 0.5) + (layer * 0.2)) % 1.0;
        final beadIndex = (beadCycle * points).clamp(0, points - 1).toInt();
        final currentPoint = pointsList[beadIndex];

        final trailLength = 8;
        for (int t = 1; t <= trailLength; t++) {
          final trailIdx =
              (beadIndex - (dir > 0 ? t : -t)).clamp(0, points - 1);
          final trailPoint = pointsList[trailIdx];
          final trailAlpha =
              (1.0 - (t / trailLength)) * 0.35 * activityFactor;
          final trailPaint = Paint()
            ..color = config.primaryColor.withValues(
              alpha: trailAlpha.clamp(0.0, 1.0),
            )
            ..style = PaintingStyle.fill;
          canvas.drawCircle(trailPoint, 1.2, trailPaint);
        }

        // Hạt năng lượng chính phát sáng
        VisualEffectsHelper.drawGlowingPoint(
          canvas,
          currentPoint,
          2.6 + (layer * 0.4),
          color: config.primaryColor,
          glowSigma: 5.0,
          glowAlpha: (0.4 * activityFactor * audioReactiveFactor).clamp(0.0, 1.0),
          coreAlpha: (0.95 * activityFactor).clamp(0.0, 1.0),
          audioReactiveFactor: audioReactiveFactor,
        );
      }
    }

    // 4. VÒNG XOÁY ĐỘNG LỰC TRUNG TÂM (Kinetic Pulse Core)
    final corePulse = (math.sin(time * 3.5) + 1.0) / 2.0;
    final coreRadius =
        baseRadius *
        0.42 *
        (1.0 + corePulse * 0.15 * activityFactor) *
        (0.96 + 0.04 * audioReactiveFactor);

    final coreGlowPaint = Paint()
      ..color = config.primaryColor.withValues(
        alpha: ((0.05 + corePulse * 0.08) *
                activityFactor *
                audioReactiveFactor)
            .clamp(0.0, 1.0),
      )
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, coreRadius, coreGlowPaint);

    final ringPaint = Paint()
      ..color = config.primaryColor.withValues(
        alpha: ((0.15 + corePulse * 0.25) * activityFactor).clamp(0.0, 1.0),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, coreRadius, ringPaint);
  }
}
