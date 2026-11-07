import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Helper chuyên biệt vẽ hiệu ứng ánh sáng khí quyển (Atmospheric Lighting),
/// hạt lượng tử hữu cơ (Ambient Particles) và phát quang đa lớp (Multi-layer Glow)
/// chuẩn ngôn ngữ thiết kế Endel (https://endel.io).
///
/// Tối ưu hóa hiệu năng di động (Performance Optimization):
/// - Tái sử dụng đối tượng Paint (Zero Heap Allocation)
/// - Giới hạn ngưỡng làm mờ (MaskFilter Sigma) an toàn cho GPU di động
/// - Thuật toán tạo hạt xác định (Deterministic Zero Allocation)
class VisualEffectsHelper {
  VisualEffectsHelper._();

  // Tái sử dụng các Paint cơ bản tránh cấp phát rác trên từng frame (60/120 FPS)
  static final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _strokePaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _particlePaint = Paint()..style = PaintingStyle.fill;
  static final Paint _particleGlowPaint = Paint()
    ..style = PaintingStyle.fill
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

  /// Vẽ quầng sáng nền khí quyển sâu thẳm (Deep Atmospheric Vignette & Glow)
  /// Tạo chiều sâu không gian (Spatial Depth) thay vì nền đen phẳng đơn điệu.
  static void drawAtmosphere(
    Canvas canvas,
    Size size,
    Offset center,
    Color primaryColor,
    Color accentColor, {
    double intensity = 1.0,
    double audioReactiveFactor = 1.0,
  }) {
    if (intensity <= 0.01) return;

    final effectiveIntensity =
        (intensity * (0.88 + 0.12 * audioReactiveFactor)).clamp(0.0, 1.5);
    final maxDim = math.max(size.width, size.height);
    final auraRadius = maxDim * 0.58;

    // 1. Quầng sáng khuếch tán diện rộng (Broad Ambient Aura)
    final auraShader = RadialGradient(
      center: Alignment.center,
      radius: 0.95,
      colors: [
        accentColor.withValues(alpha: 0.07 * effectiveIntensity),
        primaryColor.withValues(alpha: 0.025 * effectiveIntensity),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: auraRadius));

    _fillPaint.shader = auraShader;
    canvas.drawCircle(center, auraRadius, _fillPaint);
    _fillPaint.shader = null;

    // 2. Điểm sáng tiêu cự trung tâm (Core Atmospheric Luminescence)
    final coreRadius = maxDim * 0.24 * (0.95 + 0.05 * audioReactiveFactor);
    final coreShader = RadialGradient(
      center: Alignment.center,
      radius: 0.9,
      colors: [
        primaryColor.withValues(alpha: 0.05 * effectiveIntensity),
        accentColor.withValues(alpha: 0.015 * effectiveIntensity),
        Colors.transparent,
      ],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: coreRadius));

    _fillPaint.shader = coreShader;
    canvas.drawCircle(center, coreRadius, _fillPaint);
    _fillPaint.shader = null;
  }

  /// Vẽ các hạt vi mô trôi nổi hữu cơ (Organic Ambient Stardust Particles)
  /// Tính toán theo trường vector mượt mà phi lặp lại, không tạo rác bộ nhớ (Zero Allocation).
  static void drawAmbientParticles(
    Canvas canvas,
    Size size,
    double time,
    Color color, {
    double intensity = 1.0,
    double audioReactiveFactor = 1.0,
    int count = 26,
  }) {
    if (intensity <= 0.01) return;

    final baseAlpha =
        (0.35 * intensity * (0.85 + 0.15 * audioReactiveFactor)).clamp(0.0, 1.0);

    for (int i = 0; i < count; i++) {
      // Tọa độ gốc phân bố rải đều theo chuỗi tỷ lệ vàng phi lặp lại
      final phi = i * 0.61803398875;
      final seedX = (phi * 7.91) % 1.0;
      final seedY = (phi * 13.37) % 1.0;

      // Vận tốc và chu kỳ dao động vi sai cho từng hạt
      final speedY = 0.015 + ((i % 5) * 0.006);
      final freqX = 0.7 + ((i % 7) * 0.35);
      final phaseX = i * 1.34;

      // Chuyển động trôi dạt liên tục
      final yNorm = (seedY - time * speedY) % 1.0;
      final y = (yNorm < 0 ? yNorm + 1.0 : yNorm) * size.height;

      final sway = math.sin(time * freqX + phaseX) * (14.0 + (i % 4) * 8.0);
      final x = (seedX * size.width + sway) % size.width;

      // Độ sáng phập phồng sinh học đồng bộ nhịp âm
      final breath = (math.sin(time * 1.5 + i * 0.9) + 1.0) / 2.0;
      final particleAlpha =
          ((0.12 + breath * 0.88) * baseAlpha).clamp(0.0, 1.0);

      final radius = 0.8 + ((i % 4) * 0.45);

      _particlePaint.color = color.withValues(alpha: particleAlpha);
      canvas.drawCircle(Offset(x, y), radius, _particlePaint);

      // Thêm quầng sáng mờ cho hạt lớn
      if (radius > 1.4 && particleAlpha > 0.15) {
        _particleGlowPaint.color =
            color.withValues(alpha: (particleAlpha * 0.35).clamp(0.0, 1.0));
        canvas.drawCircle(Offset(x, y), radius * 2.0, _particleGlowPaint);
      }
    }
  }

  /// Vẽ đường cong với hiệu ứng phát sáng đa tầng (Multi-layer Atmospheric Glow)
  /// - Tầng 1: Hào quang khuếch tán xa (Ambient Glow)
  /// - Tầng 2: Lõi sáng sắc nét (Luminous Core Stroke)
  static void drawGlowingPath(
    Canvas canvas,
    Path path, {
    required Color color,
    required double strokeWidth,
    double glowSigma = 5.0,
    double glowAlpha = 0.18,
    double coreAlpha = 0.85,
    double audioReactiveFactor = 1.0,
  }) {
    final effectiveGlowAlpha =
        (glowAlpha * (0.85 + 0.15 * audioReactiveFactor)).clamp(0.0, 1.0);
    final effectiveCoreAlpha =
        (coreAlpha * (0.90 + 0.10 * audioReactiveFactor)).clamp(0.0, 1.0);

    // 1. Lớp hào quang khuếch tán (Ambient Glow)
    if (glowSigma > 0 && effectiveGlowAlpha > 0.005) {
      _strokePaint
        ..color = color.withValues(alpha: effectiveGlowAlpha)
        ..strokeWidth = strokeWidth * 2.2
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSigma)
        ..isAntiAlias = true;
      canvas.drawPath(path, _strokePaint);
      _strokePaint.maskFilter = null;
    }

    // 2. Lõi sáng sắc nét (Sharp Core)
    _strokePaint
      ..color = color.withValues(alpha: effectiveCoreAlpha)
      ..strokeWidth = strokeWidth
      ..maskFilter = null
      ..isAntiAlias = true;
    canvas.drawPath(path, _strokePaint);
  }

  /// Vẽ điểm nút / hạt phát quang với quầng sáng (Glowing Node)
  static void drawGlowingPoint(
    Canvas canvas,
    Offset point,
    double radius, {
    required Color color,
    double glowSigma = 4.0,
    double glowAlpha = 0.25,
    double coreAlpha = 0.9,
    double audioReactiveFactor = 1.0,
  }) {
    final effectiveGlowAlpha =
        (glowAlpha * (0.8 + 0.2 * audioReactiveFactor)).clamp(0.0, 1.0);
    final effectiveCoreAlpha =
        (coreAlpha * (0.88 + 0.12 * audioReactiveFactor)).clamp(0.0, 1.0);
    final effectiveRadius = radius * (0.95 + 0.05 * audioReactiveFactor);

    if (glowSigma > 0 && effectiveGlowAlpha > 0.005) {
      _fillPaint
        ..color = color.withValues(alpha: effectiveGlowAlpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSigma);
      canvas.drawCircle(point, effectiveRadius + glowSigma * 0.7, _fillPaint);
      _fillPaint.maskFilter = null;
    }

    _fillPaint
      ..color = color.withValues(alpha: effectiveCoreAlpha)
      ..maskFilter = null;
    canvas.drawCircle(point, effectiveRadius, _fillPaint);
  }
}
