import 'package:flutter/material.dart';

import '../../domain/entities/soundscape_item.dart';
import '../../domain/enums/wave_style.dart';
import '../../domain/services/audio_player_service.dart';

/// HUD Header ở đỉnh màn hình Endel Soundscape:
/// - Hiển thị khu vực chọn bài nhạc (Track Selector) rõ ràng, nổi bật, dễ bấm
/// - Đã loại bỏ hoàn toàn nhãn trạng thái ready/pause/playing theo yêu cầu người dùng
/// - Chuyển toàn bộ trọng tâm sang việc hiển thị bài hát và danh mục âm thanh
class SoundscapeHudHeader extends StatelessWidget {
  const SoundscapeHudHeader({
    super.key,
    required this.soundscape,
    required this.audioStatus,
    required this.activeWaveStyle,
    required this.isAutoVisual,
    this.onTapSoundscape,
    this.onTapVisualSelector,
  });

  final SoundscapeItem soundscape;
  final AudioEngineStatus audioStatus;
  final WaveStyle activeWaveStyle;
  final bool isAutoVisual;
  final VoidCallback? onTapSoundscape;
  final VoidCallback? onTapVisualSelector;

  @override
  Widget build(BuildContext context) {
    final isPlaying = audioStatus == AudioEngineStatus.playing;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Khu vực chọn bài nhạc: Được thiết kế thành dạng Card / Capsule rõ ràng,
          // nổi bật để người dùng dễ dàng nhận biết và chạm vào để đổi bài.
          Expanded(
            child: GestureDetector(
              onTap: onTapSoundscape,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF141618),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 0.9,
                  ),
                ),
                child: Row(
                  children: [
                    // Icon bài nhạc với nền tròn tinh tế
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      child: Center(
                        child: Icon(
                          isPlaying
                              ? Icons.graphic_eq_rounded
                              : Icons.music_note_rounded,
                          size: 18,
                          color: isPlaying ? Colors.white : Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Thông tin bài nhạc & danh mục
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  soundscape.category.label.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 9.5,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '• ${soundscape.category.bpmLabel}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  fontSize: 9,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            soundscape.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              letterSpacing: 0.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Nút gợi ý chọn bài / đổi bài
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 0.6,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'TRACK',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 15,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

