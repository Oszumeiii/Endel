import 'package:flutter/material.dart';
import '../../domain/entities/visual_theme_config.dart';

/// Clean Architecture Strategy Pattern cho hệ thống vẽ hoạt ảnh Endel Visualizer.
/// Tách rời từng thuật toán vẽ vào các class riêng biệt giúp:
/// 1. Dễ dàng thêm hiệu ứng mới mà không làm ảnh hưởng code cũ.
/// 2. Tối ưu hiệu năng 60/120 FPS độc lập cho từng loại hình vẽ.
/// 3. Hỗ trợ test và tinh chỉnh thông số trực quan.
abstract class VisualPainterStrategy {
  const VisualPainterStrategy();

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
  });
}
