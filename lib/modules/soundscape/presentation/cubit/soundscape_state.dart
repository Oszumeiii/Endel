import 'package:equatable/equatable.dart';
import '../../domain/entities/soundscape_item.dart';
import '../../domain/enums/soundscape_category.dart';
import '../../domain/enums/wave_style.dart';
import '../../domain/services/audio_player_service.dart';

class SoundscapeState extends Equatable {
  const SoundscapeState({
    required this.selectedSoundscape,
    required this.availableSoundscapes,
    required this.selectedCategory,
    this.audioStatus = AudioEngineStatus.idle,
    this.selectedDuration = const Duration(minutes: 45),
    this.remainingDuration = const Duration(minutes: 45),
    this.elapsedDuration = Duration.zero,
    this.isControlsVisible = true,
    this.manualWaveStyle,
  });

  /// Bài soundscape đang được chọn
  final SoundscapeItem selectedSoundscape;

  /// Danh sách các bài soundscape khả dụng theo category hiện tại
  final List<SoundscapeItem> availableSoundscapes;

  /// Danh mục hiện tại (Relax, Focus, Sleep, Activity, Move, ADHD)
  final SoundscapeCategory selectedCategory;

  /// Trạng thái phát nhạc
  final AudioEngineStatus audioStatus;

  /// Thời lượng phiên đã chọn (null = Vô cực ∞)
  final Duration? selectedDuration;

  /// Thời gian còn lại (đếm ngược, null = Vô cực ∞)
  final Duration? remainingDuration;

  /// Thời gian đã phát
  final Duration elapsedDuration;

  /// Chế độ ẩn/hiện bảng điều khiển (Zen Mode)
  final bool isControlsVisible;

  /// Kiểu hoạt ảnh chọn thủ công (null = Tự động chọn theo themeConfig của bài soundscape)
  final WaveStyle? manualWaveStyle;

  /// Hoạt ảnh đang hoạt động thực tế
  WaveStyle get activeWaveStyle =>
      manualWaveStyle ?? selectedSoundscape.themeConfig.waveStyle;

  /// Có đang ở chế độ tự động chọn hoạt ảnh hay không
  bool get isAutoVisual => manualWaveStyle == null;

  /// Đang phát hay không
  bool get isPlaying => audioStatus == AudioEngineStatus.playing;

  /// Đang tải hay không
  bool get isLoading => audioStatus == AudioEngineStatus.loading;

  bool get isPaused => audioStatus == AudioEngineStatus.paused;

  bool get hasError => audioStatus == AudioEngineStatus.error;

  /// Có phải chế độ vô hạn hay không
  bool get isEndless => selectedDuration == null;

  bool get isSessionComplete =>
      !isEndless &&
      remainingDuration == Duration.zero &&
      audioStatus == AudioEngineStatus.idle;

  /// Thời gian còn lại cho phiên nghe.
  String get formattedDisplayTime {
    if (isEndless) return '∞';
    final dur = remainingDuration ?? Duration.zero;
    final hours = dur.inHours;
    final minutes = dur.inMinutes.remainder(60);
    final seconds = dur.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Tiến trình đếm ngược (0.0 đến 1.0)
  double get timerProgress {
    if (isEndless) return 1.0;
    final total = selectedDuration?.inSeconds ?? 0;
    if (total == 0) return 0.0;
    final remaining = remainingDuration?.inSeconds ?? 0;
    return (remaining / total).clamp(0.0, 1.0);
  }

  SoundscapeState copyWith({
    SoundscapeItem? selectedSoundscape,
    List<SoundscapeItem>? availableSoundscapes,
    SoundscapeCategory? selectedCategory,
    AudioEngineStatus? audioStatus,
    Duration? Function()? selectedDuration,
    Duration? Function()? remainingDuration,
    Duration? elapsedDuration,
    bool? isControlsVisible,
    WaveStyle? Function()? manualWaveStyle,
  }) {
    return SoundscapeState(
      selectedSoundscape: selectedSoundscape ?? this.selectedSoundscape,
      availableSoundscapes: availableSoundscapes ?? this.availableSoundscapes,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      audioStatus: audioStatus ?? this.audioStatus,
      selectedDuration:
          selectedDuration != null ? selectedDuration() : this.selectedDuration,
      remainingDuration:
          remainingDuration != null ? remainingDuration() : this.remainingDuration,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      isControlsVisible: isControlsVisible ?? this.isControlsVisible,
      manualWaveStyle:
          manualWaveStyle != null ? manualWaveStyle() : this.manualWaveStyle,
    );
  }

  @override
  List<Object?> get props => [
        selectedSoundscape,
        availableSoundscapes,
        selectedCategory,
        audioStatus,
        selectedDuration,
        remainingDuration,
        elapsedDuration,
        isControlsVisible,
        manualWaveStyle,
      ];
}
