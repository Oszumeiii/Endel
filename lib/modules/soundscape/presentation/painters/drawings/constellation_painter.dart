import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';

/// 6. ADHD / CENTERING: Mạng lưới nút cộng hưởng Constellation Mesh
/// Giúp ổn định chú ý, phân tán nhiễu tâm lý bằng hình học mạng lưới kết nối hài hòa
class ConstellationVisualPainter extends VisualPainterStrategy {
  const ConstellationVisualPainter();

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
    const nodeCount = 10;
    final nodes = <Offset>[];

    // Tạo các điểm mút trên 2 quỹ đạo elip giao nhau
    for (int i = 0; i < nodeCount; i++) {
      final angle = (i / nodeCount) * 2 * math.pi + time;
      final ring = i % 2 == 0 ? 1.0 : 0.65;
      final waveOffset = isPlaying ? math.sin(time * 2 + i * 1.5) * 0.025 : 0.0;
      final radiusFactor = 0.4 * ring + waveOffset;

      final x = center.dx + size.width * radiusFactor * math.cos(angle);
      final y =
          center.dy +
          size.height *
              radiusFactor *
              math.sin(angle) *
              (i % 2 == 0 ? 0.9 : 1.15);
      nodes.add(Offset(x, y));
    }

    // Vẽ các đường nối giữa các nút lân cận
    final linePaint = Paint()
      ..color = config.primaryColor.withValues(alpha: isPlaying ? 0.22 : 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..isAntiAlias = true;

    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final dist = (nodes[i] - nodes[j]).distance;
        if (dist < math.min(size.width, size.height) * 0.55) {
          canvas.drawLine(nodes[i], nodes[j], linePaint);
        }
      }
    }

    // Vẽ các nút điểm sao
    final nodePaint = Paint()
      ..color = config.primaryColor.withValues(alpha: isPlaying ? 0.85 : 0.45)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < nodes.length; i++) {
      final nodeSize = 2.5 + (i % 3) * 0.8;
      canvas.drawCircle(nodes[i], nodeSize, nodePaint);
    }

    // Vòng tròn định vị quỹ đạo trung tâm
    final orbitPaint = Paint()
      ..color = config.primaryColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.86,
        height: size.height * 0.86,
      ),
      orbitPaint,
    );
  }
}
