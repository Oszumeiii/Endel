import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';
import 'visual_effects_helper.dart';

/// 3. SLEEP: Quầng sáng phập phồng nhịp thở sinh học (Organic Breathing Aura)
/// Tái hiện chuẩn xác phong cách Endel Sleep:
/// - Chu kỳ nhịp thở Delta/Theta êm dịu sâu lắng
/// - Đường bao màng hữu cơ uốn lượn đa hài (Perimeter Bio-harmonic Contours)
/// - Sóng thở lan truyền đa tầng có độ trễ pha (Peristaltic Phase Waves)
/// - Quầng hào quang khuếch tán đa cấp độ vào bóng đêm
/// - Nhịp tim/âm lượng phản hồi âm thanh thực tế (Audio-Reactive Pulsations)
class BreathingVisualPainter extends VisualPainterStrategy {
  const BreathingVisualPainter();

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
    // 1. Ánh sáng khí quyển nền
    VisualEffectsHelper.drawAtmosphere(
      canvas,
      size,
      center,
      config.primaryColor,
      config.accentColor,
      intensity: activityFactor * 0.9,
      audioReactiveFactor: audioReactiveFactor,
    );

    // 2. Các hạt bụi giấc mơ vi mô (Dream Stardust Particles)
    VisualEffectsHelper.drawAmbientParticles(
      canvas,
      size,
      time * 0.5,
      config.primaryColor,
      intensity: activityFactor * 0.8,
      audioReactiveFactor: audioReactiveFactor,
      count: 20,
    );

    // Chu kỳ thở sâu êm đềm kết hợp nhịp âm học
    final breathCycle = (math.sin(time * 0.75) + 1.0) / 2.0;
    final audioScale = 0.96 + 0.04 * audioReactiveFactor;
    final breathScale = (0.88 + breathCycle * 0.24 * activityFactor) * audioScale;

    final baseRadiusX = size.width * 0.38 * breathScale;
    final baseRadiusY = size.height * 0.38 * breathScale;

    // 3. VẦNG HÀO QUANG TRUNG TÂM PHÁT QUANG VÀO BÓNG TỐI
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.95,
      colors: [
        config.primaryColor.withValues(
          alpha: ((0.16 + breathCycle * 0.12) *
                  activityFactor *
                  audioReactiveFactor)
              .clamp(0.0, 1.0),
        ),
        config.accentColor.withValues(
          alpha: ((0.06 + breathCycle * 0.05) *
                  activityFactor *
                  audioReactiveFactor)
              .clamp(0.0, 1.0),
        ),
        Colors.transparent,
      ],
      stops: const [0.0, 0.55, 1.0],
    );

    final auraRadius = math.max(baseRadiusX, baseRadiusY) * 1.35;
    final auraPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: auraRadius),
      )
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, auraRadius, auraPaint);

    // 4. MÀNG SINH HỌC HỮU CƠ ĐA TẦNG (Multi-layer Bio-membranes)
    const layers = 4;
    const segments = 120;

    for (int layer = 0; layer < layers; layer++) {
      final layerPhase = layer * 0.55;
      final layerBreath = (math.sin(time * 0.75 - layerPhase) + 1.0) / 2.0;
      final layerScale = 1.0 + (layer * 0.18) + (layerBreath * 0.08);

      final rx = baseRadiusX * layerScale;
      final ry = baseRadiusY * layerScale;

      final path = Path();

      for (int i = 0; i <= segments; i++) {
        final theta = (i / segments) * 2 * math.pi;

        // Biến dạng chu vi hữu cơ mềm mại
        final d1 = math.sin(theta * 3.0 + time * 0.9 + layerPhase) * 7.0;
        final d2 = math.cos(theta * 5.0 - time * 0.6 + layerPhase) * 4.0;
        final d3 = math.sin(theta * 2.0 + time * 1.3) * 3.0;
        final distortion =
            (d1 + d2 + d3) *
            (0.4 + 0.6 * activityFactor) *
            (0.9 + 0.1 * audioReactiveFactor);

        final rXCurrent = rx + distortion;
        final rYCurrent = ry + distortion;

        final x = center.dx + rXCurrent * math.cos(theta);
        final y = center.dy + rYCurrent * math.sin(theta);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      final layerAlpha =
          ((0.24 - (layer * 0.05)) *
                  (0.45 + 0.55 * activityFactor) *
                  (0.92 + 0.08 * audioReactiveFactor))
              .clamp(0.0, 1.0);

      // Quầng sáng mờ bao quanh viền màng ngoài
      if (layer == 0 || layer == 1) {
        final glowPaint = Paint()
          ..color = config.primaryColor.withValues(
            alpha: (layerAlpha * 0.4).clamp(0.0, 1.0),
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0)
          ..isAntiAlias = true;
        canvas.drawPath(path, glowPaint);
      }

      // Viền nét chính
      final ringPaint = Paint()
        ..color = config.primaryColor.withValues(alpha: layerAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 + (layer == 0 ? 0.6 : 0.0)
        ..isAntiAlias = true;
      canvas.drawPath(path, ringPaint);
    }

    // 5. TRÁI TIM NĂNG LƯỢNG TRUNG TÂM (Luminous Heart Core)
    final coreBreath = (math.sin(time * 1.5) + 1.0) / 2.0;
    final coreRadius =
        (4.0 + coreBreath * 2.5 * activityFactor) *
        (0.95 + 0.05 * audioReactiveFactor);
    VisualEffectsHelper.drawGlowingPoint(
      canvas,
      center,
      coreRadius,
      color: config.primaryColor,
      glowSigma: 6.0,
      glowAlpha: (0.35 * activityFactor * audioReactiveFactor).clamp(0.0, 1.0),
      coreAlpha: (0.95 * activityFactor).clamp(0.0, 1.0),
      audioReactiveFactor: audioReactiveFactor,
    );
  }
}
