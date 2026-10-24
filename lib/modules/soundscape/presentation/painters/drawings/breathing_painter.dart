import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';

/// 3. SLEEP: Quầng sáng phập phồng nhịp thở êm ái (Breathing Glow Circles)
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
  }) {
    // Nhịp thở chậm êm dịu (chu kỳ hít vào, thở ra)
    final breathCycle = (math.sin(time) + 1) / 2;
    final expansion = breathCycle * 25.0 * (isPlaying ? 1.0 : 0.3);

    final radiusX = size.width * 0.46 + expansion;
    final radiusY = size.height * 0.46 + expansion;

    // Vầng hào quang chuyển sắc tỏa ra bóng tối
    final gradient = RadialGradient(
      colors: [
        config.primaryColor.withValues(alpha: 0.15 + breathCycle * 0.1),
        config.primaryColor.withValues(alpha: 0.05),
        Colors.transparent,
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(radiusX, radiusY);
    final auraPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: Offset.zero, radius: 1),
      );
    canvas.drawCircle(Offset.zero, 1, auraPaint);
    canvas.restore();

    // Vòng tròn mờ nhạt bao ngoài
    for (int i = 0; i < 3; i++) {
      final ringScale = 1.0 + i * 0.08;
      final ringPaint = Paint()
        ..color = config.primaryColor.withValues(alpha: 0.18 - (i * 0.05))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radiusX * 2 * ringScale,
          height: radiusY * 2 * ringScale,
        ),
        ringPaint,
      );
    }
  }
}
