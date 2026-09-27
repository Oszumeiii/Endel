/// Định dạng [Duration] thành chuỗi `MM:SS` hoặc `HH:MM:SS`.
String formatFocusTime(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  String two(int value) => value.toString().padLeft(2, '0');

  if (hours > 0) {
    return '${two(hours)}:${two(minutes)}:${two(seconds)}';
  }
  return '${two(minutes)}:${two(seconds)}';
}