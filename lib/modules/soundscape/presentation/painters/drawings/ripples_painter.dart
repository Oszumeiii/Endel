import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';
import 'visual_effects_helper.dart';

/// 7. RIPPLES: Các dải sóng nước giao thoa đa tầng (Water Ripples & Caustics)
/// Tái hiện chuẩn xác phong cách Endel Nature / Water:
/// - Sóng nước uốn lượn đa tần số với độ suy giảm Gauss theo phương thẳng đứng
/// - Hiện tượng giao thoa sóng tạo gợn sáng tự nhiên (Interference Caustics)
/// - Bề mặt phản chiếu bán trong suốt tạo độ sâu chất lỏng
/// - Đồng bộ nhịp chấn động giọt nước với âm học thực tế (Acoustic Droplet Resonance)
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

    // 2. Hạt bụi sương
    VisualEffectsHelper.drawAmbientParticles(
      canvas,
      size,
      time * 0.4,
      config.primaryColor,
      intensity: activityFactor * 0.7,
      audioReactiveFactor: audioReactiveFactor,
      count: 20,
    );

    const lineCount = 9;
    final halfWidth = size.width * 0.48;
    final spacing = (size.height * 0.85) / (lineCount - 1);
    final intensity =
        config.deformationIntensity *
        (0.35 + 0.65 * activityFactor) *
        audioReactiveFactor;
    const points = 140;

    final List<List<Offset>> rippleLines = [];

    for (int i = 0; i < lineCount; i++) {
      final offset = (i - (lineCount - 1) / 2.0) * spacing;
      final verticalFade = math.exp(
        -math.pow(offset / (size.height * 0.32), 2),
      );

      final linePoints = <Offset>[];

      for (int p = 0; p <= points; p++) {
        final progress = p / points;
        final x = center.dx - halfWidth + progress * halfWidth * 2.0;

        final w1 =
            math.sin(progress * 2 * math.pi * 2.2 + time + i * 0.42) * 12.0;
        final w2 =
            math.sin(progress * 2 * math.pi * 4.4 - time * 1.6 + i * 0.28) *
            5.0;
        final w3 =
            math.cos(progress * 2 * math.pi * 1.2 + time * 0.8 + i * 0.15) *
            3.5;

        final envelope = math.pow(math.sin(progress * math.pi), 0.85);
        final displacement =
            (w1 + w2 + w3) * intensity * verticalFade * envelope;

        final y = center.dy + offset + displacement;
        linePoints.add(Offset(x, y));
      }

      rippleLines.add(linePoints);
    }

    // 3. VẼ DẢI MÀU GIAO THOA THỂ TÍCH GIỮA CÁC ĐƯỜNG GỢN NƯỚC
    for (int i = 0; i < lineCount - 1; i++) {
      final currentLine = rippleLines[i];
      final nextLine = rippleLines[i + 1];

      final meshPath = Path()
        ..moveTo(currentLine.first.dx, currentLine.first.dy);
      for (int p = 1; p < currentLine.length; p++) {
        meshPath.lineTo(currentLine[p].dx, currentLine[p].dy);
      }
      for (int p = nextLine.length - 1; p >= 0; p--) {
        meshPath.lineTo(nextLine[p].dx, nextLine[p].dy);
      }
      meshPath.close();

      final meshAlpha =
          (0.025 * activityFactor * audioReactiveFactor).clamp(0.0, 1.0);
      final meshPaint = Paint()
        ..color = config.accentColor.withValues(alpha: meshAlpha)
        ..style = PaintingStyle.fill;
      canvas.drawPath(meshPath, meshPaint);
    }

    // 4. VẼ CÁC ĐƯỜNG GỢN SÓNG VỚI NÉT PHÁT QUANG
    for (int i = 0; i < lineCount; i++) {
      final linePoints = rippleLines[i];
      final offset = (i - (lineCount - 1) / 2.0) * spacing;
      final verticalFade = math.exp(
        -math.pow(offset / (size.height * 0.32), 2),
      );

      final path = Path()..moveTo(linePoints.first.dx, linePoints.first.dy);
      for (int p = 1; p < linePoints.length; p++) {
        final prev = linePoints[p - 1];
        final curr = linePoints[p];
        final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
        path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
      }
      path.lineTo(linePoints.last.dx, linePoints.last.dy);

      final lineAlpha =
          ((0.18 + verticalFade * 0.65) *
                  (0.35 + 0.65 * activityFactor) *
                  (0.92 + 0.08 * audioReactiveFactor))
              .clamp(0.0, 1.0);

      // Quầng sáng trên các đường gợn trung tâm
      if (verticalFade > 0.6) {
        final glowPaint = Paint()
          ..color = config.primaryColor.withValues(
            alpha: (lineAlpha * 0.35).clamp(0.0, 1.0),
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
          ..isAntiAlias = true;
        canvas.drawPath(path, glowPaint);
      }

      // Nét vẽ chính
      final corePaint = Paint()
        ..color = config.primaryColor.withValues(alpha: lineAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 + verticalFade * 0.8
        ..isAntiAlias = true;
      canvas.drawPath(path, corePaint);
    }

    // 5. GIỌT NƯỚC RƠI / ĐIỂM CHẤN ĐỘNG TRUNG TÂM (Center Droplet Resonance)
    final dropletPulse = (math.sin(time * 2.2) + 1.0) / 2.0;
    VisualEffectsHelper.drawGlowingPoint(
      canvas,
      center,
      3.5 + dropletPulse * 1.5 * activityFactor,
      color: config.primaryColor,
      glowSigma: 5.0,
      glowAlpha: (0.35 * activityFactor * audioReactiveFactor).clamp(0.0, 1.0),
      coreAlpha: (0.95 * activityFactor).clamp(0.0, 1.0),
      audioReactiveFactor: audioReactiveFactor,
    );
  }
}
