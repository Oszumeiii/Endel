import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';

/// 5. MOVE: Chùm quét radar xoay với các điểm phản hồi
class PulseVisualPainter extends VisualPainterStrategy {
  const PulseVisualPainter();

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
    final radiusX = size.width * 0.48;
    final radiusY = size.height * 0.48;
    final radius = math.min(radiusX, radiusY);
    final sweepAngle = math.pi / 3;
    final rotation = time * 2;
    final sweepPath = Path()
      ..moveTo(0, 0)
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: 1),
        rotation - sweepAngle / 2,
        sweepAngle,
        false,
      )
      ..close();
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(radiusX, radiusY);
    final sweepPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          config.primaryColor.withValues(alpha: isPlaying ? 0.24 : 0.1),
          config.primaryColor.withValues(alpha: isPlaying ? 0.08 : 0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.72, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 1))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(sweepPath, sweepPaint);

    final edgePaint = Paint()
      ..color = config.primaryColor.withValues(alpha: isPlaying ? 0.7 : 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 / radius
      ..isAntiAlias = true;
    final edgePath = Path()
      ..moveTo(0, 0)
      ..lineTo(
        math.cos(rotation + sweepAngle / 2),
        math.sin(rotation + sweepAngle / 2),
      );
    canvas.drawPath(edgePath, edgePaint);

    const targets = [
      Offset(0.58, -0.24),
      Offset(-0.34, 0.62),
      Offset(-0.72, -0.38),
    ];
    for (int i = 0; i < targets.length; i++) {
      final visibility = (math.sin(time * 2 + i * 2 * math.pi / 3) + 1) / 2;
      final targetPaint = Paint()
        ..color = config.primaryColor.withValues(
          alpha: (isPlaying ? 0.25 : 0.12) + visibility * 0.65,
        )
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(targets[i].dx, targets[i].dy),
        (2.0 + visibility) / radius,
        targetPaint,
      );
    }
    canvas.restore();

    final corePulse = isPlaying ? math.sin(time * 4) * 1.5 : 0.0;
    final corePaint = Paint()
      ..color = config.primaryColor.withValues(alpha: isPlaying ? 0.9 : 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5.0 + corePulse, corePaint);
  }
}
