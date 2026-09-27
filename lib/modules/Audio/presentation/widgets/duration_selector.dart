import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/extensions/context_x.dart';

class DurationSelector extends StatelessWidget {
  const DurationSelector({
    super.key,
    required this.selectedDuration,
    required this.onSelected,
  });

  final Duration selectedDuration;
  final ValueChanged<Duration> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primary = context.colorScheme.primary;

    return Material(
      color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => _showDurationPicker(context),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(Icons.timer_outlined, color: primary, size: 22.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  _formatDuration(selectedDuration),
                  style: TextStyle(
                    color: context.colorScheme.onSurface,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: context.colorScheme.onSurface.withValues(alpha: 0.55),
                size: 24.r,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDurationPicker(BuildContext context) async {
    var pickedDuration = selectedDuration;
    final result = await showModalBottomSheet<Duration>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final colorScheme = Theme.of(sheetContext).colorScheme;
        final isDark = colorScheme.brightness == Brightness.dark;

        return SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.only(top: 12.h, bottom: 12.h),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 14.h, 12.w, 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.65),
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      Text(
                        'Duration',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(sheetContext).pop(pickedDuration),
                        child: Text(
                          'Done',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 180.h,
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      brightness: isDark ? Brightness.dark : Brightness.light,
                      primaryColor: colorScheme.primary,
                    ),
                    child: CupertinoTimerPicker(
                      mode: CupertinoTimerPickerMode.hm,
                      initialTimerDuration: selectedDuration,
                      onTimerDurationChanged: (duration) {
                        pickedDuration = duration;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null && result > Duration.zero) {
      onSelected(result);
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '$hours:${minutes.toString().padLeft(2, '0')}';
    return '$minutes min';
  }
}