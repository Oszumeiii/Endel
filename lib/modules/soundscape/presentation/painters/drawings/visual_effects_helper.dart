import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Helper chuyên biệt vẽ hiệu ứng ánh sáng khí quyển (Atmospheric Lighting),
/// dải màu mềm cộng sáng (Soft Fill / Orb) và đường cong mượt chuẩn ngôn ngữ Endel.
///
/// Tối ưu hóa hiệu năng di động:
/// - Tái sử dụng Paint static (tránh cấp phát rác mỗi frame)
/// - Thuật toán tạo hạt xác định theo tỷ lệ vàng
class VisualEffectsHelper {
  VisualEffectsHelper._();

  // Tái sử dụng các Paint cơ bản tránh cấp phát rác trên từng frame (60/120 FPS)
  static final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _strokePaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _particlePaint = Paint()..style = PaintingStyle.fill;
  static final Paint _softPaint = Paint()..style = PaintingStyle.fill;

  /// Tô nền gradient dọc sâu thẳm cho toàn bộ khung vẽ (gọi đầu tiên trong mỗi painter).
  /// Tạo không gian tối có sắc độ nhẹ từ accent -> primary -> đen để các lớp plus nổi khối.
  static void drawBackdrop(
    Canvas canvas,
    Size size,
    Color primary,
    Color accent, {
    double intensity = 1.0,
  }) {
    if (size.isEmpty) return;

    final tAccent = (0.22 * intensity).clamp(0.0, 1.0);
    final tPrimary = (0.10 * intensity).clamp(0.0, 1.0);
    final topColor = Color.lerp(Colors.black, accent, tAccent) ?? Colors.black;
    final midColor = Color.lerp(Colors.black, primary, tPrimary) ?? Colors.black;

    final rect = Offset.zero & size;
    _fillPaint
      ..blendMode = BlendMode.srcOver
      ..maskFilter = null
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, midColor, Colors.black],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, _fillPaint);
    _fillPaint.shader = null;
  }

  /// Tạo đường cong quadratic bezier mượt qua danh sách điểm (an toàn khi pts < 3).
  static Path smoothPath(List<Offset> pts) {
    final path = Path();
    if (pts.isEmpty) return path;

    path.moveTo(pts.first.dx, pts.first.dy);
    if (pts.length == 1) return path;
    if (pts.length == 2) {
      path.lineTo(pts[1].dx, pts[1].dy);
      return path;
    }

    for (int i = 1; i < pts.length - 1; i++) {
      final p0 = pts[i];
      final p1 = pts[i + 1];
      if (i == pts.length - 2) {
        path.quadraticBezierTo(p0.dx, p0.dy, p1.dx, p1.dy);
      } else {
        final midX = (p0.dx + p1.dx) * 0.5;
        final midY = (p0.dy + p1.dy) * 0.5;
        path.quadraticBezierTo(p0.dx, p0.dy, midX, midY);
      }
    }
    return path;
  }

  /// Tạo đường cong khép kín mượt hoàn toàn, không tạo góc nhọn tại điểm nối đầu-cuối.
  static Path smoothClosedPath(List<Offset> pts) {
    if (pts.length < 3) {
      final path = smoothPath(pts);
      if (pts.length == 2) path.close();
      return path;
    }

    final path = Path();
    final startMidX = (pts.last.dx + pts.first.dx) * 0.5;
    final startMidY = (pts.last.dy + pts.first.dy) * 0.5;
    path.moveTo(startMidX, startMidY);

    for (int i = 0; i < pts.length; i++) {
      final curr = pts[i];
      final next = pts[(i + 1) % pts.length];
      final midX = (curr.dx + next.dx) * 0.5;
      final midY = (curr.dy + next.dy) * 0.5;
      path.quadraticBezierTo(curr.dx, curr.dy, midX, midY);
    }

    path.close();
    return path;
  }

  /// Tạo dải kín nối giữa hai đường [a] (xuôi) và [b] (ngược), cả hai cạnh đều dùng bezier mượt.
  static Path ribbonPath(List<Offset> a, List<Offset> b) {
    final path = Path();
    if (a.isEmpty || b.isEmpty) return path;

    // Cạnh trên/xuôi theo thứ tự từ đầu đến cuối danh sách a
    path.moveTo(a.first.dx, a.first.dy);
    if (a.length == 2) {
      path.lineTo(a[1].dx, a[1].dy);
    } else if (a.length >= 3) {
      for (int i = 1; i < a.length - 1; i++) {
        final p0 = a[i];
        final p1 = a[i + 1];
        if (i == a.length - 2) {
          path.quadraticBezierTo(p0.dx, p0.dy, p1.dx, p1.dy);
        } else {
          final midX = (p0.dx + p1.dx) * 0.5;
          final midY = (p0.dy + p1.dy) * 0.5;
          path.quadraticBezierTo(p0.dx, p0.dy, midX, midY);
        }
      }
    }

    // Nối sang điểm cuối của b rồi đi ngược về đầu b
    path.lineTo(b.last.dx, b.last.dy);
    if (b.length == 2) {
      path.lineTo(b.first.dx, b.first.dy);
    } else if (b.length >= 3) {
      for (int i = b.length - 2; i >= 1; i--) {
        final p0 = b[i];
        final p1 = b[i - 1];
        if (i == 1) {
          path.quadraticBezierTo(p0.dx, p0.dy, p1.dx, p1.dy);
        } else {
          final midX = (p0.dx + p1.dx) * 0.5;
          final midY = (p0.dy + p1.dy) * 0.5;
          path.quadraticBezierTo(p0.dx, p0.dy, midX, midY);
        }
      }
    }

    path.close();
    return path;
  }

  /// Tô mềm một [path] bằng LinearGradient 4 điểm dừng (trong suốt -> a -> b -> trong suốt)
  /// kết hợp BlendMode.plus và blur để tạo lớp ánh sáng giao thoa mượt.
  static void drawSoftFill(
    Canvas canvas,
    Path path,
    Rect bounds,
    Color a,
    Color b, {
    double alpha = 0.16,
    double blur = 14,
  }) {
    final effectiveAlpha = alpha.clamp(0.0, 1.0);
    if (effectiveAlpha <= 0.001 || bounds.isEmpty) return;

    _softPaint
      ..blendMode = BlendMode.plus
      ..maskFilter = blur > 0 ? MaskFilter.blur(BlurStyle.normal, blur) : null
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          a.withValues(alpha: 0.0),
          a.withValues(alpha: effectiveAlpha),
          b.withValues(alpha: effectiveAlpha),
          b.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(bounds);

    canvas.drawPath(path, _softPaint);
    _softPaint
      ..shader = null
      ..maskFilter = null
      ..blendMode = BlendMode.srcOver;
  }

  /// Vẽ khối sáng tròn mềm với RadialGradient cộng sáng, không có lõi cứng ở tâm.
  static void drawSoftOrb(
    Canvas canvas,
    Offset center,
    double radius,
    Color color, {
    double alpha = 0.2,
    double blur = 12,
  }) {
    final effectiveAlpha = alpha.clamp(0.0, 1.0);
    if (radius <= 0.0 || effectiveAlpha <= 0.001) return;

    final rect = Rect.fromCircle(center: center, radius: radius);
    _softPaint
      ..blendMode = BlendMode.plus
      ..maskFilter = blur > 0 ? MaskFilter.blur(BlurStyle.normal, blur) : null
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          color.withValues(alpha: effectiveAlpha),
          color.withValues(alpha: (effectiveAlpha * 0.4).clamp(0.0, 1.0)),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(rect);

    canvas.drawCircle(center, radius, _softPaint);
    _softPaint
      ..shader = null
      ..maskFilter = null
      ..blendMode = BlendMode.srcOver;
  }

  /// Vẽ quầng sáng nền khí quyển khuếch tán rộng bằng BlendMode.plus,
  /// không vẽ đốm sáng cứng ở tâm để giữ tối giản không gian.
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

    final auraShader = RadialGradient(
      center: Alignment.center,
      radius: 0.95,
      colors: [
        accentColor.withValues(alpha: (0.20 * effectiveIntensity).clamp(0.0, 1.0)),
        primaryColor.withValues(alpha: (0.08 * effectiveIntensity).clamp(0.0, 1.0)),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: auraRadius));

    _fillPaint
      ..blendMode = BlendMode.plus
      ..maskFilter = null
      ..shader = auraShader;
    canvas.drawCircle(center, auraRadius, _fillPaint);
    _fillPaint
      ..shader = null
      ..blendMode = BlendMode.srcOver;
  }

  /// Vẽ các hạt vi mô trôi nổi hữu cơ với mật độ thưa và độ mờ dịu mắt.
  static void drawAmbientParticles(
    Canvas canvas,
    Size size,
    double time,
    Color color, {
    double intensity = 1.0,
    double audioReactiveFactor = 1.0,
    int count = 10,
  }) {
    if (intensity <= 0.01 || size.isEmpty) return;

    final baseAlpha =
        (0.25 * intensity * (0.85 + 0.15 * audioReactiveFactor)).clamp(0.0, 0.25);

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

      // Độ sáng phập phồng chậm theo nhịp thở
      final breath = (math.sin(time * 1.2 + i * 0.9) + 1.0) * 0.5;
      final particleAlpha =
          ((0.2 + breath * 0.8) * baseAlpha).clamp(0.0, 0.25);

      // Bán kính nhỏ 0.6 - 1.4 để không lấn át khối màu chính
      final radius = 0.6 + ((i % 5) * 0.2);

      _particlePaint
        ..blendMode = BlendMode.plus
        ..color = color.withValues(alpha: particleAlpha);
      canvas.drawCircle(Offset(x, y), radius, _particlePaint);
    }
    _particlePaint.blendMode = BlendMode.srcOver;
  }

  /// Vẽ đường cong với hiệu ứng phát sáng đa tầng.
  @Deprecated('Sử dụng drawSoftFill hoặc drawSoftOrb để thay thế.')
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

    if (glowSigma > 0 && effectiveGlowAlpha > 0.005) {
      _strokePaint
        ..color = color.withValues(alpha: effectiveGlowAlpha)
        ..strokeWidth = strokeWidth * 2.2
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSigma)
        ..isAntiAlias = true;
      canvas.drawPath(path, _strokePaint);
      _strokePaint.maskFilter = null;
    }

    _strokePaint
      ..color = color.withValues(alpha: effectiveCoreAlpha)
      ..strokeWidth = strokeWidth
      ..maskFilter = null
      ..isAntiAlias = true;
    canvas.drawPath(path, _strokePaint);
  }

  /// Vẽ điểm nút phát quang với quầng sáng.
  @Deprecated('Sử dụng drawSoftOrb để thay thế.')
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
