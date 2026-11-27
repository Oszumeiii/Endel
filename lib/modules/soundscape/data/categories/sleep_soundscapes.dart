import '../../domain/entities/soundscape_item.dart';
import '../../domain/enums/soundscape_category.dart';

/// ─── SLEEP ──────────────────────────────────────────────────────────────────
/// 📁 assets/audio/sleep/ | Visual: breathing aura | 48 BPM
const List<SoundscapeItem> sleepSoundscapes = [
  SoundscapeItem(
    id: 'sleep_ambient2_nautilus',
    title: 'Ambient Nautilus',
    subtitle: 'Oceanic depth textures guiding into deep sleep',
    category: SoundscapeCategory.sleep,
    audioFile: 'ambient2_nautilus.mp3',
    tags: ['nautilus', 'deep', 'delta'],
  ),
  SoundscapeItem(
    id: 'sleep_forest_ambience',
    title: 'Forest Ambience',
    subtitle: 'Whispering night canopy creating bedtime comfort',
    category: SoundscapeCategory.sleep,
    audioFile: 'forest_ambience.mp3',
    tags: ['forest', 'night', 'whisper'],
  ),
  SoundscapeItem(
    id: 'sleep_into_the_caves',
    title: 'Into the Caves',
    subtitle: 'Deep reverberant shelter for restorative sleep',
    category: SoundscapeCategory.sleep,
    audioFile: 'into_the_caves.mp3',
    tags: ['caves', 'reverberant', 'rest'],
  ),
  SoundscapeItem(
    id: 'sleep_persistence',
    title: 'Night Persistence',
    subtitle: 'Steady delta wave anchor through the night',
    category: SoundscapeCategory.sleep,
    audioFile: 'persistence.mp3',
    tags: ['anchor', 'delta', 'rest'],
  ),
  SoundscapeItem(
    id: 'sleep_somnium',
    title: 'Somnium Slumber',
    subtitle: 'Weightless melodic drift into unconscious rest',
    category: SoundscapeCategory.sleep,
    audioFile: 'somnium.mp3',
    tags: ['somnium', 'slumber', 'sleep'],
  ),
  SoundscapeItem(
    id: 'sleep_yoiyami_core_theme',
    title: 'Yoiyami Theme',
    subtitle: 'Gentle dusk lullaby preparing mind for deep slumber',
    category: SoundscapeCategory.sleep,
    audioFile: 'yoiyami_core_theme.wav',
    tags: ['yoiyami', 'lullaby', 'dusk'],
  ),
];
