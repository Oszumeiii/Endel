import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';
import 'visual_effects_helper.dart';

/// 2. FOCUS: Khối tinh thể đa diện quay vi sai kỹ thuật (Geometric Crystals)
/// Tái hiện chuẩn xác phong cách Endel Focus:
/// - Đa giác lồng nhau quay vi sai theo tỷ lệ vàng (phi-ratio counter-rotation)
/// - Mạng lưới tinh thể kết nối đỉnh qua các tầng (Cross-layer Lattice Filaments)
/// - Vòng tròn tọa độ kỹ thuật HUD với các vạch khắc vi phân
/// - Các điểm nút tinh thể phát sáng với quầng sáng (Glowing Vertex Nodes)
/// - Đồng bộ nhịp xung âm học (Audio-Reactive Vertex Pulses)
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

    // 2. Hạt vi mô
    VisualEffectsHelper.drawAmbientParticles(
      canvas,
      size,
      time * 0.7,
      config.primaryColor,
      intensity: activityFactor * 0.7,
      audioReactiveFactor: audioReactiveFactor,
      count: 18,
    );

    final layers = config.layerCount.clamp(3, 5);
    final maxRadiusFactor = 0.44;
    final minRadiusFactor = 0.18;
    final radiusStep = (maxRadiusFactor - minRadiusFactor) / (layers - 1);

    final List<List<Offset>> layerVertices = [];
    const invPhi = 0.6180339887;

    for (int layer = 0; layer < layers; layer++) {
      final isEven = layer % 2 == 0;
      final rotSpeed = isEven ? 0.45 * (1.0 + layer * 0.2) : -0.45 * invPhi;
      final rotAngle = time * rotSpeed + (layer * (math.pi / 4));
      final sides = 6 + (layer * 2);
      final radiusFactor = maxRadiusFactor - (layers - 1 - layer) * radiusStep;

      // Độ phập phồng nhẹ nhàng kết hợp nhịp âm học
      final audioPulse = (audioReactiveFactor - 1.0) * 8.0;
      final breathe =
          (math.sin(time * 1.2 + layer) * 5.0 * activityFactor) + audioPulse;
      final radiusX = size.width * radiusFactor + breathe;
      final radiusY = size.height * radiusFactor + breathe;

      final currentVertices = <Offset>[];
      final path = Path();

      for (int i = 0; i <= sides; i++) {
        final theta = (i / sides) * 2 * math.pi + rotAngle;
        final x = center.dx + radiusX * math.cos(theta);
        final y = center.dy + radiusY * math.sin(theta);

        if (i < sides) {
          currentVertices.add(Offset(x, y));
        }

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      layerVertices.add(currentVertices);

      final depthFactor = (layer + 1) / layers;
      final strokeAlpha =
          ((0.18 + depthFactor * 0.55) *
                  (0.35 + 0.65 * activityFactor) *
                  (0.92 + 0.08 * audioReactiveFactor))
              .clamp(0.0, 1.0);

      // Quầng sáng tinh thể cho lớp ngoài cùng
      if (layer == layers - 1) {
        final glowPaint = Paint()
          ..color = config.primaryColor.withValues(
            alpha: (strokeAlpha * 0.4).clamp(0.0, 1.0),
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0)
          ..isAntiAlias = true;
        canvas.drawPath(path, glowPaint);
      }

      // Viền nét tinh thể sắc sảo
      final polyPaint = Paint()
        ..color = config.primaryColor.withValues(alpha: strokeAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 + (layer == layers - 1 ? 0.4 : 0.0)
        ..isAntiAlias = true;
      canvas.drawPath(path, polyPaint);
    }

    // 3. MẠNG LƯỚI TINH THỂ LIÊN KẾT GIỮA CÁC TẦNG (Lattice Connectors)
    for (int l = 0; l < layers - 1; l++) {
      final inner = layerVertices[l];
      final outer = layerVertices[l + 1];
      final linePaint = Paint()
        ..color = config.accentColor.withValues(
          alpha: (0.10 * activityFactor * (0.9 + 0.1 * audioReactiveFactor))
              .clamp(0.0, 1.0),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;

      for (int i = 0; i < inner.length; i++) {
        final targetIndex =
            (i * outer.length / inner.length).round() % outer.length;
        canvas.drawLine(inner[i], outer[targetIndex], linePaint);
      }
    }

    // 4. VẼ CÁC ĐIỂM NÚT TINH THỂ PHÁT SÁNG (Crystal Luminous Vertices)
    final outerLayer = layerVertices.last;
    for (int i = 0; i < outerLayer.length; i++) {
      final pulse = (math.sin(time * 2.0 + i * (math.pi / 3)) + 1.0) / 2.0;
      VisualEffectsHelper.drawGlowingPoint(
        canvas,
        outerLayer[i],
        2.2 + pulse * 1.2,
        color: config.primaryColor,
        glowSigma: 4.0,
        glowAlpha:
            ((0.2 + pulse * 0.3) * activityFactor * audioReactiveFactor)
                .clamp(0.0, 1.0),
        coreAlpha: (0.95 * activityFactor).clamp(0.0, 1.0),
        audioReactiveFactor: audioReactiveFactor,
      );
    }

    // 5. VÒNG TRÒN TỌA ĐỘ VÀ VẠCH KHẮC KỸ THUẬT NỘI TÂM
    final reticleRadius =
        size.width * 0.14 * (0.97 + 0.03 * audioReactiveFactor);
    final reticlePaint = Paint()
      ..color = config.primaryColor.withValues(
        alpha: (0.15 * activityFactor).clamp(0.0, 1.0),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    canvas.drawCircle(center, reticleRadius, reticlePaint);

    const ticks = 12;
    for (int t = 0; t < ticks; t++) {
      final tickAngle = (t / ticks) * 2 * math.pi + (time * 0.15);
      final p1 = Offset(
        center.dx + (reticleRadius - 4) * math.cos(tickAngle),
        center.dy + (reticleRadius - 4) * math.sin(tickAngle),
      );
      final p2 = Offset(
        center.dx + (reticleRadius + 4) * math.cos(tickAngle),
        center.dy + (reticleRadius + 4) * math.sin(tickAngle),
      );
      canvas.drawLine(p1, p2, reticlePaint);
    }

    // Điểm hội tụ trung tâm
    VisualEffectsHelper.drawGlowingPoint(
      canvas,
      center,
      3.5,
      color: config.primaryColor,
      glowSigma: 5.0,
      glowAlpha: (0.3 * activityFactor * audioReactiveFactor).clamp(0.0, 1.0),
      coreAlpha: (0.9 * activityFactor).clamp(0.0, 1.0),
      audioReactiveFactor: audioReactiveFactor,
    );
  }
}
