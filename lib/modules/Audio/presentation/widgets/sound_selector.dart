import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/extensions/context_x.dart';
import '../../../../core/language/generated/l10n.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../domain/enums/background_sound.dart';

class SoundSelector extends StatelessWidget {
  const SoundSelector({
    super.key,
    required this.selectedSound,
    required this.onSelected,
  });

  final BackgroundSound selectedSound;
  final ValueChanged<BackgroundSound> onSelected;

  List<({BackgroundSound sound, String label, IconData icon})>
      _buildOptions(BuildContext context) => [
        (
          sound: BackgroundSound.none,
          label: S.of(context).soundNone,
          icon: Icons.do_not_disturb_on_outlined,
        ),
        (
          sound: BackgroundSound.tick,
          label: S.of(context).soundTick,
          icon: Icons.av_timer_outlined,
        ),
        (
          sound: BackgroundSound.whiteNoise,
          label: S.of(context).soundWhiteNoise,
          icon: Icons.graphic_eq,
        ),
        (
          sound: BackgroundSound.rain,
          label: S.of(context).soundRain,
          icon: Icons.water_drop_outlined,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primary = context.colorScheme.primary;
    final options = _buildOptions(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: options.map((option) {
            final selected = option.sound == selectedSound;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: GestureDetector(
                  onTap: () => onSelected(option.sound),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80.w,
                    height: 96.h,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: selected
                          ? primary.withValues(alpha: isDark ? 0.16 : 0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: selected
                            ? primary.withValues(alpha: 0.7)
                            : Colors.grey.withValues(alpha: 0.18),
                        width: selected ? 1.6 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.08),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          option.icon,
                          size: 24.r,
                          color: selected
                              ? primary
                              : Colors.black.withValues(alpha: 0.65),
                        ),
                        SizedBox(height: 8.h),
                        AppText(
                          option.label,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          textAlign: TextAlign.center,
                          textColor: selected
                              ? primary
                              : Colors.black.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}