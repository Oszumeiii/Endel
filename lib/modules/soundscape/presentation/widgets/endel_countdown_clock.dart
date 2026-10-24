import 'package:flutter/material.dart';

/// Hiển thị đồng hồ đếm ngược và nút Play/Pause phong cách tối giản Endel
/// - Đồng hồ số tự co dãn (FittedBox) không bao giờ bị overflow
/// - Nút Play/Pause tích hợp vòng tiến trình đếm ngược (Progress Ring)
class EndelCountdownClock extends StatelessWidget {
  const EndelCountdownClock({
    super.key,
    required this.displayTime,
    required this.isPlaying,
    required this.isLoading,
    required this.progress,
    required this.onTogglePlayPause,
  });

  final String displayTime;
  final bool isPlaying;
  final bool isLoading;
  final double progress;
  final VoidCallback onTogglePlayPause;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Đồng hồ số Monospace phong cách kỹ thuật Endel
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              displayTime,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w300,
                letterSpacing: 4.0,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Nút Play / Pause với vòng tròn tiến trình (Progress Ring)
        Tooltip(
          message: isLoading
              ? 'Loading audio'
              : isPlaying
              ? 'Pause'
              : 'Play',
          child: GestureDetector(
            onTap: isLoading ? null : onTogglePlayPause,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 1.5,
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isPlaying
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPlaying
                          ? Colors.white
                          : const Color(0xFF141618),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: isPlaying ? 1.0 : 0.3,
                        ),
                        width: 1,
                      ),
                      boxShadow: isPlaying
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.2),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isLoading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isPlaying ? Colors.black : Colors.white,
                                ),
                              ),
                            )
                          : Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: isPlaying ? Colors.black : Colors.white,
                              size: 26,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
