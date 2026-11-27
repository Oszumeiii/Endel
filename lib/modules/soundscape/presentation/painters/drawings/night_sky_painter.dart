import 'dart:math' as math;
import 'dart:ui' show PointMode;
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';
import 'visual_effects_helper.dart';

class _ConstellationDef {
  const _ConstellationDef({
    required this.anchorX,
    required this.anchorY,
    required this.scaleFactor,
    required this.rotation,
    required this.stars,
    required this.edges,
  });

  final double anchorX;
  final double anchorY;
  final double scaleFactor;
  final double rotation;
  final List<Offset> stars;
  final List<int> edges;
}

/// 3. NIGHT SKY: Trời đêm đầy sao, Ngân Hà, 6 chòm sao, hành tinh có vành đai,
/// tinh vân và các tầng sao/mây/sao băng chuyển động đa hướng chậm rãi.
class NightSkyVisualPainter extends VisualPainterStrategy {
  const NightSkyVisualPainter();

  // Hằng số chất lượng và tốc độ (chậm nhất trong 7 theme)
  static const double _kQuality = 1.0;
  static const double _kSkyRotationSpeed = 0.01;
  static const double _kTwinkleSpeed = 0.35;

  static final Paint _milkyWayPaint = Paint()
    ..style = PaintingStyle.fill
    ..blendMode = BlendMode.plus
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25.0)
    ..isAntiAlias = true;

  static final Paint _cloudPaint = Paint()
    ..style = PaintingStyle.fill
    ..blendMode = BlendMode.plus
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18.0)
    ..isAntiAlias = true;

  static final Paint _nebulaPaint = Paint()
    ..style = PaintingStyle.fill
    ..blendMode = BlendMode.plus
    ..isAntiAlias = true;

  static final Paint _starPointsPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..blendMode = BlendMode.plus
    ..isAntiAlias = true;

  static final Paint _linePaint = Paint()
    ..style = PaintingStyle.stroke
    ..blendMode = BlendMode.plus
    ..isAntiAlias = true;

  static final Paint _ringPaint = Paint()
    ..style = PaintingStyle.stroke
    ..blendMode = BlendMode.plus
    ..isAntiAlias = true;

  static final Paint _fillPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  static final Paint _moonGlowPaint = Paint()
    ..style = PaintingStyle.fill
    ..blendMode = BlendMode.plus
    ..isAntiAlias = true;

  static final Paint _meteorPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 1.4
    ..blendMode = BlendMode.plus
    ..isAntiAlias = true;

  // Bộ đệm static cho các nhóm sao theo pha nhấp nháy nhằm gộp drawPoints
  static final List<Offset> _smallBucketA = <Offset>[];
  static final List<Offset> _smallBucketB = <Offset>[];
  static final List<Offset> _medBucketA = <Offset>[];
  static final List<Offset> _medBucketB = <Offset>[];
  static final List<Offset> _milkyDustPts = <Offset>[];

  // 6 chòm sao định sẵn theo tọa độ chuẩn hóa 0..1
  static const List<_ConstellationDef> _constellations = [
    // Cassiopeia (chữ W đặc trưng)
    _ConstellationDef(
      anchorX: 0.22,
      anchorY: 0.20,
      scaleFactor: 0.20,
      rotation: -0.22,
      stars: [
        Offset(0.05, 0.35),
        Offset(0.28, 0.65),
        Offset(0.50, 0.30),
        Offset(0.74, 0.62),
        Offset(0.95, 0.22),
      ],
      edges: [0, 1, 1, 2, 2, 3, 3, 4],
    ),
    // Orion (vai, thắt lưng 3 sao, chân)
    _ConstellationDef(
      anchorX: 0.26,
      anchorY: 0.60,
      scaleFactor: 0.24,
      rotation: 0.14,
      stars: [
        Offset(0.20, 0.12),
        Offset(0.76, 0.16),
        Offset(0.40, 0.48),
        Offset(0.50, 0.45),
        Offset(0.60, 0.42),
        Offset(0.24, 0.86),
        Offset(0.78, 0.82),
      ],
      edges: [0, 1, 0, 2, 1, 4, 2, 3, 3, 4, 2, 5, 4, 6, 5, 6],
    ),
    // Leo (liềm đầu sư tử + thân)
    _ConstellationDef(
      anchorX: 0.74,
      anchorY: 0.56,
      scaleFactor: 0.22,
      rotation: -0.10,
      stars: [
        Offset(0.32, 0.10),
        Offset(0.18, 0.25),
        Offset(0.26, 0.42),
        Offset(0.42, 0.38),
        Offset(0.38, 0.70),
        Offset(0.78, 0.66),
        Offset(0.92, 0.45),
      ],
      edges: [0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 3],
    ),
    // Scorpius (vương miện + đuôi cong)
    _ConstellationDef(
      anchorX: 0.48,
      anchorY: 0.82,
      scaleFactor: 0.20,
      rotation: 0.18,
      stars: [
        Offset(0.16, 0.18),
        Offset(0.28, 0.30),
        Offset(0.18, 0.44),
        Offset(0.46, 0.38),
        Offset(0.64, 0.55),
        Offset(0.76, 0.76),
        Offset(0.88, 0.66),
      ],
      edges: [0, 1, 1, 2, 1, 3, 3, 4, 4, 5, 5, 6],
    ),
    // Ursa Major / Big Dipper (gáo múc Bắc Đẩu)
    _ConstellationDef(
      anchorX: 0.48,
      anchorY: 0.34,
      scaleFactor: 0.22,
      rotation: 0.08,
      stars: [
        Offset(0.08, 0.38),
        Offset(0.26, 0.28),
        Offset(0.44, 0.34),
        Offset(0.58, 0.46),
        Offset(0.56, 0.72),
        Offset(0.84, 0.76),
        Offset(0.88, 0.48),
      ],
      edges: [0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 3],
    ),
    // Cygnus / Northern Cross (chữ thập phương Bắc)
    _ConstellationDef(
      anchorX: 0.80,
      anchorY: 0.78,
      scaleFactor: 0.19,
      rotation: -0.32,
      stars: [
        Offset(0.50, 0.10),
        Offset(0.50, 0.42),
        Offset(0.50, 0.86),
        Offset(0.16, 0.36),
        Offset(0.84, 0.48),
      ],
      edges: [0, 1, 1, 2, 3, 1, 1, 4],
    ),
  ];

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

    final playScale = isPlaying ? 1.0 : 0.4;
    final activityMod = 0.75 + 0.25 * activityFactor.clamp(0.0, 1.5);
    final audioMod = 0.97 + 0.03 * audioReactiveFactor.clamp(0.0, 2.0);

    // 1. Nền đêm sâu thẳm xanh thẫm -> đen
    final nightPrimary =
        Color.lerp(const Color(0xFF0A1428), config.primaryColor, 0.35) ??
        config.primaryColor;
    final nightAccent =
        Color.lerp(const Color(0xFF0B1936), config.accentColor, 0.45) ??
        config.accentColor;

    VisualEffectsHelper.drawBackdrop(
      canvas,
      size,
      nightPrimary,
      nightAccent,
      intensity: 0.9 * activityMod,
    );

    // 2. Khí quyển nhẹ lệch về phía trăng
    final moonBasePos = Offset(size.width * 0.72, size.height * 0.22);
    VisualEffectsHelper.drawAtmosphere(
      canvas,
      size,
      moonBasePos,
      config.primaryColor,
      nightAccent,
      intensity: 0.45 * activityMod,
      audioReactiveFactor: audioReactiveFactor,
    );

    // 3. Các đám tinh vân mềm trôi theo nhiều hướng khác nhau (không dùng blur)
    _drawDriftingNebulae(canvas, size, minDim, time, playScale, config, activityMod);

    // 4. Quay bầu trời rất chậm quanh cực ngoài khung
    final pole = Offset(size.width * 0.75, size.height * 1.1);
    final skyAngle = time * _kSkyRotationSpeed;

    canvas.save();
    canvas.translate(pole.dx, pole.dy);
    canvas.rotate(skyAngle);
    canvas.translate(-pole.dx, -pole.dy);

    // 4a. Dải Ngân Hà chéo mờ (1 MaskFilter.blur) + dải hạt bụi mịn
    _drawMilkyWay(canvas, size, minDim, time, playScale, config, activityMod);

    // 4b. Trường sao nền 3 cấp có thị sai trôi đa hướng
    _drawStarField(canvas, size, time, playScale, config, activityMod, audioMod);

    canvas.restore();

    // 4c. 6 chòm sao nối vạch, mỗi chòm trôi đa hướng và xoay tuần hoàn độc lập trong khung hình
    _drawConstellations(
      canvas,
      size,
      minDim,
      time,
      playScale,
      config,
      activityMod,
    );

    // 5. Hành tinh có vành đai ở vùng trời trái (đối trọng với mặt trăng)
    _drawRingedPlanet(canvas, size, minDim, time, playScale, config, activityMod);

    // 6. Hạt bụi sáng trôi lên/chéo đa hướng nhẹ nhàng
    _drawFloatingMotes(canvas, size, minDim, time, playScale, config, activityMod);

    // 7. Trăng khuyết, quầng sáng và mây mỏng trôi đa hướng
    _drawMoonAndClouds(
      canvas,
      size,
      minDim,
      time,
      playScale,
      config,
      activityMod,
      audioMod,
    );

    // 8. Sao băng từ nhiều hướng khác nhau (~16s một lần, tồn tại ~1.2s)
    _drawMeteor(canvas, size, minDim, time, config, activityMod);
  }

  void _drawDriftingNebulae(
    Canvas canvas,
    Size size,
    double minDim,
    double time,
    double playScale,
    VisualThemeConfig config,
    double activityMod,
  ) {
    // 3 vùng tinh vân trôi chậm theo các hướng khác nhau (chéo, ngang, dọc)
    const anchors = [
      Offset(0.24, 0.38),
      Offset(0.68, 0.72),
      Offset(0.42, 0.16),
    ];
    const dirAngles = [0.6, -2.3, 1.9];

    for (int i = 0; i < anchors.length; i++) {
      final speed = (0.08 + i * 0.03) * playScale;
      final driftR = minDim * 0.045;
      final angle = dirAngles[i] + time * speed * 0.4;
      final cx = size.width * anchors[i].dx + math.cos(angle) * driftR;
      final cy = size.height * anchors[i].dy + math.sin(angle * 0.8) * driftR;
      final rx = minDim * (0.34 + i * 0.06);
      final ry = rx * (0.58 + 0.12 * math.sin(time * 0.12 + i));

      final color = i.isEven ? config.accentColor : config.primaryColor;
      final alpha = (0.065 * activityMod).clamp(0.0, 0.09);

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(-0.4 + i * 0.55 + math.sin(time * 0.05 + i) * 0.06);
      final rect = Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2);
      _nebulaPaint.shader = RadialGradient(
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: (alpha * 0.35).clamp(0.0, 0.05)),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);
      canvas.drawOval(rect, _nebulaPaint);
      _nebulaPaint.shader = null;
      canvas.restore();
    }
  }

  void _drawMilkyWay(
    Canvas canvas,
    Size size,
    double minDim,
    double time,
    double playScale,
    VisualThemeConfig config,
    double activityMod,
  ) {
    final mwAlpha =
        ((0.075 + 0.015 * math.sin(time * 0.2)) * activityMod).clamp(0.0, 0.10);
    final swayAngle = -0.55 + math.sin(time * 0.04) * 0.03 * playScale;
    final mwRect = Rect.fromCenter(
      center: Offset(size.width * 0.45, size.height * 0.48),
      width: size.width * 1.45,
      height: minDim * 0.34,
    );

    canvas.save();
    canvas.translate(mwRect.center.dx, mwRect.center.dy);
    canvas.rotate(swayAngle);
    canvas.translate(-mwRect.center.dx, -mwRect.center.dy);

    _milkyWayPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        config.accentColor.withValues(alpha: mwAlpha * 0.7),
        config.primaryColor.withValues(alpha: mwAlpha),
        config.accentColor.withValues(alpha: mwAlpha * 0.6),
        Colors.transparent,
      ],
      stops: const [0.0, 0.28, 0.5, 0.72, 1.0],
    ).createShader(mwRect);

    canvas.drawOval(mwRect, _milkyWayPaint);
    _milkyWayPaint.shader = null;

    // Bụi sao mịn dọc theo dải Ngân Hà
    _milkyDustPts.clear();
    final dustCount = (90 * _kQuality).round();
    for (int i = 0; i < dustCount; i++) {
      final u = (_hash(i, 101) + time * 0.002 * playScale) % 1.0;
      final v = (_hash(i, 102) + _hash(i, 103)) * 0.5 - 0.5;
      final dx = mwRect.left + u * mwRect.width;
      final dy = mwRect.center.dy + v * mwRect.height * 0.75;
      _milkyDustPts.add(Offset(dx, dy));
    }
    _starPointsPaint
      ..color = config.primaryColor.withValues(alpha: (0.18 * activityMod).clamp(0.0, 0.25))
      ..strokeWidth = 1.0;
    canvas.drawPoints(PointMode.points, _milkyDustPts, _starPointsPaint);

    canvas.restore();
  }

  void _drawStarField(
    Canvas canvas,
    Size size,
    double time,
    double playScale,
    VisualThemeConfig config,
    double activityMod,
    double audioMod,
  ) {
    final totalStars = (175 * _kQuality).round().clamp(90, 200);
    final padX = size.width * 0.34;
    final padY = size.height * 0.34;
    final spanW = size.width + padX * 2;
    final spanH = size.height + padY * 2;

    _smallBucketA.clear();
    _smallBucketB.clear();
    _medBucketA.clear();
    _medBucketB.clear();

    final starWhite =
        Color.lerp(Colors.white, config.primaryColor, 0.35) ?? Colors.white;
    final starCool =
        Color.lerp(Colors.white, config.accentColor, 0.40) ?? Colors.white;

    final twinkleT = time * _kTwinkleSpeed * playScale;

    for (int i = 0; i < totalStars; i++) {
      // Thị sai trôi nhẹ theo hướng riêng của từng tầng sao
      final tierRoll = _hash(i, 13);
      final driftAngle = _hash(i, 19) * math.pi * 2.0;
      final driftSpeed = (tierRoll < 0.72 ? 0.0012 : 0.0024) * playScale;
      final uX = (_hash(i, 11) + time * driftSpeed * math.cos(driftAngle)) % 1.0;
      final uY = (_hash(i, 12) + time * driftSpeed * math.sin(driftAngle)) % 1.0;

      final x = -padX + (uX < 0 ? uX + 1.0 : uX) * spanW;
      final y = -padY + (uY < 0 ? uY + 1.0 : uY) * spanH;
      final pos = Offset(x, y);

      final freq = 0.6 + _hash(i, 14) * 1.4;
      final phase = _hash(i, 15) * math.pi * 2.0;
      final twinkle = math.sin(twinkleT * freq + phase);

      if (tierRoll < 0.72) {
        if (twinkle >= 0) {
          _smallBucketA.add(pos);
        } else {
          _smallBucketB.add(pos);
        }
      } else if (tierRoll < 0.93) {
        if (twinkle >= 0) {
          _medBucketA.add(pos);
        } else {
          _medBucketB.add(pos);
        }
      } else {
        final baseAlpha = (0.55 + 0.25 * _hash(i, 16)) * activityMod * audioMod;
        final alpha = (baseAlpha * (0.85 + 0.15 * twinkle)).clamp(0.0, 0.9);
        final r = 0.8 + _hash(i, 17) * 0.4;
        final starColor = i.isEven ? starWhite : starCool;

        _fillPaint
          ..blendMode = BlendMode.plus
          ..color = starColor.withValues(alpha: alpha);
        canvas.drawCircle(pos, r, _fillPaint);

        final rayLen = 4.0 + _hash(i, 18) * 4.0;
        final rayAlpha = (alpha * 0.32).clamp(0.0, 0.30);
        _linePaint
          ..color = starColor.withValues(alpha: rayAlpha)
          ..strokeWidth = 0.6;
        canvas.drawLine(
          Offset(x - rayLen, y),
          Offset(x + rayLen, y),
          _linePaint,
        );
        canvas.drawLine(
          Offset(x, y - rayLen),
          Offset(x, y + rayLen),
          _linePaint,
        );
      }
    }

    final smallBase = 0.36 * activityMod * audioMod;
    if (_smallBucketA.isNotEmpty) {
      _starPointsPaint
        ..color = starWhite.withValues(alpha: (smallBase * 1.25).clamp(0.0, 0.75))
        ..strokeWidth = 1.3;
      canvas.drawPoints(PointMode.points, _smallBucketA, _starPointsPaint);
    }
    if (_smallBucketB.isNotEmpty) {
      _starPointsPaint
        ..color = starCool.withValues(alpha: (smallBase * 0.72).clamp(0.0, 0.55))
        ..strokeWidth = 1.1;
      canvas.drawPoints(PointMode.points, _smallBucketB, _starPointsPaint);
    }

    final medBase = 0.56 * activityMod * audioMod;
    if (_medBucketA.isNotEmpty) {
      _starPointsPaint
        ..color = starWhite.withValues(alpha: (medBase * 1.25).clamp(0.0, 0.85))
        ..strokeWidth = 2.1;
      canvas.drawPoints(PointMode.points, _medBucketA, _starPointsPaint);
    }
    if (_medBucketB.isNotEmpty) {
      _starPointsPaint
        ..color = starCool.withValues(alpha: (medBase * 0.75).clamp(0.0, 0.65))
        ..strokeWidth = 1.8;
      canvas.drawPoints(PointMode.points, _medBucketB, _starPointsPaint);
    }
  }

  void _drawConstellations(
    Canvas canvas,
    Size size,
    double minDim,
    double time,
    double playScale,
    VisualThemeConfig config,
    double activityMod,
  ) {
    const highlightPeriod = 14.0;
    final cyclePos = time / highlightPeriod;
    final activeIdx = cyclePos.floor() % _constellations.length;
    final cycleFrac = cyclePos - cyclePos.floor();
    final activeWave = math.sin(cycleFrac * math.pi);

    for (int c = 0; c < _constellations.length; c++) {
      final def = _constellations[c];
      final scale = minDim * def.scaleFactor;

      // Mỗi chòm trôi đa hướng, ngẫu nhiên và tuần hoàn (Lissajous 2 tần số)
      // giữ tâm dao động gọn trong khung hình để không bị trôi mất.
      final margin = scale * 0.55;
      final minX = margin;
      final maxX = math.max(margin, size.width - margin);
      final minY = margin;
      final maxY = math.max(margin, size.height - margin);

      final baseX = (size.width * def.anchorX * 0.78 + size.width * 0.5 * 0.22)
          .clamp(minX, maxX);
      final baseY = (size.height * def.anchorY * 0.78 + size.height * 0.5 * 0.22)
          .clamp(minY, maxY);

      final maxAmpX = math.min(
        size.width * (0.12 + _hash(c, 55) * 0.08),
        math.min(baseX - minX, maxX - baseX),
      );
      final maxAmpY = math.min(
        size.height * (0.12 + _hash(c, 56) * 0.08),
        math.min(baseY - minY, maxY - baseY),
      );

      final fx1 = 0.09 + _hash(c, 51) * 0.08;
      final fy1 = 0.08 + _hash(c, 52) * 0.08;
      final fx2 = fx1 * (1.6 + _hash(c, 57) * 0.7);
      final fy2 = fy1 * (1.5 + _hash(c, 58) * 0.7);
      final px1 = _hash(c, 53) * math.pi * 2.0;
      final py1 = _hash(c, 54) * math.pi * 2.0;
      final px2 = _hash(c, 59) * math.pi * 2.0;
      final py2 = _hash(c, 60) * math.pi * 2.0;

      final waveX =
          (0.68 * math.sin(time * fx1 + px1) + 0.32 * math.cos(time * fx2 + px2)) *
              playScale;
      final waveY =
          (0.68 * math.cos(time * fy1 + py1) + 0.32 * math.sin(time * fy2 + py2)) *
              playScale;

      final driftX = waveX * maxAmpX;
      final driftY = waveY * maxAmpY;

      final origin = Offset(
        baseX - scale * 0.5 + driftX,
        baseY - scale * 0.5 + driftY,
      );

      // Xoay tuần hoàn độc lập (chiều và tốc độ khác nhau cho mỗi chòm sao)
      final rotDir = _hash(c, 61) < 0.5 ? 1.0 : -1.0;
      final rotSpeed = (0.06 + _hash(c, 62) * 0.08) * rotDir * playScale;
      final rotWobble = math.sin(time * 0.17 + c * 1.9) * 0.22 * playScale;
      final rot = def.rotation + time * rotSpeed + rotWobble;
      final cosR = math.cos(rot);
      final sinR = math.sin(rot);

      final breath = 0.5 + 0.5 * math.sin(time * 0.45 + c * 1.7);
      final highlightBoost = (c == activeIdx) ? activeWave * 0.16 : 0.0;
      final lineAlpha =
          ((0.20 + 0.12 * breath + highlightBoost) * activityMod).clamp(0.0, 0.42);

      _linePaint
        ..color = config.primaryColor.withValues(alpha: lineAlpha)
        ..strokeWidth = 0.85;

      for (int e = 0; e < def.edges.length; e += 2) {
        final p1 = _transformStar(def.stars[def.edges[e]], origin, scale, cosR, sinR);
        final p2 = _transformStar(
          def.stars[def.edges[e + 1]],
          origin,
          scale,
          cosR,
          sinR,
        );
        canvas.drawLine(p1, p2, _linePaint);
      }

      final orbAlpha =
          ((0.36 + 0.14 * breath + highlightBoost) * activityMod).clamp(0.0, 0.65);
      for (int s = 0; s < def.stars.length; s++) {
        final pt = _transformStar(def.stars[s], origin, scale, cosR, sinR);
        VisualEffectsHelper.drawSoftOrb(
          canvas,
          pt,
          4.5 + (s % 2) * 1.5,
          config.primaryColor,
          alpha: orbAlpha,
          blur: 0,
        );
      }
    }
  }

  Offset _transformStar(
    Offset normPt,
    Offset origin,
    double scale,
    double cosR,
    double sinR,
  ) {
    final dx = (normPt.dx - 0.5) * scale;
    final dy = (normPt.dy - 0.5) * scale;
    return Offset(
      origin.dx + scale * 0.5 + dx * cosR - dy * sinR,
      origin.dy + scale * 0.5 + dx * sinR + dy * cosR,
    );
  }

  void _drawRingedPlanet(
    Canvas canvas,
    Size size,
    double minDim,
    double time,
    double playScale,
    VisualThemeConfig config,
    double activityMod,
  ) {
    // Hành tinh nhỏ ở góc trên-trái, trôi chậm theo quỹ đạo elip
    final orbitX = math.cos(time * 0.09) * minDim * 0.018 * playScale;
    final orbitY = math.sin(time * 0.07) * minDim * 0.012 * playScale;
    final planetCenter = Offset(
      size.width * 0.16 + orbitX,
      size.height * 0.36 + orbitY,
    );
    final planetR = minDim * 0.022;

    // Quầng mềm quanh hành tinh
    VisualEffectsHelper.drawSoftOrb(
      canvas,
      planetCenter,
      planetR * 2.8,
      config.accentColor,
      alpha: (0.14 * activityMod).clamp(0.0, 0.22),
      blur: 0,
    );

    // Thân hành tinh chuyển sắc nhẹ
    final bodyColor =
        Color.lerp(config.primaryColor, config.accentColor, 0.45) ??
        config.primaryColor;
    _fillPaint
      ..blendMode = BlendMode.srcOver
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        colors: [
          config.primaryColor.withValues(alpha: 0.72 * activityMod),
          bodyColor.withValues(alpha: 0.35 * activityMod),
          Colors.black.withValues(alpha: 0.65),
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: planetCenter, radius: planetR));
    canvas.drawCircle(planetCenter, planetR, _fillPaint);
    _fillPaint.shader = null;

    // Vành đai nghiêng xoay rất chậm
    final ringTilt = -0.38 + math.sin(time * 0.06) * 0.05 * playScale;
    canvas.save();
    canvas.translate(planetCenter.dx, planetCenter.dy);
    canvas.rotate(ringTilt);
    _ringPaint
      ..color = config.primaryColor.withValues(alpha: (0.34 * activityMod).clamp(0.0, 0.45))
      ..strokeWidth = 1.0;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: planetR * 4.4,
        height: planetR * 1.15,
      ),
      _ringPaint,
    );
    canvas.restore();
  }

  void _drawFloatingMotes(
    Canvas canvas,
    Size size,
    double minDim,
    double time,
    double playScale,
    VisualThemeConfig config,
    double activityMod,
  ) {
    // 14 hạt bụi ánh sáng trôi chậm theo nhiều hướng (chéo lên, ngang, xoáy nhẹ)
    const moteCount = 14;
    for (int i = 0; i < moteCount; i++) {
      final angle = _hash(i, 61) * math.pi * 2.0;
      final speed = (0.008 + _hash(i, 62) * 0.010) * playScale;
      final uX = (_hash(i, 63) + time * speed * math.cos(angle)) % 1.0;
      final uY = (_hash(i, 64) + time * speed * math.sin(angle)) % 1.0;

      final x = (uX < 0 ? uX + 1.0 : uX) * size.width;
      final y = (uY < 0 ? uY + 1.0 : uY) * size.height;
      final sway = math.sin(time * 0.4 + i * 1.7) * minDim * 0.015;
      final pos = Offset(x + sway, y);

      final pulse = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(time * 0.55 + i * 2.1));
      final alpha = (0.14 * pulse * activityMod).clamp(0.0, 0.22);
      VisualEffectsHelper.drawSoftOrb(
        canvas,
        pos,
        3.5 + _hash(i, 65) * 3.0,
        i.isEven ? config.primaryColor : config.accentColor,
        alpha: alpha,
        blur: 0,
      );
    }
  }

  void _drawMoonAndClouds(
    Canvas canvas,
    Size size,
    double minDim,
    double time,
    double playScale,
    VisualThemeConfig config,
    double activityMod,
    double audioMod,
  ) {
    final driftX = math.cos(time * 0.14) * size.width * 0.006 * playScale;
    final driftY = math.sin(time * 0.18) * size.height * 0.01 * playScale;
    final moonCenter = Offset(
      size.width * 0.72 + driftX,
      size.height * 0.22 + driftY,
    );
    final moonRadius = minDim * 0.09 * audioMod;

    // Quầng sáng rộng bằng RadialGradient, không blur thêm
    final glowRadius = moonRadius * 3.5;
    final glowAlpha = (0.16 * activityMod).clamp(0.0, 0.18);
    _moonGlowPaint.shader = RadialGradient(
      colors: [
        config.primaryColor.withValues(alpha: glowAlpha),
        config.accentColor.withValues(alpha: (glowAlpha * 0.4).clamp(0.0, 0.18)),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45, 1.0],
    ).createShader(Rect.fromCircle(center: moonCenter, radius: glowRadius));
    canvas.drawCircle(moonCenter, glowRadius, _moonGlowPaint);
    _moonGlowPaint.shader = null;

    // Vòng hào quang mảnh mờ quanh trăng
    _ringPaint
      ..color = config.primaryColor.withValues(alpha: (0.06 * activityMod).clamp(0.0, 0.1))
      ..strokeWidth = 0.8;
    canvas.drawCircle(moonCenter, moonRadius * 1.85, _ringPaint);

    // Dựng trăng khuyết bằng hiệu hai hình tròn
    final outerCircle = Path()
      ..addOval(Rect.fromCircle(center: moonCenter, radius: moonRadius));
    final cutoutCenter = Offset(
      moonCenter.dx - moonRadius * 0.42,
      moonCenter.dy - moonRadius * 0.22,
    );
    final innerCircle = Path()
      ..addOval(Rect.fromCircle(center: cutoutCenter, radius: moonRadius * 0.92));
    final crescent = Path.combine(
      PathOperation.difference,
      outerCircle,
      innerCircle,
    );

    final moonIvory =
        Color.lerp(const Color(0xFFFFFBF0), config.primaryColor, 0.22) ??
        const Color(0xFFFFFBF0);
    final moonEdge =
        Color.lerp(moonIvory, config.primaryColor, 0.45) ?? config.primaryColor;

    _fillPaint
      ..blendMode = BlendMode.srcOver
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          moonIvory.withValues(alpha: 0.92),
          moonEdge.withValues(alpha: 0.75),
        ],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: moonRadius));
    canvas.drawPath(crescent, _fillPaint);
    _fillPaint.shader = null;

    // 4 vệt mây mỏng mờ trôi theo nhiều hướng khác nhau (1 MaskFilter.blur)
    final cloudAlpha = (0.045 * activityMod).clamp(0.0, 0.05);
    _cloudPaint.color = config.primaryColor.withValues(alpha: cloudAlpha);
    for (int i = 0; i < 4; i++) {
      final dir = i.isEven ? 1.0 : -1.0;
      final speed = (0.006 + i * 0.0025) * dir;
      final rawX = (0.20 + i * 0.22 + time * speed * playScale) % 1.4;
      final cxNorm = (rawX < 0 ? rawX + 1.4 : rawX) - 0.2;
      final cx = cxNorm * size.width;
      final cy = moonCenter.dy +
          (i - 1.5) * moonRadius * 0.55 +
          math.sin(time * 0.16 + i * 1.4) * minDim * 0.012 * playScale;
      final w = minDim * (0.36 + (i % 3) * 0.12);
      final h = minDim * (0.038 + (i % 2) * 0.012);

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate((i.isEven ? 0.08 : -0.10));
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        _cloudPaint,
      );
      canvas.restore();
    }
  }

  void _drawMeteor(
    Canvas canvas,
    Size size,
    double minDim,
    double time,
    VisualThemeConfig config,
    double activityMod,
  ) {
    const period = 16.0;
    const duration = 1.2;
    final cycleTime = time % period;
    if (cycleTime > duration) return;

    final cycleIdx = (time / period).floor();
    final progress = (cycleTime / duration).clamp(0.0, 1.0);

    // Đảo chiều sao băng xen kẽ (trái->phải và phải->trái)
    final goLeft = cycleIdx.isOdd;
    final startX = goLeft
        ? size.width * (0.55 + _hash(cycleIdx, 41) * 0.35)
        : size.width * (0.12 + _hash(cycleIdx, 41) * 0.45);
    final startY = size.height * (0.06 + _hash(cycleIdx, 42) * 0.30);
    final baseAngle = 0.38 + _hash(cycleIdx, 43) * 0.38;
    final angle = goLeft ? (math.pi - baseAngle) : baseAngle;

    final travel = minDim * 0.32 * progress;
    final streakLen = minDim * 0.15;
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);

    final head = Offset(startX + cosA * travel, startY + sinA * travel);
    final tail = Offset(
      head.dx - cosA * streakLen * (0.5 + 0.5 * progress),
      head.dy - sinA * streakLen * (0.5 + 0.5 * progress),
    );

    final fade = math.sin(progress * math.pi);
    final alpha = (0.55 * fade * activityMod).clamp(0.0, 0.75);
    if (alpha <= 0.01) return;

    _meteorPaint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.transparent,
        config.primaryColor.withValues(alpha: alpha),
      ],
    ).createShader(Rect.fromPoints(tail, head));

    canvas.drawLine(tail, head, _meteorPaint);
    _meteorPaint.shader = null;
  }
}
