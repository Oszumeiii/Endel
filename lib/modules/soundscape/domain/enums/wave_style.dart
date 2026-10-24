import 'package:flutter/material.dart';

/// Kiểu hiển thị hình ảnh động của Endel Visualizer (đối chiếu chuẩn https://endel.io)
enum WaveStyle {
  /// Sóng uốn lượn mềm mại đa hài (dành cho Relax / Ambient)
  organic(
    id: 'organic',
    label: 'Organic Waves',
    description: 'Harmonic flowing ribbons that calm the nervous system',
    iconData: Icons.waves_rounded,
  ),

  /// Khối đa giác góc cạnh, xoay đảo chiều kỹ thuật (dành cho Focus)
  geometric(
    id: 'geometric',
    label: 'Geometric Crystals',
    description: 'Precision multifaceted polygons enhancing cognitive focus',
    iconData: Icons.hexagon_outlined,
  ),

  /// Quầng sáng phập phồng theo nhịp thở êm dịu (dành cho Sleep)
  breathing(
    id: 'breathing',
    label: 'Breathing Aura',
    description: 'Slow rhythmic luminous pulsations for deep delta rest',
    iconData: Icons.album_outlined,
  ),

  /// Dải sóng động học và luồng quỹ đạo năng lượng (dành cho Activity)
  activity(
    id: 'activity',
    label: 'Kinetic Flux',
    description: 'High-energy orbital ribbons powering continuous movement',
    iconData: Icons.motion_photos_on_rounded,
  ),

  /// Xung radar lan tỏa theo nhịp tuần hoàn (dành cho Move)
  pulse(
    id: 'pulse',
    label: 'Radar Pulse',
    description: 'Concentric cadence rings aligning physical rhythm and tempo',
    iconData: Icons.radio_button_checked_rounded,
  ),

  /// Mạng lưới nút dao động cộng hưởng liên kết (dành cho ADHD / Centering)
  constellation(
    id: 'constellation',
    label: 'Constellation Mesh',
    description: 'Harmonically connected nodes stabilizing scattered thoughts',
    iconData: Icons.hub_outlined,
  ),

  /// Sóng gợn đồng tâm lan tỏa mềm mại (dành cho Nature / Water)
  ripples(
    id: 'ripples',
    label: 'Water Ripples',
    description: 'Gentle droplet concentric wavelets evoking natural tranquility',
    iconData: Icons.blur_on_rounded,
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
}
