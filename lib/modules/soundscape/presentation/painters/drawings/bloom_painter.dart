import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';
import 'visual_effects_helper.dart';

/// 7. BLOOM: Họ sợi mảnh tạo hình đóa hoa / quả cầu string-art 3D xoay chậm trong không gian.
class BloomVisualPainter extends VisualPainterStrategy {
  const BloomVisualPainter();

  // Hằng số chất lượng và tốc độ
  static const double _kQuality = 1.0;
  static const double _kSpeedScale = 0.4;
  static const int _kMaxSegments = 128;

  static final Paint _backdropGlowPaint = Paint()
    ..style = PaintingStyle.fill
    ..blendMode = BlendMode.plus
    ..isAntiAlias = true;

  static final Paint _threadPaint = Paint()
    ..style = PaintingStyle.stroke
    ..blendMode = BlendMode.plus
    ..isAntiAlias = true;

  static final Paint _glowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.4
    ..blendMode = BlendMode.plus
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0)
    ..isAntiAlias = true;

  static final Path _threadPath = Path();
  static final Path _glowPath = Path();

  // Bộ đệm static lưu các điểm của một vòng khép kín để vẽ smoothClosedPath không cấp phát rác
  static final Float64List _ptsX = Float64List(_kMaxSegments);
  static final Float64List _ptsY = Float64List(_kMaxSegments);

  static double _hash(int i, int salt) {
    final x = math.sin(i * 12.9898 + salt * 78.233) * 43758.5453;
    return x - x.floorToDouble();
  }

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
    if (size.isEmpty) return;

    final minDim = math.min(size.width, size.height);
    if (minDim <= 0) return;

    // 1. Nền và khí quyển
    VisualEffectsHelper.drawBackdrop(
      canvas,
      size,
      config.primaryColor,
      config.accentColor,
      intensity: activityFactor,
    );

    VisualEffectsHelper.drawAtmosphere(
      canvas,
      size,
      center,
      config.primaryColor,
      config.accentColor,
      intensity: activityFactor * 0.85,
      audioReactiveFactor: audioReactiveFactor,
    );

    final t = time * _kSpeedScale;
    final playScale = isPlaying ? 1.0 : 0.4;
    final audioScale = 0.97 + 0.03 * audioReactiveFactor.clamp(0.0, 2.0);
    final activityMod = 0.70 + 0.30 * activityFactor.clamp(0.0, 1.5);
    final deform = config.deformationIntensity.clamp(0.4, 1.8);

    // Đường kính tổng thể ~0.62 * minDim => bán kính cơ sở ~0.31 * minDim (cộng nhịp thở ±4%)
    final breath = 1.0 + 0.04 * math.sin(t * 0.4) * playScale;
    final baseR = minDim * 0.24 * breath * audioScale;

    // Quầng RadialGradient mềm sau hình (không blur)
    final backGlowR = minDim * 0.38 * breath;
    final backGlowAlpha = (0.14 * activityMod).clamp(0.0, 0.18);
    _backdropGlowPaint.shader = RadialGradient(
      colors: [
        config.accentColor.withValues(alpha: backGlowAlpha),
        config.primaryColor.withValues(alpha: (backGlowAlpha * 0.35).clamp(0.0, 0.15)),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: backGlowR));
    canvas.drawCircle(center, backGlowR, _backdropGlowPaint);
    _backdropGlowPaint.shader = null;

    final threadCount = (64 * _kQuality).round().clamp(32, 72);
    final segments = (120 * _kQuality).round().clamp(60, _kMaxSegments);
    final petalCount = 3 + config.layerCount.clamp(2, 5);
    final petalAmp = 0.38 * (0.8 + 0.2 * activityFactor.clamp(0.0, 1.5)) * deform;

    final globalRot = time * 0.12;
    final cosGlobal = math.cos(globalRot);
    final sinGlobal = math.sin(globalRot);
    final tilt = 0.9 + 0.25 * math.sin(t * 0.2) * playScale;

    _glowPath.reset();
    final glowStep = math.max(1, threadCount ~/ 7);

    // 2. Dựng họ đường cong hoa hồng xoay quanh trục tạo khối cầu/đóa sen 3D
    for (int k = 0; k < threadCount; k++) {
      final u = k / threadCount;
      final phi = u * math.pi + globalRot * 0.65;
      final cosPhi = math.cos(phi);
      // Độ sâu 3D để phân biệt mặt trước / mặt sau
      final depth = 0.5 + 0.5 * math.sin(phi).abs();

      final scaleK = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(u * math.pi + _hash(k, 1) * 0.08));
      final phaseShift = t * 0.5 * playScale + u * math.pi * 2.0;

      for (int s = 0; s < segments; s++) {
        final theta = (s / segments) * math.pi * 2.0;
        final r = baseR * (1.0 + petalAmp * math.sin(petalCount * theta + phaseShift)) * scaleK;

        // Tọa độ phẳng hoa hồng -> xoay phối cảnh nhẹ thành vật thể 3D
        final lx = r * math.cos(theta) * cosPhi;
        final ly = r * math.sin(theta) * tilt;

        // Xoay toàn khối chậm quanh tâm
        _ptsX[s] = center.dx + lx * cosGlobal - ly * sinGlobal;
        _ptsY[s] = center.dy + lx * sinGlobal + ly * cosGlobal;
      }

      // Dựng đường cong khép kín mượt hoàn toàn (giống VisualEffectsHelper.smoothClosedPath)
      _threadPath.reset();
      final startMidX = (_ptsX[segments - 1] + _ptsX[0]) * 0.5;
      final startMidY = (_ptsY[segments - 1] + _ptsY[0]) * 0.5;
      _threadPath.moveTo(startMidX, startMidY);

      for (int s = 0; s < segments; s++) {
        final next = (s + 1) % segments;
        final midX = (_ptsX[s] + _ptsX[next]) * 0.5;
        final midY = (_ptsY[s] + _ptsY[next]) * 0.5;
        _threadPath.quadraticBezierTo(_ptsX[s], _ptsY[s], midX, midY);
      }
      _threadPath.close();

      final threadColor =
          Color.lerp(config.primaryColor, config.accentColor, u) ??
          config.primaryColor;
      final alpha = ((0.08 + 0.10 * depth) * activityMod).clamp(0.0, 0.18);

      _threadPaint
        ..color = threadColor.withValues(alpha: alpha)
        ..strokeWidth = 0.8 + 0.3 * depth;
      canvas.drawPath(_threadPath, _threadPaint);

      // Gom 6-8 sợi đại diện vào 1 glowPath (1 MaskFilter.blur/frame)
      if (k % glowStep == 0) {
        _glowPath.addPath(_threadPath, Offset.zero);
      }
    }

    // 3. Lớp glow mềm cho các sợi biên
    final glowAlpha = (0.14 * activityMod).clamp(0.0, 0.20);
    _glowPaint.color = config.primaryColor.withValues(alpha: glowAlpha);
    canvas.drawPath(_glowPath, _glowPaint);
  }
}
