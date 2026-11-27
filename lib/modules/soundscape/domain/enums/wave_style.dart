import 'package:flutter/material.dart';

/// Kiểu hiển thị hình ảnh động của Endel Visualizer (đối chiếu chuẩn https://endel.io)
enum WaveStyle {
  /// Mảng ánh sáng màu lớn, mờ, trôi chậm và hòa vào nhau (dành cho Relax / Ambient)
  aurora(
    id: 'aurora',
    label: 'Aurora',
    description: 'Soft drifting color fields blending into tranquil light',
    iconData: Icons.waves_rounded,
  ),

  /// Bầu trời các chấm nối với nhau như đồ thị trôi chậm, tự nối và ngắt (dành cho Focus / ADHD)
  constellation(
    id: 'constellation',
    label: 'Constellation',
    description: 'Drifting star-like nodes forming quiet harmonic connections',
    iconData: Icons.hub_outlined,
  ),

  /// Trời đêm đầy sao, trăng khuyết và các chòm sao nối vạch nhẹ nhàng (dành cho Sleep)
  nightSky(
    id: 'night_sky',
    label: 'Night Sky',
    description:
        'Still starfield, crescent moon, and slow celestial constellations',
    iconData: Icons.nights_stay_outlined,
  ),

  /// Dải sóng động học và luồng quỹ đạo năng lượng (dành cho Activity)
  activity(
    id: 'activity',
    label: 'Kinetic Flux',
    description: 'High-energy orbital ribbons powering continuous movement',
    iconData: Icons.motion_photos_on_rounded,
  ),

  /// Nhiều sợi mảnh song song lệch pha tạo dải lụa xoắn 3D (dành cho Nature / Silk)
  silk(
    id: 'silk',
    label: 'Silk',
    description: 'Delicate braided silk threads flowing in harmonic motion',
    iconData: Icons.blur_on_rounded,
  ),

  /// Các sợi mảnh chạy dọc buông xuống như rèm ánh sáng xoắn nhẹ
  cascade(
    id: 'cascade',
    label: 'Cascade',
    description: 'Vertical light curtains swaying in slow harmonic currents',
    iconData: Icons.waterfall_chart_rounded,
  ),

  /// Họ sợi mảnh xếp thành đóa hoa / quả cầu string-art xoay chậm trong không gian
  bloom(
    id: 'bloom',
    label: 'Bloom',
    description: 'Luminous woven petals rotating in meditative symmetry',
    iconData: Icons.filter_vintage_outlined,
  ),

  /// Mạng lưới nút phát sáng chuyển động theo quỹ đạo và liên kết gần nhau
  mesh(
    id: 'mesh',
    label: 'Mesh',
    description:
        'Glowing constellation nodes linked by proximity and resonance',
    iconData: Icons.hub_rounded,
  ),

  /// Vòng sóng radar lan tỏa theo nhịp và quét các điểm định vị
  pulse(
    id: 'pulse',
    label: 'Pulse',
    description: 'Cadence radar rings and sweeping beacons pulsing in rhythm',
    iconData: Icons.radar_rounded,
  );

  const WaveStyle({
    required this.id,
    required this.label,
    required this.description,
    required this.iconData,
  });

  final String id;
  final String label;
  final String description;
  final IconData iconData;

  /// Ánh xạ id cũ sang enum mới để tránh lỗi nếu dữ liệu lưu trữ còn id cũ
  static WaveStyle fromId(String? id) {
    switch (id) {
      case 'organic':
      case 'aurora':
        return WaveStyle.aurora;
      case 'geometric':
      case 'constellation':
        return WaveStyle.constellation;
      case 'breathing':
      case 'dunes':
      case 'night_sky':
      case 'nightSky':
        return WaveStyle.nightSky;
      case 'ripples':
      case 'silk':
        return WaveStyle.silk;
      case 'activity':
        return WaveStyle.activity;
      case 'cascade':
        return WaveStyle.cascade;
      case 'bloom':
        return WaveStyle.bloom;
      case 'mesh':
        return WaveStyle.mesh;
      case 'pulse':
        return WaveStyle.pulse;
      default:
        return WaveStyle.aurora;
    }
  }
}
