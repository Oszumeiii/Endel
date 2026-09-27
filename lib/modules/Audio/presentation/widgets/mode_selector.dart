import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/extensions/context_x.dart';
import '../../../../core/language/generated/l10n.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../domain/enums/focus_mode.dart';

/// Bộ chọn chế độ: Countdown / Stopwatch.
class ModeSelector extends StatelessWidget {
  const ModeSelector({
    super.key,
    required this.selectedMode,
    required this.onSelected,
  });

  final FocusMode selectedMode;
  final ValueChanged<FocusMode> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primary = context.colorScheme.primary;

    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        children: [
          _ModeTab(
            label: S.of(context).countdown,
            isSelected: selectedMode == FocusMode.countdown,
            selectedColor: primary,
            onTap: () => onSelected(FocusMode.countdown),
          ),
          _ModeTab(
            label: S.of(context).stopwatch,
            isSelected: selectedMode == FocusMode.stopwatch,
            selectedColor: primary,
            onTap: () => onSelected(FocusMode.stopwatch),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(26.r),
          ),
          child: AppText(
            label,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
            textColor: isSelected
                ? Colors.white
                : context.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
