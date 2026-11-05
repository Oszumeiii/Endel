import '../enums/soundscape_category.dart';
import '../enums/wave_style.dart';
import 'visual_theme_config.dart';

/// Entity đại diện cho một track âm thanh trong Endel.
///
/// Cách thêm bài mới:
/// Chỉ cần khai báo tối thiểu: id, title, subtitle, category, audioFile (hoặc audioPath), tags.
class SoundscapeItem {
  const SoundscapeItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.audioFile,
    String? audioPath,
    this.themeOverride,
    VisualThemeConfig? themeConfig,
    this.isRemote = false,
    this.tags = const [],
  })  : _audioPath = audioPath,
        _themeConfig = themeConfig ?? themeOverride;

  final String id;
  final String title;
  final String subtitle;
  final SoundscapeCategory category;
  final String? audioFile;
  final String? _audioPath;
  final VisualThemeConfig? _themeConfig;
  final VisualThemeConfig? themeOverride;
  final bool isRemote;
  final List<String> tags;

  /// Đường dẫn đầy đủ tới file audio.
  String get audioPath {
    final explicitPath = _audioPath;
    if (explicitPath != null && explicitPath.isNotEmpty) {
      return explicitPath;
    }
    final file = audioFile;
    if (file != null && file.isNotEmpty) {
      return isRemote ? file : '${category.audioDir}$file';
    }
    return '';
  }

  /// Visual theme thực tế: themeConfig/themeOverride nếu có, ngược lại dùng default của category
  VisualThemeConfig get themeConfig =>
      _themeConfig ?? themeOverride ?? category.defaultTheme;

  WaveStyle get waveStyle => themeConfig.waveStyle;

  SoundscapeItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    SoundscapeCategory? category,
    String? audioFile,
    String? audioPath,
    VisualThemeConfig? Function()? themeOverride,
    bool? isRemote,
    List<String>? tags,
  }) {
    return SoundscapeItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      audioFile: audioFile ?? this.audioFile,
      audioPath: audioPath ?? _audioPath,
      themeOverride:
          themeOverride != null ? themeOverride() : this.themeOverride,
      isRemote: isRemote ?? this.isRemote,
      tags: tags ?? this.tags,
    );
  }
}
