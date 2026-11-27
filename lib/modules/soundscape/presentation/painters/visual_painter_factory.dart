import '../../domain/enums/wave_style.dart';
import 'drawings/activity_painter.dart';
import 'drawings/aurora_painter.dart';
import 'drawings/bloom_painter.dart';
import 'drawings/cascade_painter.dart';
import 'drawings/constellation_painter.dart';
import 'drawings/night_sky_painter.dart';
import 'drawings/silk_painter.dart';
import 'visual_painter_strategy.dart';

/// Factory trả về Painter tương ứng theo WaveStyle (Open-Closed Principle).
/// Khi bổ sung ảnh động mới, chỉ cần khai báo painter mới và gán vào factory.
class VisualPainterFactory {
  VisualPainterFactory._();

  static const _auroraPainter = AuroraVisualPainter();
  static const _constellationPainter = ConstellationVisualPainter();
  static const _nightSkyPainter = NightSkyVisualPainter();
  static const _activityPainter = ActivityVisualPainter();
  static const _silkPainter = SilkVisualPainter();
  static const _cascadePainter = CascadeVisualPainter();
  static const _bloomPainter = BloomVisualPainter();

  /// Lấy painter theo kiểu hoạt ảnh được yêu cầu
  static VisualPainterStrategy getPainter(WaveStyle style) {
    switch (style) {
      case WaveStyle.aurora:
        return _auroraPainter;
      case WaveStyle.constellation:
        return _constellationPainter;
      case WaveStyle.nightSky:
        return _nightSkyPainter;
      case WaveStyle.activity:
        return _activityPainter;
      case WaveStyle.silk:
        return _silkPainter;
      case WaveStyle.cascade:
        return _cascadePainter;
      case WaveStyle.bloom:
        return _bloomPainter;
    }
  }
}
