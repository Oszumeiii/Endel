import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show PointMode;
import 'package:flutter/material.dart';
import '../../../domain/entities/visual_theme_config.dart';
import '../visual_painter_strategy.dart';
import 'visual_effects_helper.dart';

/// 2. CONSTELLATION: Bầu trời các chấm nối với nhau như đồ thị trôi chậm, tự nối và ngắt.
class ConstellationVisualPainter extends VisualPainterStrategy {
  const ConstellationVisualPainter();

  // Hằng số chất lượng tổng thể (giảm < 1.0 trên thiết bị yếu để giảm số nút/cạnh O(n²))
  static const double _kQuality = 1.0;
  static const double _kSpeedScale = 0.5;
  static const int _kMaxNodes = 64;
  static const int _kMaxEdges = 160;
  static const int _kMaxPulses = 5;

  static final Paint _edgePaint = Paint()
    ..style = PaintingStyle.stroke
    ..blendMode = BlendMode.plus
    ..isAntiAlias = true;

  static final Paint _pulsePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..blendMode = BlendMode.plus
    ..isAntiAlias = true;

  static final Paint _pointPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..blendMode = BlendMode.plus
    ..isAntiAlias = true;

  // Bộ đệm static tránh cấp phát List/Offset trong mỗi frame
  static final Float64List _nodeX = Float64List(_kMaxNodes);
  static final Float64List _nodeY = Float64List(_kMaxNodes);
  static final Float64List _nodeFade = Float64List(_kMaxNodes);
  static final Float64List _nodeSize = Float64List(_kMaxNodes);
  static final Uint8List _isHub = Uint8List(_kMaxNodes);

  static final Int32List _edgeA = Int32List(_kMaxEdges);
  static final Int32List _edgeB = Int32List(_kMaxEdges);
  static final Float64List _edgeD = Float64List(_kMaxEdges);

  static final List<Offset> _ptsSmall = <Offset>[];
  static final List<Offset> _ptsMedium = <Offset>[];
  static final List<Offset> _ptsLarge = <Offset>[];

  /// Hàm băm xác định theo chỉ số, trả về giá trị trong [0, 1)
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

    final minDim = math.min(size.width, size.height);
    if (minDim <= 0) return;

    final t = time * _kSpeedScale;
    final playScale = isPlaying ? 1.0 : 0.35;
    final audioMod = 0.96 + 0.04 * audioReactiveFactor.clamp(0.0, 2.0);
    final activityMod = 0.72 + 0.28 * activityFactor.clamp(0.0, 1.5);
    final deform = config.deformationIntensity.clamp(0.5, 1.6);

    final rawCount = 34 + config.layerCount.clamp(1, 6) * 4;
    final nodeCount = (rawCount * _kQuality).round().clamp(16, _kMaxNodes);

    // Chia lưới nhiễu (jittered grid) theo tỉ lệ khung hình để nút trải đều, tránh chụm
    final aspect = size.width / size.height;
    final cols = math.max(2, math.sqrt(nodeCount * aspect).round());
    final rows = math.max(2, (nodeCount / cols).ceil());
    final cellW = size.width / cols;
    final cellH = size.height / rows;
    final edgeMargin = minDim * 0.08;

    _ptsSmall.clear();
    _ptsMedium.clear();
    _ptsLarge.clear();

    // Số lượng hub (6-8 nút nổi bật) phân bố đều theo bước nhảy
    final hubCount = math.min(7, (nodeCount * 0.14).round().clamp(4, 8));
    final hubStep = math.max(1, nodeCount ~/ hubCount);

    // 2. Tính vị trí từng nút theo quỹ đạo Lissajous chậm quanh điểm neo
    for (int i = 0; i < nodeCount; i++) {
      final col = i % cols;
      final row = (i ~/ cols) % rows;

      final jx = 0.15 + 0.70 * _hash(i, 1);
      final jy = 0.15 + 0.70 * _hash(i, 2);
      final anchorX = (col + jx) * cellW;
      final anchorY = (row + jy) * cellH;

      final amp = minDim * (0.06 + 0.08 * _hash(i, 3)) * deform * playScale;
      final fx = 0.04 + 0.08 * _hash(i, 4);
      final fy = 0.04 + 0.08 * _hash(i, 5);
      final px = _hash(i, 6) * math.pi * 2.0;
      final py = _hash(i, 7) * math.pi * 2.0;

      final x = anchorX + amp * math.sin(t * fx + px);
      final y = anchorY + amp * math.cos(t * fy + py);

      _nodeX[i] = x;
      _nodeY[i] = y;

      // Fade mềm khi nút trôi sát rìa khung
      final distEdge = math.min(
        math.min(x, size.width - x),
        math.min(y, size.height - y),
      );
      _nodeFade[i] = (distEdge / edgeMargin).clamp(0.0, 1.0);

      final isHubNode = (i % hubStep == 0) && (i ~/ hubStep < hubCount);
      _isHub[i] = isHubNode ? 1 : 0;
      _nodeSize[i] = isHubNode
          ? 4.0 + _hash(i, 8) * 1.0
          : 1.2 + _hash(i, 8) * 2.4;
    }

    // 3. Tìm tối đa _kMaxEdges cạnh ngắn nhất trong phạm vi linkDist
    final linkDist = minDim * 0.26;
    final linkDistSq = linkDist * linkDist;
    int edgeCount = 0;
    int maxEdgeIdx = 0;
    double maxEdgeDistSq = 0.0;

    for (int i = 0; i < nodeCount; i++) {
      if (_nodeFade[i] <= 0.01) continue;
      final xi = _nodeX[i];
      final yi = _nodeY[i];

      for (int j = i + 1; j < nodeCount; j++) {
        if (_nodeFade[j] <= 0.01) continue;
        final dx = xi - _nodeX[j];
        final dy = yi - _nodeY[j];
        final dSq = dx * dx + dy * dy;
        if (dSq >= linkDistSq) continue;

        if (edgeCount < _kMaxEdges) {
          _edgeA[edgeCount] = i;
          _edgeB[edgeCount] = j;
          _edgeD[edgeCount] = dSq;
          if (dSq > maxEdgeDistSq) {
            maxEdgeDistSq = dSq;
            maxEdgeIdx = edgeCount;
          }
          edgeCount++;
        } else if (dSq < maxEdgeDistSq) {
          // Thay thế cạnh dài nhất để giữ các liên kết gần và rõ nét nhất
          _edgeA[maxEdgeIdx] = i;
          _edgeB[maxEdgeIdx] = j;
          _edgeD[maxEdgeIdx] = dSq;
          maxEdgeDistSq = 0.0;
          for (int k = 0; k < _kMaxEdges; k++) {
            if (_edgeD[k] > maxEdgeDistSq) {
              maxEdgeDistSq = _edgeD[k];
              maxEdgeIdx = k;
            }
          }
        }
      }
    }

    // 4. Vẽ các cạnh nối (alpha thay đổi mượt theo khoảng cách, không nhấp nháy)
    for (int e = 0; e < edgeCount; e++) {
      final a = _edgeA[e];
      final b = _edgeB[e];
      final dist = math.sqrt(_edgeD[e]);
      final normD = (dist / linkDist).clamp(0.0, 1.0);
      final proximity = 1.0 - normD;
      final edgeFade = math.min(_nodeFade[a], _nodeFade[b]);
      final hubBoost = (_isHub[a] == 1 || _isHub[b] == 1) ? 1.25 : 1.0;

      final alpha = (math.pow(proximity, 1.5) *
              0.45 *
              hubBoost *
              edgeFade *
              activityMod *
              audioMod)
          .clamp(0.0, 1.0);
      if (alpha <= 0.005) continue;

      final edgeColor =
          Color.lerp(config.primaryColor, config.accentColor, normD) ??
          config.primaryColor;

      _edgePaint
        ..color = edgeColor.withValues(alpha: alpha)
        ..strokeWidth = 0.7 + 0.3 * proximity;
      canvas.drawLine(
        Offset(_nodeX[a], _nodeY[a]),
        Offset(_nodeX[b], _nodeY[b]),
        _edgePaint,
      );
    }

    // 5. Vẽ tối đa 5 xung ánh sáng chậm trượt dọc cạnh (chu kỳ 6-9s xác định)
    if (edgeCount > 0) {
      final pulseLimit = math.min(_kMaxPulses, edgeCount);
      for (int p = 0; p < pulseLimit; p++) {
        final period = 6.0 + _hash(p, 21) * 3.0;
        final rawCycle = (time + p * 1.7) / period;
        final cycleIndex = rawCycle.floor();
        final progress = rawCycle - cycleIndex;

        final eIdx =
            ((_hash(cycleIndex, 31 + p) * edgeCount).floor()) % edgeCount;
        final a = _edgeA[eIdx];
        final b = _edgeB[eIdx];
        final edgeFade = math.min(_nodeFade[a], _nodeFade[b]);
        if (edgeFade <= 0.05) continue;

        final ax = _nodeX[a];
        final ay = _nodeY[a];
        final bx = _nodeX[b];
        final by = _nodeY[b];

        // Đoạn xung dài 18% chiều dài cạnh, mờ ở hai đầu chu kỳ
        final head = progress;
        final tail = math.max(0.0, progress - 0.18);
        final env = math.sin(progress * math.pi);
        final pulseAlpha = (0.34 * env * edgeFade * activityMod).clamp(0.0, 1.0);
        if (pulseAlpha <= 0.01) continue;

        final pStart = Offset(ax + (bx - ax) * tail, ay + (by - ay) * tail);
        final pEnd = Offset(ax + (bx - ax) * head, ay + (by - ay) * head);

        _pulsePaint
          ..color = config.primaryColor.withValues(alpha: pulseAlpha)
          ..strokeWidth = 1.3;
        canvas.drawLine(pStart, pEnd, _pulsePaint);
      }
    }

    // 6. Vẽ halo cho các nút hub và gom nhóm nút thường để giảm draw call
    for (int i = 0; i < nodeCount; i++) {
      final fade = _nodeFade[i];
      if (fade <= 0.01) continue;

      final pos = Offset(_nodeX[i], _nodeY[i]);
      if (_isHub[i] == 1) {
        final haloAlpha = (0.16 * fade * activityMod).clamp(0.0, 1.0);
        VisualEffectsHelper.drawSoftOrb(
          canvas,
          pos,
          _nodeSize[i] * 4.2,
          config.accentColor,
          alpha: haloAlpha,
          blur: 0,
        );
        _ptsLarge.add(pos);
      } else if (_nodeSize[i] < 2.1) {
        _ptsSmall.add(pos);
      } else {
        _ptsMedium.add(pos);
      }
    }

    final nodeAlpha = (0.68 * activityMod * audioMod).clamp(0.0, 1.0);
    if (_ptsSmall.isNotEmpty) {
      _pointPaint
        ..color = config.primaryColor.withValues(alpha: (nodeAlpha * 0.75).clamp(0.0, 1.0))
        ..strokeWidth = 1.6;
      canvas.drawPoints(PointMode.points, _ptsSmall, _pointPaint);
    }
    if (_ptsMedium.isNotEmpty) {
      _pointPaint
        ..color = config.primaryColor.withValues(alpha: nodeAlpha)
        ..strokeWidth = 2.9;
      canvas.drawPoints(PointMode.points, _ptsMedium, _pointPaint);
    }
    if (_ptsLarge.isNotEmpty) {
      _pointPaint
        ..color = config.primaryColor.withValues(alpha: (nodeAlpha * 1.15).clamp(0.0, 1.0))
        ..strokeWidth = 4.4;
      canvas.drawPoints(PointMode.points, _ptsLarge, _pointPaint);
    }
  }
}
