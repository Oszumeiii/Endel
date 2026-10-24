import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';

/// 7. RIPPLES: Các dải sóng mặt nước uốn lượn và giao thoa
class RipplesVisualPainter extends VisualPainterStrategy {
  const RipplesVisualPainter();

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
    const lineCount = 9;
    final halfWidth = size.width * 0.48;
    final spacing = size.height * 0.9 / (lineCount - 1);
    final intensity = config.deformationIntensity * (isPlaying ? 1.0 : 0.35);

    for (int i = 0; i < lineCount; i++) {
      final offset = (i - (lineCount - 1) / 2) * spacing;
      final verticalFade = math.exp(
        -math.pow(offset / (size.height * 0.34), 2),
      );
      final alpha = (0.2 + verticalFade * 0.45) * (isPlaying ? 1.0 : 0.45);

      final paint = Paint()
        ..color = config.primaryColor.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 + verticalFade * 0.8
        ..isAntiAlias = true;

      final path = Path();
      const points = 120;
      for (int p = 0; p <= points; p++) {
        final progress = p / points;
        final x = center.dx - halfWidth + progress * halfWidth * 2;
        final waveA =
            math.sin(progress * 2 * math.pi * 2 + time + i * 0.35) *
            9 *
            intensity;
        final waveB =
            math.sin(progress * 2 * math.pi * 4 - time * 2 + i * 0.2) *
            3.5 *
            intensity;
        final y = center.dy + offset + waveA + waveB;
        if (p == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }

    final centerAlpha = isPlaying ? (math.sin(time * 2) * 0.2 + 0.55) : 0.3;
    final centerPaint = Paint()
      ..color = config.primaryColor.withValues(alpha: centerAlpha)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.0, centerPaint);
  }
}
