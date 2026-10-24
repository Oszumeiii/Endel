import '../../domain/enums/wave_style.dart';
import 'drawings/activity_painter.dart';
import 'drawings/breathing_painter.dart';
import 'drawings/constellation_painter.dart';
import 'drawings/geometric_painter.dart';
import 'drawings/organic_painter.dart';
import 'drawings/pulse_painter.dart';
import 'drawings/ripples_painter.dart';
import 'visual_painter_strategy.dart';

/// Factory trả về Painter tương ứng theo WaveStyle (Open-Closed Principle).
/// Khi bổ sung ảnh động mới, chỉ cần khai báo painter mới và gán vào factory.
class VisualPainterFactory {
  VisualPainterFactory._();

  static const _organicPainter = OrganicVisualPainter();
  static const _geometricPainter = GeometricVisualPainter();
  static const _breathingPainter = BreathingVisualPainter();
  static const _activityPainter = ActivityVisualPainter();
  static const _pulsePainter = PulseVisualPainter();
  static const _constellationPainter = ConstellationVisualPainter();
  static const _ripplesPainter = RipplesVisualPainter();

  /// Lấy painter theo kiểu hoạt ảnh được yêu cầu
  static VisualPainterStrategy getPainter(WaveStyle style) {
    switch (style) {
      case WaveStyle.organic:
        return _organicPainter;
      case WaveStyle.geometric:
        return _geometricPainter;
      case WaveStyle.breathing:
        return _breathingPainter;
      case WaveStyle.activity:
        return _activityPainter;
      case WaveStyle.pulse:
        return _pulsePainter;
      case WaveStyle.constellation:
        return _constellationPainter;
      case WaveStyle.ripples:
        return _ripplesPainter;
    }
  }
}
