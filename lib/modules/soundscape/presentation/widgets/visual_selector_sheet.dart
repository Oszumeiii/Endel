import 'package:flutter/material.dart';
import '../../domain/enums/wave_style.dart';
import '../cubit/soundscape_cubit.dart';
import '../cubit/soundscape_state.dart';

/// Modal Bottom Sheet chọn hiệu ứng ảnh động (Visualizer Selector)
/// Đáp ứng yêu cầu: Chọn ảnh động thủ công; nếu không chọn app sẽ tự động chọn (Auto).
class VisualSelectorSheet extends StatelessWidget {
  const VisualSelectorSheet({
    super.key,
    required this.cubit,
    required this.state,
  });

  final SoundscapeCubit cubit;
  final SoundscapeState state;

  @override
  Widget build(BuildContext context) {
    final activeStyle = state.activeWaveStyle;
    final isAuto = state.isAutoVisual;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF101214),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 25,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh kéo handle ở đầu sheet
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header tiêu đề & nút đóng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ENDEL VISUAL ENGINE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    fontFamily: 'monospace',
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.close_rounded,
                      color: Color(0xFF888888),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Select a visual style manually or let Endel adapt automatically to your track.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 16),

            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.65,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  // 1. MỤC AUTO: TỰ ĐỘNG CHỌN THEO TRACK (MẶC ĐỊNH)
                  _buildOptionCard(
                    title: 'Auto (Soundscape Matched)',
                    subtitle:
                        'Automatically shifts visuals based on track acoustics and phase (Current: ${state.selectedSoundscape.themeConfig.waveStyle.label})',
                    icon: Icons.auto_awesome_rounded,
                    isSelected: isAuto,
                    badgeText: 'RECOMMENDED',
                    onTap: () async {
                      await cubit.setManualWaveStyle(null);
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'MANUAL STYLES',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),

                  // 2. DANH SÁCH ẢNH ĐỘNG CHỌN THỦ CÔNG
                  ...WaveStyle.values.map((style) {
                    final isExplicitlySelected =
                        !isAuto && state.manualWaveStyle == style;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildOptionCard(
                        title: style.label,
                        subtitle: style.description,
                        icon: style.iconData,
                        isSelected: isExplicitlySelected,
                        badgeText: isAuto && activeStyle == style
                            ? 'ACTIVE VIA AUTO'
                            : null,
                        onTap: () async {
                          await cubit.setManualWaveStyle(style);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    String? badgeText,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFF16181B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.08),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.06),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Colors.black : Colors.white70,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 8,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 11,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 10),
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
