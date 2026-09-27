import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/extensions/context_x.dart';
import '../../../../core/language/generated/l10n.dart';
import '../../domain/enums/focus_mode.dart';
import '../../domain/enums/focus_status.dart';
import '../cubit/focus_cubit.dart';
import '../cubit/focus_state.dart';
import '../widgets/circular_timer.dart';
import '../widgets/duration_selector.dart';
import '../widgets/mode_selector.dart';
import '../widgets/sound_selector.dart';
import '../widgets/start_button.dart';

/// Thân màn hình Focus: ghép các widget con theo state của [FocusCubit].
class FocusBody extends StatelessWidget {
  const FocusBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FocusCubit, FocusState>(
      builder: (context, state) {
        final cubit = context.read<FocusCubit>();
        final isRunning = state.status == FocusStatus.running;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mode selector — segmented pill trong suốt/mờ
              ModeSelector(
                selectedMode: state.mode,
                onSelected: cubit.selectMode,
              ),
              SizedBox(height: 10.h),

              // Circular timer — vòng tròn lớn giữa màn hình
              Center(
                child: CircularTimer(
                  time: state.displayTime,
                  progress: state.progress,
                  subtitle: state.sessionLabel,
                ),
              ),
              SizedBox(height: 5.h),

              // Duration selector (ẩn khi stopwatch đang chạy)
              if (state.mode == FocusMode.countdown) ...[
                Text(
                  S.of(context).duration,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 12.h),
                DurationSelector(
                  selectedDuration: state.selectedDuration,
                  onSelected: cubit.selectDuration,
                ),
                SizedBox(height: 28.h),
              ],

              // Background sound selector
              Text(
                S.of(context).backgroundSound,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: context.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 12.h),
              SoundSelector(
                selectedSound: state.sound,
                onSelected: cubit.selectSound,
              ),
              SizedBox(height: 32.h),

              // Start button
              StartButton(
                status: state.status,
                onPressed: () {
                  if (isRunning) {
                    cubit.pause();
                  } else if (state.status == FocusStatus.paused) {
                    cubit.resume();
                  } else {
                    cubit.start();
                  }
                },
              ),
              SizedBox(height: 100.h),
            ],
          ),
        );
      },
    );
  }
}