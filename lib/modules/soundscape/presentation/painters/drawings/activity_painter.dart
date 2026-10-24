import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';

/// 4. ACTIVITY: Các dải sóng dọc động học với điểm năng lượng chuyển động
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
  }) {
    final intensity = config.deformationIntensity * (isPlaying ? 1.0 : 0.4);
    final layers = config.layerCount.clamp(3, 6);
    final halfHeight = size.height * 0.47;
    final spacing = size.width * 0.88 / (layers - 1);

    for (int layer = 0; layer < layers; layer++) {
      final dir = layer % 2 == 0 ? 1.0 : -1.0;
      final layerSpeed = layer + 1.0;
      final layerTime = time * layerSpeed * dir;
      final horizontalOffset = (layer - (layers - 1) / 2) * spacing;
      final alpha = (0.25 + (layer / layers) * 0.55) * (isPlaying ? 1.0 : 0.5);

      final paint = Paint()
        ..color = config.primaryColor.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4 + (layer * 0.2)
        ..isAntiAlias = true;

      final path = Path();
      const points = 140;

      for (int i = 0; i <= points; i++) {
        final progress = i / points;
        final waveA =
            math.sin(progress * 2 * math.pi * 3 + layerTime) * 12 * intensity;
        final waveB =
            math.cos(progress * 2 * math.pi * 5 - layerTime * 2) *
            8 *
            intensity;
        final waveC =
            math.sin(progress * 2 * math.pi * 2 + layerTime * 2) *
            6 *
            intensity;

        final x = center.dx + horizontalOffset + waveA + waveB + waveC;
        final y = center.dy - halfHeight + progress * halfHeight * 2;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);

      final beadProgress =
          (math.sin(layerTime + layer * (math.pi / 2)) + 1) / 2;
      final beadY = center.dy - halfHeight + beadProgress * halfHeight * 2;
      final normalizedY = (beadY - (center.dy - halfHeight)) / (halfHeight * 2);
      final beadX =
          center.dx +
          horizontalOffset +
          math.sin(normalizedY * 2 * math.pi * 3 + layerTime) * 12 * intensity +
          math.cos(normalizedY * 2 * math.pi * 5 - layerTime * 2) *
              8 *
              intensity +
          math.sin(normalizedY * 2 * math.pi * 2 + layerTime * 2) *
              6 *
              intensity;

      final beadPaint = Paint()
        ..color = config.primaryColor.withValues(alpha: isPlaying ? 0.9 : 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(beadX, beadY), 2.5 + (layer * 0.4), beadPaint);
    }

    // 3. Vòng tròn tâm nhịp tim phát sáng xung nhịp
    final pulseScale = 1.0 + (isPlaying ? math.sin(time * 3) * 0.15 : 0.0);
    final corePaint = Paint()
      ..color = config.primaryColor.withValues(alpha: isPlaying ? 0.12 : 0.04)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, baseRadius * 0.55 * pulseScale, corePaint);
  }
}
