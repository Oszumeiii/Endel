import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';
import 'visual_effects_helper.dart';

/// 1. AURORA: Những mảng ánh sáng màu lớn, mờ, trôi chậm theo quỹ đạo Lissajous và hòa vào nhau.
class AuroraVisualPainter extends VisualPainterStrategy {
  const AuroraVisualPainter();

  static final Paint _blobPaint = Paint()
    ..style = PaintingStyle.fill
    ..blendMode = BlendMode.plus
    ..isAntiAlias = true;

  static final Paint _grainPaint = Paint()
    ..style = PaintingStyle.fill
    ..blendMode = BlendMode.plus;

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
    // 1. Nền gradient sâu thẳm
    VisualEffectsHelper.drawBackdrop(
      canvas,
      size,
      config.primaryColor,
      config.accentColor,
      intensity: activityFactor,
    );

    // 2. Ánh sáng khí quyển nền
    VisualEffectsHelper.drawAtmosphere(
      canvas,
      size,
      center,
      config.primaryColor,
      config.accentColor,
      intensity: activityFactor,
      audioReactiveFactor: audioReactiveFactor,
    );

    final minDim = math.min(size.width, size.height);
    if (minDim <= 0) return;

    final t = time * 1.15;
    final playScale = isPlaying ? 1.0 : 0.45;
    final audioScale = 0.97 + 0.03 * audioReactiveFactor.clamp(0.0, 2.0);
    final blobCount = config.layerCount.clamp(4, 6);

    final amp =
        0.28 *
        minDim *
        (0.75 + 0.25 * activityFactor) *
        config.deformationIntensity.clamp(0.4, 1.8) *
        playScale;

    // 3. Các mảng sáng lớn trôi nhanh vừa phải và hòa vào nhau (0 MaskFilter.blur)
    for (int i = 0; i < blobCount; i++) {
      // Tần số Lissajous xác định trong khoảng 0.10 - 0.24 rad/s
      final seedA = ((math.sin(i * 12.9898 + 1.23) + 1.0) * 0.5);
      final seedB = ((math.cos(i * 78.233 + 4.56) + 1.0) * 0.5);
      final fx = 0.10 + seedA * 0.14;
      final fy = 0.10 + seedB * 0.14;
      final px = i * 1.6180339887;
      final py = i * 2.3999632297;

      final dx = amp * math.sin(t * fx + px);
      final dy = amp * math.cos(t * fy + py);
      final blobCenter = Offset(center.dx + dx, center.dy + dy);

      final radius =
          minDim * (0.30 + 0.12 * math.sin(t * 0.22 + i) * playScale) * audioScale;

      final colorMix = i.isEven
          ? (i / math.max(1, blobCount - 1)) * 0.45
          : 0.55 + (i / math.max(1, blobCount - 1)) * 0.45;
      final blobColor =
          Color.lerp(
            config.primaryColor,
            config.accentColor,
            colorMix.clamp(0.0, 1.0),
          ) ??
          config.primaryColor;

      final centerAlpha = (0.35 * (0.55 + 0.45 * activityFactor)).clamp(
        0.0,
        1.0,
      );

      _blobPaint.shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          blobColor.withValues(alpha: centerAlpha),
          blobColor.withValues(alpha: (centerAlpha * 0.45).clamp(0.0, 1.0)),
          blobColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: blobCenter, radius: radius));

      // Kéo dãn nhẹ một blob lớn thành elip để tạo dòng cực quang tự nhiên
      if (i == 0) {
        canvas.save();
        canvas.translate(blobCenter.dx, blobCenter.dy);
        canvas.scale(1.32, 0.78);
        canvas.translate(-blobCenter.dx, -blobCenter.dy);
        canvas.drawCircle(blobCenter, radius, _blobPaint);
        canvas.restore();
      } else {
        canvas.drawCircle(blobCenter, radius, _blobPaint);
      }
    }
    _blobPaint.shader = null;

    // 4. Grain rất nhẹ xác định theo chỉ số i để giảm banding chuyển sắc
    const grainCount = 48;
    final grainAlpha = (0.045 * (0.5 + 0.5 * activityFactor)).clamp(0.0, 0.06);
    _grainPaint.color = config.primaryColor.withValues(alpha: grainAlpha);
    for (int i = 0; i < grainCount; i++) {
      final phi = i * 0.61803398875;
      final gx = (((phi * 17.13 + t * 0.012) % 1.0) + 1.0) % 1.0 * size.width;
      final gy = (((phi * 29.71 - t * 0.008) % 1.0) + 1.0) % 1.0 * size.height;
      canvas.drawCircle(Offset(gx, gy), 0.6, _grainPaint);
    }
  }
}
