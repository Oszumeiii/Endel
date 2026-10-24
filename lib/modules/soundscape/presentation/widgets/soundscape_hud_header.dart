import 'package:flutter/material.dart';

import '../../domain/entities/soundscape_item.dart';
import '../../domain/enums/wave_style.dart';
import '../../domain/services/audio_player_service.dart';

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

  String get _statusLabel => switch (audioStatus) {
    AudioEngineStatus.loading => 'LOADING',
    AudioEngineStatus.playing => 'PLAYING',
    AudioEngineStatus.paused => 'PAUSED',
    AudioEngineStatus.error => 'ERROR',
    AudioEngineStatus.idle => 'READY',
  };

  @override
  Widget build(BuildContext context) {
    final isPlaying = audioStatus == AudioEngineStatus.playing;
    final statusColor = audioStatus == AudioEngineStatus.error
        ? const Color(0xFFFF8A80)
        : isPlaying
        ? const Color(0xFF4CAF50)
        : const Color(0xFF888888);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // 1. Bên trái: Danh mục & Tên bài Soundscape (chạm để mở sheet đổi bài)
          Expanded(
            child: GestureDetector(
              onTap: onTapSoundscape,
              behavior: HitTestBehavior.opaque,
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
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 10,
                            letterSpacing: 1.8,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          soundscape.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            letterSpacing: 0.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (onTapSoundscape != null) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 2. Nút chọn ảnh động Visual Mode (Auto vs Manual)
          Flexible(
            child: GestureDetector(
              onTap: onTapVisualSelector,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: isAutoVisual
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isAutoVisual
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.white,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAutoVisual
                          ? Icons.auto_awesome_rounded
                          : activeWaveStyle.iconData,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        isAutoVisual
                            ? 'VISUAL: AUTO'
                            : activeWaveStyle.id.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // 3. Trạng thái âm thanh (PLAYING/PAUSED/READY)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 0.8,
              ),
            ),
            child: Text(
              _statusLabel,
              style: TextStyle(
                color: statusColor,
                fontSize: 9,
                letterSpacing: 1.0,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
