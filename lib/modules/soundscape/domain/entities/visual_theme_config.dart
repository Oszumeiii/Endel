import 'package:flutter/material.dart';
import '../enums/wave_style.dart';

/// Cấu hình hiển thị hiệu ứng đồ họa động cho từng bài soundscape
class VisualThemeConfig {
  const VisualThemeConfig({
    required this.waveStyle,
    this.primaryColor = Colors.white,
    this.accentColor = const Color(0xFF888888),
    this.waveSpeed = 1.0,
    this.layerCount = 3,
    this.baseRadiusFactor = 0.30,
    this.deformationIntensity = 1.0,
  });

  /// Kiểu thuật toán sinh hình động
  final WaveStyle waveStyle;

  /// Màu sắc chủ đạo (chuẩn Endel là tông trắng/sáng trên nền đen)
  final Color primaryColor;

  /// Màu phụ hoặc phát quang
  final Color accentColor;

  /// Tốc độ chuyển động của sóng (1.0 = chuẩn, >1.0 = nhanh hơn)
  final double waveSpeed;

  /// Số lớp sóng lồng nhau
  final int layerCount;

  /// Tỉ lệ bán kính so với khung vẽ
  final double baseRadiusFactor;

  /// Độ biến dạng (uốn lượn mạnh hay nhẹ)
  final double deformationIntensity;
}
