import '../enums/soundscape_category.dart';
import 'visual_theme_config.dart';

/// Entity đại diện cho một chủ đề / track âm thanh trong Endel
class SoundscapeItem {
  const SoundscapeItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.audioPath,
    required this.themeConfig,
    this.isRemote = false,
    this.tags = const [],
  });

  /// Định danh duy nhất (ví dụ: 'relax_water', 'focus_pulse')
  final String id;

  /// Tên hiển thị (ví dụ: 'Deep Relax', 'Focus Horizon')
  final String title;

  /// Mô tả ngắn (ví dụ: 'Calm alpha waves for deep peace')
  final String subtitle;

  /// Phân loại chế độ (Relax, Focus, Sleep, Move)
  final SoundscapeCategory category;

  /// Đường dẫn asset (ví dụ: 'assets/audio/relax.wav') hoặc URL streaming trực tuyến
  final String audioPath;

  /// Cấu hình hoạt ảnh hiển thị
  final VisualThemeConfig themeConfig;

  /// Cờ xác định audioPath là URL mạng hay Local Asset
  final bool isRemote;

  /// Các tag phân loại thêm nếu cần
  final List<String> tags;

  SoundscapeItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    SoundscapeCategory? category,
    String? audioPath,
    VisualThemeConfig? themeConfig,
    bool? isRemote,
    List<String>? tags,
  }) {
    return SoundscapeItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      audioPath: audioPath ?? this.audioPath,
      themeConfig: themeConfig ?? this.themeConfig,
      isRemote: isRemote ?? this.isRemote,
      tags: tags ?? this.tags,
    );
  }
}
