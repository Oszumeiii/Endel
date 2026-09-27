import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/extensions/context_x.dart';
import '../../../../shared/widgets/app_text.dart';
import 'focus_time_format.dart';

class CircularTimer extends StatelessWidget {
  const CircularTimer({
    super.key,
    required this.time,
    required this.progress,
    required this.subtitle,
  });

  final Duration time;
  final double progress;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primary = Theme.of(context).colorScheme.primary;
    final innerFill = isDark ? const Color(0xFF1F382F) : const Color(0xFFDEE9E7);
    final outerRing = isDark ? Colors.white.withValues(alpha: 0.9) : Colors.white;
    final secondaryRing = isDark ? const Color(0xFF89A9A4) : const Color(0xFF7EA6A5);

    return SizedBox(
      width: 320.r,
      height: 320.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 290.r,
            height: 290.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primary.withValues(alpha: isDark ? 0.15 : 0.08),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
          Container(
            width: 260.r,
            height: 260.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: innerFill,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
          ),
          CustomPaint(
            size: Size(320.r, 320.r),
            painter: _TimerRingPainter(
              progress: progress,
              progressColor: primary,
              trackColor: secondaryRing.withValues(alpha: 0.9),
              dashedColor: outerRing.withValues(alpha: 0.78),
              isDark: isDark,
            ),
          ),
          Positioned(
            top: 34,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 34,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                formatFocusTime(time),
                fontSize: 50,
                fontWeight: FontWeight.w800,
                textColor: context.defaultTextColor,
                height: 1.1,
              ),
              SizedBox(height: 8.h),
              AppText(
                subtitle,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
                textColor: primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  _TimerRingPainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
    required this.dashedColor,
    required this.isDark,
  });

  final double progress;
  final Color progressColor;
  final Color trackColor;
  final Color dashedColor;
  final bool isDark;

  static const double _outerStroke = 18;
  static const double _midStroke = 6;
  static const double _progressStroke = 10;
  static const int _ticks = 42;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 18;

    final outerPaint = Paint()
      ..color = dashedColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _outerStroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, outerPaint);

    final midPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _midStroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - 10, midPaint);

    final dashedPaint = Paint()
      ..color = dashedColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < _ticks; i++) {
      final angle = (2 * math.pi * i / _ticks) - math.pi / 2;
      final start = Offset(
        center.dx + math.cos(angle) * (radius - 2),
        center.dy + math.sin(angle) * (radius - 2),
      );
      final end = Offset(
        center.dx + math.cos(angle) * (radius - 16),
        center.dy + math.sin(angle) * (radius - 16),
      );
      if (i % 3 == 0) {
        canvas.drawLine(start, end, dashedPaint);
      }
    }

    final arcRect = Rect.fromCircle(center: center, radius: radius - 18);
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    const startAngle = -math.pi / 2;

    final glowPaint = Paint()
      ..color = progressColor.withValues(alpha: isDark ? 0.18 : 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _progressStroke + 12
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    if (sweepAngle > 0) {
      canvas.drawArc(arcRect, startAngle, sweepAngle, false, glowPaint);
    }

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _progressStroke
      ..strokeCap = StrokeCap.round;

    if (sweepAngle > 0) {
      canvas.drawArc(arcRect, startAngle, sweepAngle, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.dashedColor != dashedColor;
  }
}