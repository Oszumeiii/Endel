import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import '../../domain/entities/visual_theme_config.dart';
import '../../domain/enums/wave_style.dart';
import '../cubit/soundscape_cubit.dart';
import '../cubit/soundscape_state.dart';
import '../widgets/endel_countdown_clock.dart';
import '../widgets/endel_timer_selector.dart';
import '../widgets/endel_visual_selector.dart';
import '../widgets/endel_visualizer.dart';
import '../widgets/soundscape_category_bar.dart';
import '../widgets/soundscape_hud_header.dart';
import '../widgets/visual_selector_sheet.dart';

/// Màn hình chính của Endel Soundscape:
/// - Toàn màn hình phong cách tối giản (Ambient Dark UI)
/// - Không còn appbar / thanh điều hướng thừa (loại bỏ hoàn toàn Home/Profile bar)
/// - Tự động co dãn (responsive) theo từng kích thước màn hình, không bao giờ bị overflow pixel
/// - Hỗ trợ Zen Mode: chạm vào màn hình để ẩn/hiện toàn bộ thanh điều khiển
/// - Hỗ trợ chọn ảnh động thủ công hoặc tự động chuyển theo nhạc (Auto Visualizer)
/// - Tối ưu hoá luồng: Áp dụng Granular Rebuild (BlocSelector/buildWhen) cô lập các widget tĩnh khỏi nhịp đếm ticker 500ms
@RoutePage()
class SoundscapeScreen extends StatelessWidget {
  const SoundscapeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SoundscapeCubit(),
      child: const _SoundscapeView(),
    );
  }
}

class _SoundscapeView extends StatelessWidget {
  const _SoundscapeView();

  void _showTrackSelector(
    BuildContext context,
    SoundscapeCubit cubit,
    SoundscapeState state,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SoundscapeTrackSheet(cubit: cubit, state: state),
    );
  }

  void _showVisualSelector(
    BuildContext context,
    SoundscapeCubit cubit,
    SoundscapeState state,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => VisualSelectorSheet(cubit: cubit, state: state),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090A),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight;

          final isShort = maxHeight < 680;
          final topSpacing = isShort ? 4.0 : 8.0;
          final bottomSpacing = isShort ? 12.0 : 20.0;
          final controlsSpacing = isShort ? 12.0 : 18.0;

          return Stack(
            children: [
              // 1. VISUALIZER NỀN: Cô lập hoàn toàn, chỉ cập nhật khi đổi track, wave style hoặc play/pause
              Positioned.fill(
                child: IgnorePointer(
                  child: BlocSelector<
                    SoundscapeCubit,
                    SoundscapeState,
                    ({
                      bool isPlaying,
                      VisualThemeConfig themeConfig,
                      WaveStyle activeWaveStyle,
                      int bpm,
                    })
                  >(
                    selector: (state) => (
                      isPlaying: state.isPlaying,
                      themeConfig: state.selectedSoundscape.themeConfig,
                      activeWaveStyle: state.activeWaveStyle,
                      bpm: state.selectedCategory.bpm,
                    ),
                    builder: (context, visualData) {
                      final cubit = context.read<SoundscapeCubit>();
                      return EndelVisualizer(
                        isPlaying: visualData.isPlaying,
                        themeConfig: visualData.themeConfig,
                        activeWaveStyle: visualData.activeWaveStyle,
                        audioPositionStream: cubit.audioPositionStream,
                        audioVolumeStream: cubit.audioVolumeStream,
                        bpm: visualData.bpm,
                      );
                    },
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 2. PHẦN TRÊN: HUD HEADER & CATEGORY BAR (Không rebuild khi countdown chạy)
                    BlocBuilder<SoundscapeCubit, SoundscapeState>(
                      buildWhen: (prev, curr) {
                        return prev.isControlsVisible != curr.isControlsVisible ||
                            prev.selectedSoundscape != curr.selectedSoundscape ||
                            prev.audioStatus != curr.audioStatus ||
                            prev.activeWaveStyle != curr.activeWaveStyle ||
                            prev.isAutoVisual != curr.isAutoVisual ||
                            prev.selectedCategory != curr.selectedCategory;
                      },
                      builder: (context, state) {
                        final cubit = context.read<SoundscapeCubit>();
                        final isControlsVisible = state.isControlsVisible;

                        return AnimatedOpacity(
                          opacity: isControlsVisible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: IgnorePointer(
                            ignoring: !isControlsVisible,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: topSpacing),
                                SoundscapeHudHeader(
                                  soundscape: state.selectedSoundscape,
                                  audioStatus: state.audioStatus,
                                  activeWaveStyle: state.activeWaveStyle,
                                  isAutoVisual: state.isAutoVisual,
                                  onTapSoundscape: () =>
                                      _showTrackSelector(context, cubit, state),
                                  onTapVisualSelector: () =>
                                      _showVisualSelector(
                                        context,
                                        cubit,
                                        state,
                                      ),
                                ),
                                SizedBox(height: isShort ? 6 : 10),
                                SoundscapeCategoryBar(
                                  selectedCategory: state.selectedCategory,
                                  onCategorySelected: cubit.selectCategory,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // 3. PHẦN GIỮA: VÙNG CHẠM CHUYỂN ĐỔI CHẾ ĐỘ ZEN MODE
                    Expanded(
                      child: BlocSelector<SoundscapeCubit, SoundscapeState, bool>(
                        selector: (state) => state.isControlsVisible,
                        builder: (context, isControlsVisible) {
                          final cubit = context.read<SoundscapeCubit>();
                          return GestureDetector(
                            onTap: cubit.toggleControlsVisibility,
                            behavior: HitTestBehavior.opaque,
                            child: Center(
                              child: !isControlsVisible
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.3,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        '',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          fontSize: 9,
                                          letterSpacing: 2.0,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          );
                        },
                      ),
                    ),

                    // 4. PHẦN DƯỚI: BỘ CHỌN THỜI GIAN & ĐỒNG HỒ / NÚT PLAY
                    BlocBuilder<SoundscapeCubit, SoundscapeState>(
                      buildWhen: (prev, curr) {
                        return prev.isControlsVisible != curr.isControlsVisible;
                      },
                      builder: (context, state) {
                        final isControlsVisible = state.isControlsVisible;

                        return AnimatedOpacity(
                          opacity: isControlsVisible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: IgnorePointer(
                            ignoring: !isControlsVisible,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 1. Thanh chọn ảnh động: Đưa danh sách xuống bên trên thanh chọn thời gian
                                BlocSelector<
                                  SoundscapeCubit,
                                  SoundscapeState,
                                  ({WaveStyle activeWaveStyle, bool isAutoVisual})
                                >(
                                  selector: (state) => (
                                    activeWaveStyle: state.activeWaveStyle,
                                    isAutoVisual: state.isAutoVisual,
                                  ),
                                  builder: (context, visualData) {
                                    return EndelVisualSelector(
                                      activeWaveStyle: visualData.activeWaveStyle,
                                      isAutoVisual: visualData.isAutoVisual,
                                      onWaveStyleSelected: context
                                          .read<SoundscapeCubit>()
                                          .setManualWaveStyle,
                                    );
                                  },
                                ),
                                SizedBox(height: isShort ? 6 : 10),

                                // 2. Bộ chọn thời gian: Chỉ rebuild khi người dùng đổi thời lượng đặt
                                BlocSelector<
                                  SoundscapeCubit,
                                  SoundscapeState,
                                  Duration?
                                >(
                                  selector: (state) => state.selectedDuration,
                                  builder: (context, selectedDuration) {
                                    return EndelTimerSelector(
                                      selectedDuration: selectedDuration,
                                      onDurationSelected: context
                                          .read<SoundscapeCubit>()
                                          .selectDuration,
                                    );
                                  },
                                ),
                                SizedBox(height: controlsSpacing),

                                // Đồng hồ đếm ngược: Vùng duy nhất rebuild theo nhịp ticker
                                BlocSelector<
                                  SoundscapeCubit,
                                  SoundscapeState,
                                  ({
                                    String time,
                                    bool isPlaying,
                                    bool isLoading,
                                    double progress,
                                  })
                                >(
                                  selector: (state) => (
                                    time: state.formattedDisplayTime,
                                    isPlaying: state.isPlaying,
                                    isLoading: state.isLoading,
                                    progress: state.timerProgress,
                                  ),
                                  builder: (context, clockData) {
                                    return EndelCountdownClock(
                                      displayTime: clockData.time,
                                      isPlaying: clockData.isPlaying,
                                      isLoading: clockData.isLoading,
                                      progress: clockData.progress,
                                      onTogglePlayPause: context
                                          .read<SoundscapeCubit>()
                                          .togglePlayPause,
                                    );
                                  },
                                ),

                                // Thông báo lỗi hoặc hoàn tất phiên
                                BlocSelector<
                                  SoundscapeCubit,
                                  SoundscapeState,
                                  ({bool hasError, bool isComplete})
                                >(
                                  selector: (state) => (
                                    hasError: state.hasError,
                                    isComplete: state.isSessionComplete,
                                  ),
                                  builder: (context, status) {
                                    if (!status.hasError && !status.isComplete) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        status.hasError
                                            ? 'Unable to play audio. Please try again.'
                                            : 'Session complete.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: status.hasError
                                              ? const Color(0xFFFF8A80)
                                              : Colors.white.withValues(
                                                  alpha: 0.55,
                                                ),
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: bottomSpacing),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Modal for choosing a soundscape in the selected category.
class _SoundscapeTrackSheet extends StatelessWidget {
  const _SoundscapeTrackSheet({required this.cubit, required this.state});

  final SoundscapeCubit cubit;
  final SoundscapeState state;

  @override
  Widget build(BuildContext context) {
    final tracks = state.availableSoundscapes;

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
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.queue_music_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${state.selectedCategory.label.toUpperCase()} SOUNDSCAPES',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.close_rounded,
                      color: Color(0xFF888888),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.62,
              ),
              child: ListView(
                shrinkWrap: true,
                children: tracks.map((item) {
                  final isSelected = item.id == state.selectedSoundscape.id;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () {
                        cubit.selectSoundscape(item);
                        Navigator.pop(context);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.12)
                              : const Color(0xFF16181B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.08),
                            width: 0.9,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.06),
                              ),
                              child: Center(
                                child: Icon(
                                  isSelected && state.isPlaying
                                      ? Icons.graphic_eq_rounded
                                      : Icons.music_note_rounded,
                                  size: 18,
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white70,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item.subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF888888),
                                      fontSize: 11,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    children: item.tags.map((tag) {
                                      return Text(
                                        '#$tag',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.4,
                                          ),
                                          fontSize: 10,
                                          fontFamily: 'monospace',
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
