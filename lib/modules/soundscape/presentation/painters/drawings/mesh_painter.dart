import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';
import 'visual_effects_helper.dart';

/// 6. ADHD / CENTERING: Mạng lưới nút cộng hưởng Constellation Mesh
/// Tái hiện chuẩn xác phong cách Endel ADHD:
/// - Các nút thiên thể chuyển động mượt mà trên quỹ đạo Lissajous đa tần số phi lặp lại
/// - Sợi liên kết xi-náp phát quang tự động theo khoảng cách lân cận (Proximity Synaptic Filaments)
/// - Quầng sáng tinh vân đa tầng giúp ổn định trường thị giác và điều hòa tâm trí
/// - Phản hồi năng lượng âm thanh thực tế (Audio Resonance)
class MeshVisualPainter extends VisualPainterStrategy {
  const MeshVisualPainter();

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
      intensity: activityFactor,
      audioReactiveFactor: audioReactiveFactor,
    );

    // 2. Hạt bụi sao
    VisualEffectsHelper.drawAmbientParticles(
      canvas,
      size,
      time * 0.6,
      config.primaryColor,
      intensity: activityFactor * 0.8,
      audioReactiveFactor: audioReactiveFactor,
      count: 22,
    );

    const nodeCount = 14;
    final nodes = <Offset>[];
    final nodeRadii = <double>[];

    final maxSpanX = size.width * 0.42;
    final maxSpanY = size.height * 0.42;

    for (int i = 0; i < nodeCount; i++) {
      final f1 = 0.45 + (i * 0.11);
      final f2 = 0.38 + (i * 0.09);
      final p1 = i * 1.6180339887;
      final p2 = i * 2.7182818284;

      final nx =
          math.sin(time * f1 + p1) * 0.85 + math.cos(time * 0.25 + p2) * 0.15;
      final ny =
          math.cos(time * f2 + p2) * 0.85 + math.sin(time * 0.28 + p1) * 0.15;

      final x = center.dx + nx * maxSpanX;
      final y = center.dy + ny * maxSpanY;

      nodes.add(Offset(x, y));
      nodeRadii.add(2.0 + (i % 3) * 0.8);
    }

    // 3. VẼ CÁC SỢI LIÊN KẾT XI-NÁP PHÁT QUANG (Proximity Synaptic Filaments)
    final maxConnectDist = math.min(size.width, size.height) * 0.40;

    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final dist = (nodes[i] - nodes[j]).distance;
        if (dist < maxConnectDist) {
          final proximity = 1.0 - (dist / maxConnectDist);
          final lineAlpha =
              ((proximity * proximity) *
                      0.38 *
                      (0.35 + 0.65 * activityFactor) *
                      audioReactiveFactor)
                  .clamp(0.0, 1.0);

          final linePaint = Paint()
            ..color = config.primaryColor.withValues(alpha: lineAlpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8 + proximity * 0.8
            ..isAntiAlias = true;

          canvas.drawLine(nodes[i], nodes[j], linePaint);
        }
      }
    }

    // 4. VẼ CÁC NÚT SAO PHÁT QUANG ĐA TẦNG (Celestial Luminous Nodes)
    for (int i = 0; i < nodes.length; i++) {
      final pulse = (math.sin(time * 2.0 + i * 1.2) + 1.0) / 2.0;
      final radius =
          (nodeRadii[i] + pulse * 1.0 * activityFactor) *
          (0.96 + 0.04 * audioReactiveFactor);

      VisualEffectsHelper.drawGlowingPoint(
        canvas,
        nodes[i],
        radius,
        color: config.primaryColor,
        glowSigma: 4.5,
        glowAlpha:
            ((0.25 + pulse * 0.25) * activityFactor * audioReactiveFactor)
                .clamp(0.0, 1.0),
        coreAlpha: (0.95 * activityFactor).clamp(0.0, 1.0),
        audioReactiveFactor: audioReactiveFactor,
      );
    }

    // Điểm tâm định vị
    VisualEffectsHelper.drawGlowingPoint(
      canvas,
      center,
      3.2,
      color: config.primaryColor,
      glowSigma: 5.0,
      glowAlpha: (0.35 * activityFactor * audioReactiveFactor).clamp(0.0, 1.0),
      coreAlpha: (0.9 * activityFactor).clamp(0.0, 1.0),
      audioReactiveFactor: audioReactiveFactor,
    );
  }
}
