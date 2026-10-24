import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';

/// 2. FOCUS: Khối đa giác góc cạnh, xoay đảo chiều kỹ thuật sắc sảo
class GeometricVisualPainter extends VisualPainterStrategy {
  const GeometricVisualPainter();

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
    final maxRadiusFactor = 0.44;
    final radiusStep = layers > 1 ? 0.16 / (layers - 1) : 0.0;

    for (int layer = 0; layer < layers; layer++) {
      final isEven = layer % 2 == 0;
      final rotSpeed = isEven ? 1.0 : -1.0;
      final rotAngle = time * rotSpeed + (layer * 0.4);
      final sides = 6 + (layer * 2); // Lục giác, bát giác lồng nhau
      final radiusFactor = maxRadiusFactor - (layers - 1 - layer) * radiusStep;
      final radiusX = size.width * radiusFactor;
      final radiusY = size.height * radiusFactor;

      final paint = Paint()
        ..color = config.primaryColor.withValues(alpha: 0.25 + (layer * 0.2))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..isAntiAlias = true;

      final path = Path();
      for (int i = 0; i <= sides; i++) {
        final theta = (i / sides) * 2 * math.pi + rotAngle;
        final pulse = isPlaying ? math.sin(time * 2 + i) * 6 : 0.0;
        final pulseFactor = pulse / math.min(size.width, size.height);
        final x =
            center.dx +
            (radiusFactor + pulseFactor) * size.width * math.cos(theta);
        final y =
            center.dy +
            (radiusFactor + pulseFactor) * size.height * math.sin(theta);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);

      // Điểm mút kỹ thuật tại các đỉnh
      if (layer == layers - 1) {
        final dotPaint = Paint()
          ..color = config.primaryColor.withValues(alpha: 0.8)
          ..style = PaintingStyle.fill;
        for (int i = 0; i < sides; i++) {
          final theta = (i / sides) * 2 * math.pi + rotAngle;
          final x = center.dx + radiusX * math.cos(theta);
          final y = center.dy + radiusY * math.sin(theta);
          canvas.drawCircle(Offset(x, y), 2.0, dotPaint);
        }
      }
    }
  }
}
