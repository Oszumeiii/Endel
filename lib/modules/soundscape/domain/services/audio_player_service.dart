import '../entities/soundscape_item.dart';

/// Trạng thái phát âm thanh
enum AudioEngineStatus {
  idle,
  loading,
  playing,
  paused,
  error,
}

/// Abstract Contract cho Audio Player Engine.
/// Giúp tách biệt hoàn toàn thư viện phát âm thanh (just_audio, audioplayers, etc.)
/// khỏi Presentation Layer và BLoC.
abstract class AudioPlayerService {
  /// Stream phát ra trạng thái audio player
  Stream<AudioEngineStatus> get statusStream;

  /// Stream phát ra vị trí hiện tại của bài hát
  Stream<Duration> get positionStream;

  /// Trạng thái hiện tại
  AudioEngineStatus get currentStatus;

  /// Bắt đầu phát soundscape với loop vô tận và hiệu ứng fade-in mượt mà
  Future<void> playSoundscape(
    SoundscapeItem soundscape, {
    Duration fadeInDuration = const Duration(milliseconds: 1500),
  });

  /// Tạm dừng phát
  Future<void> pause();

  /// Tiếp tục phát
  Future<void> resume();

  /// Giảm âm lượng mà không dừng player, dùng cho đoạn cuối của timer.
  Future<void> fadeOut({required Duration duration});

  /// Dừng phát hoàn toàn (có hỗ trợ fade-out mượt mà)
  Future<void> stop({
    Duration fadeOutDuration = const Duration(milliseconds: 1000),
  });

  /// Điều chỉnh âm lượng từ 0.0 đến 1.0
  Future<void> setVolume(double volume);

  /// Giải phóng tài nguyên
  Future<void> dispose();
}
