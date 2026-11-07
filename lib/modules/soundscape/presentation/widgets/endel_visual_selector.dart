import 'package:flutter/material.dart';

import '../../domain/enums/wave_style.dart';

/// Thanh chọn ảnh động (Visual Selector Bar) phong cách tối giản Endel.
/// Nằm trực tiếp bên trên thanh chọn thời gian để người dùng dễ dàng chuyển đổi
/// giữa chế độ Auto và các kiểu sóng ảnh động thủ công.
class EndelVisualSelector extends StatelessWidget {
  const EndelVisualSelector({
    super.key,
    required this.activeWaveStyle,
    required this.isAutoVisual,
    required this.onWaveStyleSelected,
  });

  final WaveStyle activeWaveStyle;
  final bool isAutoVisual;
  final ValueChanged<WaveStyle?> onWaveStyleSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Tùy chọn Tự động chọn theo bài nhạc (Auto)
          _buildChip(
            label: 'AUTO',
            icon: Icons.auto_awesome_rounded,
            isSelected: isAutoVisual,
            onTap: () => onWaveStyleSelected(null),
          ),

          // 2. Danh sách các kiểu ảnh động sóng (WaveStyle)
          ...WaveStyle.values.map((style) {
            final isSelected = !isAutoVisual && activeWaveStyle == style;
            return _buildChip(
              label: _getShortLabel(style),
              icon: style.iconData,
              isSelected: isSelected,
              onTap: () => onWaveStyleSelected(style),
            );
          }),
        ],
      ),
    );
  }

  String _getShortLabel(WaveStyle style) {
    return switch (style) {
      WaveStyle.organic => 'ORGANIC',
      WaveStyle.geometric => 'GEOMETRIC',
      WaveStyle.breathing => 'BREATHING',
      WaveStyle.activity => 'KINETIC',
      WaveStyle.pulse => 'PULSE',
      WaveStyle.constellation => 'MESH',
      WaveStyle.ripples => 'RIPPLES',
    };
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.16)
                : const Color(0xFF141618),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.12),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 11,
                color: isSelected ? Colors.white : const Color(0xFF777777),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF777777),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 1.0,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
