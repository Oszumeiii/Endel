import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/extensions/context_x.dart';
import '../../../../core/language/generated/l10n.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../domain/enums/focus_status.dart';

/// Nút hành động chính của màn hình Focus.
///
/// Trạng thái:
/// - Idle/Completed → "Start focusing"
/// - Running → "Pause"
/// - Paused → "Resume"
class StartButton extends StatelessWidget {
  const StartButton({
    super.key,
    required this.status,
    required this.onPressed,
  });

  final FocusStatus status;
  final VoidCallback onPressed;

  bool get _isRunning => status == FocusStatus.running;

  String _label(BuildContext context) {
    switch (status) {
      case FocusStatus.running:
        return S.of(context).pause;
      case FocusStatus.paused:
        return S.of(context).resume;
      case FocusStatus.idle:
      case FocusStatus.completed:
        return S.of(context).startFocusing;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;

    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 22.r,
              color: Colors.white,
            ),
            SizedBox(width: 8.w),
            AppText(
              _label(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}