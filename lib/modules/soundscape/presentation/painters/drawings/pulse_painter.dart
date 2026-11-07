import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';
import 'visual_effects_helper.dart';

/// 5. MOVE: Xung radar lan tỏa theo nhịp tuần hoàn thể lực (Radar Pulse & Cadence Rings)
/// Tái hiện chuẩn xác phong cách Endel Move:
/// - Các vòng sóng âm lan truyền liên tục từ tâm ra ngoài (Concentric Propagating Wavefronts)
/// - Chùm quét radar quét 360 độ lưu luyến vệt phát quang phosphorescent
/// - Các điểm tiêu cự / trạm định vị (Cadence Beacon Nodes) bừng sáng khi chùm quét đi qua
/// - Nhịp tim/bước chân trung tâm xung kích mạnh mẽ đồng bộ âm thanh thực tế
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
      time * 0.9,
      config.primaryColor,
      intensity: activityFactor * 0.8,
      audioReactiveFactor: audioReactiveFactor,
      count: 22,
    );

    final maxRadius = math.min(size.width, size.height) * 0.46;

    // 3. CÁC VÒNG SÓNG ÂM LAN TRUYỀN LIÊN TỤC (Propagating Wavefronts)
    const ringCount = 5;
    for (int r = 0; r < ringCount; r++) {
      final ringProgress = ((time * 0.35) + (r / ringCount)) % 1.0;
      final currentRadius =
          maxRadius * math.sqrt(ringProgress) * (0.97 + 0.03 * audioReactiveFactor);
      final fadeAlpha =
          ((1.0 - ringProgress) *
                  0.35 *
                  (0.3 + 0.7 * activityFactor) *
                  audioReactiveFactor)
              .clamp(0.0, 1.0);

      if (currentRadius > 4.0 && fadeAlpha > 0.01) {
        final wavePaint = Paint()
          ..color = config.primaryColor.withValues(alpha: fadeAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0 + (1.0 - ringProgress) * 0.8
          ..isAntiAlias = true;
        canvas.drawCircle(center, currentRadius, wavePaint);
      }
    }

    // 4. CHÙM QUÉT RADAR VỚI VỆT SÁNG PHOSPHORESCENT (Sweeping Sonar Beam)
    final sweepAngle = math.pi * 0.42;
    final sweepRotation = time * 1.8;

    canvas.save();
    canvas.translate(center.dx, center.dy);

    final sweepRect = Rect.fromCircle(center: Offset.zero, radius: maxRadius);
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: sweepRotation - sweepAngle,
        endAngle: sweepRotation,
        colors: [
          Colors.transparent,
          config.primaryColor.withValues(
            alpha: (0.04 * activityFactor).clamp(0.0, 1.0),
          ),
          config.primaryColor.withValues(
            alpha: (0.16 * activityFactor * audioReactiveFactor).clamp(0.0, 1.0),
          ),
        ],
        stops: const [0.0, 0.6, 1.0],
        transform: GradientRotation(sweepRotation - sweepAngle),
      ).createShader(sweepRect)
      ..style = PaintingStyle.fill;

    final sweepPath = Path()
      ..moveTo(0, 0)
      ..arcTo(sweepRect, sweepRotation - sweepAngle, sweepAngle, false)
      ..close();
    canvas.drawPath(sweepPath, sweepPaint);

    final leadingLinePaint = Paint()
      ..color = config.primaryColor.withValues(
        alpha: (0.75 * activityFactor).clamp(0.0, 1.0),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;
    final leadX = maxRadius * math.cos(sweepRotation);
    final leadY = maxRadius * math.sin(sweepRotation);
    canvas.drawLine(Offset.zero, Offset(leadX, leadY), leadingLinePaint);

    // 5. CÁC ĐIỂM TIÊU CỰ / TRẠM ĐỊNH VỊ (Cadence Beacon Nodes)
    const targets = [
      Offset(0.52, -0.28),
      Offset(-0.38, 0.58),
      Offset(-0.65, -0.35),
      Offset(0.32, 0.62),
      Offset(-0.25, -0.68),
    ];

    for (int i = 0; i < targets.length; i++) {
      final tPos = Offset(targets[i].dx * maxRadius, targets[i].dy * maxRadius);
      final targetAngle =
          (math.atan2(tPos.dy, tPos.dx) + 2 * math.pi) % (2 * math.pi);
      final currentSweepNorm =
          (sweepRotation % (2 * math.pi) + 2 * math.pi) % (2 * math.pi);

      var angleDiff = (currentSweepNorm - targetAngle) % (2 * math.pi);
      if (angleDiff < 0) angleDiff += 2 * math.pi;

      final flare = angleDiff < sweepAngle
          ? (1.0 - (angleDiff / sweepAngle))
          : 0.0;
      final targetAlpha =
          ((0.18 + flare * 0.75) *
                  (0.35 + 0.65 * activityFactor) *
                  audioReactiveFactor)
              .clamp(0.0, 1.0);

      VisualEffectsHelper.drawGlowingPoint(
        canvas,
        tPos,
        2.2 + flare * 1.5,
        color: config.primaryColor,
        glowSigma: 4.0 + flare * 3.0,
        glowAlpha: (targetAlpha * 0.45).clamp(0.0, 1.0),
        coreAlpha: targetAlpha,
        audioReactiveFactor: audioReactiveFactor,
      );
    }
    canvas.restore();

    // 6. LÕI PHÁT NHỊP BƯỚC CHÂN TRUNG TÂM (Cadence Core Pulse)
    final coreBeat = (math.sin(time * 4.6) + 1.0) / 2.0;
    final coreRadius =
        (4.5 + coreBeat * 2.2 * activityFactor) *
        (0.95 + 0.05 * audioReactiveFactor);
    VisualEffectsHelper.drawGlowingPoint(
      canvas,
      center,
      coreRadius,
      color: config.primaryColor,
      glowSigma: 6.0,
      glowAlpha: (0.4 * activityFactor * audioReactiveFactor).clamp(0.0, 1.0),
      coreAlpha: (0.95 * activityFactor).clamp(0.0, 1.0),
      audioReactiveFactor: audioReactiveFactor,
    );
  }
}
