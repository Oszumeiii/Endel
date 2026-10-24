import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';

/// 1. RELAX: Các dải sóng dọc hữu cơ chuyển động mềm mại
class OrganicVisualPainter extends VisualPainterStrategy {
  const OrganicVisualPainter();

  @override
  void paint({
    required Canvas canvas,
    required Size size,
    required Offset center,
    required double baseRadius,
    required double time,
    required bool isPlaying,
    required VisualThemeConfig config,
  }) {
    final layers = config.layerCount;
    final intensity = config.deformationIntensity * (isPlaying ? 1.0 : 0.4);
    final halfHeight = size.height * 0.47;
    final spacing = layers > 1 ? size.width * 0.88 / (layers - 1) : 0.0;

    for (int layer = 0; layer < layers; layer++) {
      final phaseOffset = layer * (math.pi / 2.5);
      final horizontalOffset = (layer - (layers - 1) / 2) * spacing;
      final alpha = (0.2 + (layer / layers) * 0.6) * (isPlaying ? 1.0 : 0.6);

      final paint = Paint()
        ..color = config.primaryColor.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 + (layer * 0.3)
        ..isAntiAlias = true;

      final path = Path();
      const points = 180;

      for (int i = 0; i <= points; i++) {
        final progress = i / points;
        final wave1 =
            math.sin(progress * 2 * math.pi * 2 + time + phaseOffset) *
            14 *
            intensity;
        final wave2 =
            math.cos(progress * 2 * math.pi * 3 - time * 2 + phaseOffset) *
            9 *
            intensity;
        final wave3 =
            math.sin(progress * 2 * math.pi * 5 + time * 3) * 4 * intensity;
        final wave4 =
            math.cos(progress * 2 * math.pi * 7 - time * 2 + phaseOffset) *
            3 *
            intensity;
        final wave5 =
            math.sin(progress * 2 * math.pi * 9 + time * 2) * 2 * intensity;

        final x =
            center.dx +
            horizontalOffset +
            wave1 +
            wave2 +
            wave3 +
            wave4 +
            wave5;
        final y = center.dy - halfHeight + progress * halfHeight * 2;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }
}
