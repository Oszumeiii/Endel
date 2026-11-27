import '../domain/entities/soundscape_item.dart';
import '../domain/enums/soundscape_category.dart';
import 'categories/activity_soundscapes.dart';
import 'categories/adhd_soundscapes.dart';
import 'categories/focus_soundscapes.dart';
import 'categories/move_soundscapes.dart';
import 'categories/relax_soundscapes.dart';
import 'categories/sleep_soundscapes.dart';

/// ============================================================================
/// 🎵 SOUNDSCAPE REGISTRY – Quản lý danh mục âm thanh tập trung
///
/// Registry tổng hợp các bài hát từ từng file thể loại riêng biệt nằm trong
/// thư mục `categories/` để tránh bùng nổ số dòng và dễ dàng bảo trì.
///
/// ─── 1. THÊM BÀI HÁT MỚI:
///   Mở file thể loại tương ứng trong `lib/modules/soundscape/data/categories/`
///   (ví dụ: `relax_soundscapes.dart`) và thêm `SoundscapeItem(...)` vào danh sách.
///
/// ─── 2. THÊM THỂ LOẠI MỚI:
///   Bước 1: Tạo file mới trong `categories/` (ví dụ: `meditation_soundscapes.dart`)
///   Bước 2: Import file đó và thêm `...meditationSoundscapes` vào `_registry` bên dưới.
/// ============================================================================
class SoundscapeRegistry {
  SoundscapeRegistry._();

  static const List<SoundscapeItem> _registry = [
    ...relaxSoundscapes,
    ...focusSoundscapes,
    ...sleepSoundscapes,
    ...activitySoundscapes,
    ...moveSoundscapes,
    ...adhdSoundscapes,
  ];

  static List<SoundscapeItem> get allSoundscapes => List.unmodifiable(_registry);

  static List<SoundscapeItem> getByCategory(SoundscapeCategory category) =>
      _registry.where((item) => item.category == category).toList();

  static SoundscapeItem? getById(String id) {
    try {
      return _registry.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  static SoundscapeItem get defaultSoundscape => _registry.first;

  static List<SoundscapeCategory> get availableCategories =>
      SoundscapeCategory.values;
}
