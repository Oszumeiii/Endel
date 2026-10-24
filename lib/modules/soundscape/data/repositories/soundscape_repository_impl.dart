import '../../domain/entities/soundscape_item.dart';
import '../../domain/enums/soundscape_category.dart';
import '../../domain/repositories/soundscape_repository.dart';
import '../soundscape_registry.dart';

/// Triển khai SoundscapeRepository dựa trên SoundscapeRegistry
class SoundscapeRepositoryImpl implements SoundscapeRepository {
  const SoundscapeRepositoryImpl();

  @override
  List<SoundscapeItem> getAllSoundscapes() {
    return SoundscapeRegistry.allSoundscapes;
  }

  @override
  List<SoundscapeItem> getByCategory(SoundscapeCategory category) {
    return SoundscapeRegistry.getByCategory(category);
  }

  @override
  SoundscapeItem? getById(String id) {
    return SoundscapeRegistry.getById(id);
  }

  @override
  SoundscapeItem getDefaultSoundscape() {
    return SoundscapeRegistry.defaultSoundscape;
  }

  @override
  List<SoundscapeCategory> getAvailableCategories() {
    return SoundscapeRegistry.availableCategories;
  }
}
