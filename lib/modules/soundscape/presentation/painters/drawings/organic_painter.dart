import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';
import 'visual_effects_helper.dart';

/// 1. RELAX: Các dải lụa sóng hữu cơ uốn lượn đa hài (Organic Harmonic Ribbons)
/// Lấy cảm hứng từ ngôn ngữ thị giác cốt lõi của Endel (https://endel.io):
/// - Sóng đa hài phi chu kỳ (sử dụng tỷ lệ vàng phi lặp lại)
/// - Chiều sâu không gian 3 tầng (Background blur, Midground silk ribbons, Foreground luminous core)
/// - Bề mặt thể tích bán trong suốt (Volumetric Translucent Meshes) giữa các cặp sóng
/// - Chuyển động êm ái, tiếp tục thở nhẹ nhàng khi tạm dừng (Ambient Idle Breathing)
/// - Đồng bộ nhịp âm học (Audio-Reactive Harmony)
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
    double activityFactor = 1.0,
    double audioReactiveFactor = 1.0,
  }) {
    // 1. Ánh sáng khí quyển nền sâu thẳm
    VisualEffectsHelper.drawAtmosphere(
      canvas,
      size,
      center,
      config.primaryColor,
      config.accentColor,
      intensity: activityFactor,
      audioReactiveFactor: audioReactiveFactor,
    );

    // 2. Các hạt vi mô trôi nổi hữu cơ
    VisualEffectsHelper.drawAmbientParticles(
      canvas,
      size,
      time,
      config.primaryColor,
      intensity: activityFactor,
      audioReactiveFactor: audioReactiveFactor,
      count: 24,
    );

    final layers = config.layerCount.clamp(3, 7);
    final intensity =
        config.deformationIntensity *
        (0.35 + 0.65 * activityFactor) *
        audioReactiveFactor;
    final halfHeight = size.height * 0.48;
    final spacing = layers > 1 ? (size.width * 0.80) / (layers - 1) : 0.0;
    const points = 160;

    // Lưu trữ danh sách điểm của từng lớp sóng để tạo dải lụa thể tích nối liền
    final List<List<Offset>> waveRibbons = [];

    // Tần số tỷ lệ vàng và số vô tỷ giúp chuyển động tự nhiên, không lặp lại máy móc
    const phi = 1.6180339887;
    const invPhi = 0.6180339887;

    for (int layer = 0; layer < layers; layer++) {
      final horizontalOffset = (layer - (layers - 1) / 2.0) * spacing;
      final phaseOffset = layer * (math.pi / 2.618) + (layer * 0.4);

      // Tốc độ sóng biến thiên nhẹ theo từng lớp
      final layerSpeed = 0.85 + (layer * 0.22);
      final layerTime = time * layerSpeed;

      final pointsList = <Offset>[];

      for (int i = 0; i <= points; i++) {
        final progress = i / points;

        // Hàm bao làm mượt hai đầu cực trên & dưới (Envelope Bell Curve)
        final envelope = math.pow(math.sin(progress * math.pi), 1.15);

        // Tổng hợp sóng đa hài phi chu kỳ (Non-linear Harmonic Wave Sum)
        final w1 =
            math.sin(progress * 2 * math.pi * 1.5 + layerTime + phaseOffset) *
            22.0;
        final w2 =
            math.cos(
              progress * 2 * math.pi * (1.5 * phi) -
                  layerTime * invPhi +
                  phaseOffset,
            ) *
            14.0;
        final w3 =
            math.sin(
              progress * 2 * math.pi * 3.236 + layerTime * 1.4 + phaseOffset,
            ) *
            8.0;
        final w4 =
            math.cos(
              progress * 2 * math.pi * 5.236 - layerTime * 0.8 + phaseOffset,
            ) *
            4.0;

        final displacement = (w1 + w2 + w3 + w4) * intensity * envelope;

        final x = center.dx + horizontalOffset + displacement;
        final y = center.dy - halfHeight + (progress * halfHeight * 2.0);

        pointsList.add(Offset(x, y));
      }

      waveRibbons.add(pointsList);
    }

    // 3. VẼ DẢI LỤA THỂ TÍCH (Volumetric Translucent Ribbon Meshes)
    for (int layer = 0; layer < layers - 1; layer++) {
      final ribbonPath = Path();
      final currentLayer = waveRibbons[layer];
      final nextLayer = waveRibbons[layer + 1];

      ribbonPath.moveTo(currentLayer.first.dx, currentLayer.first.dy);
      for (int i = 1; i < currentLayer.length; i++) {
        ribbonPath.lineTo(currentLayer[i].dx, currentLayer[i].dy);
      }
      for (int i = nextLayer.length - 1; i >= 0; i--) {
        ribbonPath.lineTo(nextLayer[i].dx, nextLayer[i].dy);
      }
      ribbonPath.close();

      final ribbonAlpha =
          ((0.02 + (layer / layers) * 0.035) * activityFactor * audioReactiveFactor)
              .clamp(0.0, 1.0);
      final meshGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          config.accentColor.withValues(alpha: ribbonAlpha * 0.7),
          config.primaryColor.withValues(alpha: ribbonAlpha),
          config.accentColor.withValues(alpha: ribbonAlpha * 0.7),
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      );

      final meshPaint = Paint()
        ..shader = meshGradient.createShader(
          Rect.fromLTWH(0, center.dy - halfHeight, size.width, halfHeight * 2),
        )
        ..style = PaintingStyle.fill;

      canvas.drawPath(ribbonPath, meshPaint);
    }

    // 4. VẼ CÁC ĐƯỜNG SÓNG CỐT LÕI VÀ PHÁT QUANG ĐA TẦNG
    for (int layer = 0; layer < layers; layer++) {
      final currentLayer = waveRibbons[layer];
      final path = Path();
      path.moveTo(currentLayer.first.dx, currentLayer.first.dy);

      for (int i = 1; i < currentLayer.length; i++) {
        final prev = currentLayer[i - 1];
        final curr = currentLayer[i];
        final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
        path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
      }
      path.lineTo(currentLayer.last.dx, currentLayer.last.dy);

      final depthFactor = (layer + 1) / layers;
      final isForeGround = layer >= layers - 2;

      final strokeAlpha =
          ((0.18 + depthFactor * 0.72) *
                  (0.4 + 0.6 * activityFactor) *
                  (0.92 + 0.08 * audioReactiveFactor))
              .clamp(0.0, 1.0);
      final strokeGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          config.primaryColor.withValues(alpha: strokeAlpha * 0.5),
          config.primaryColor.withValues(alpha: strokeAlpha),
          config.primaryColor.withValues(alpha: strokeAlpha * 0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.12, 0.5, 0.88, 1.0],
      );

      final shaderRect = Rect.fromLTWH(
        0,
        center.dy - halfHeight,
        size.width,
        halfHeight * 2,
      );

      // Lớp phát quang mờ (Ambient Glow Pass)
      if (isForeGround) {
        final glowPaint = Paint()
          ..shader = strokeGradient.createShader(shaderRect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8 + (layer * 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0)
          ..isAntiAlias = true;
        canvas.drawPath(path, glowPaint);
      }

      // Lớp nét vẽ chính sắc nét (Core Stroke Pass)
      final corePaint = Paint()
        ..shader = strokeGradient.createShader(shaderRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1 + (depthFactor * 0.9)
        ..isAntiAlias = true;
      canvas.drawPath(path, corePaint);
    }
  }
}
