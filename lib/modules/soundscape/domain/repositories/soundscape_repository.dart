import '../entities/soundscape_item.dart';
import '../enums/soundscape_category.dart';

/// Contract cho Repository cung cấp danh sách và chi tiết các chủ đề Soundscape
abstract class SoundscapeRepository {
  /// Lấy toàn bộ danh sách soundscape
  List<SoundscapeItem> getAllSoundscapes();

  /// Lọc soundscape theo danh mục (Relax, Focus, Sleep, Move)
  List<SoundscapeItem> getByCategory(SoundscapeCategory category);

  /// Lấy soundscape theo id
  SoundscapeItem? getById(String id);

  /// Lấy soundscape mặc định khi mở app
  SoundscapeItem getDefaultSoundscape();

  /// Lấy danh sách các danh mục khả dụng
  List<SoundscapeCategory> getAvailableCategories();
}
