import '../../domain/entities/soundscape_item.dart';
import '../../domain/enums/soundscape_category.dart';

/// ─── ACTIVITY ───────────────────────────────────────────────────────────────
/// 📁 assets/audio/activity/ | Visual: kinetic flux | 135 BPM
const List<SoundscapeItem> activitySoundscapes = [
  SoundscapeItem(
    id: 'activity_countryside',
    title: 'Countryside Pace',
    subtitle: 'Invigorating rural ambiance for active moments',
    category: SoundscapeCategory.activity,
    audioFile: 'countryside.mp3',
    tags: ['countryside', 'walk', 'vitality'],
  ),
  SoundscapeItem(
    id: 'activity_florist',
    title: 'Florist Energy',
    subtitle: 'Fresh uplifting rhythm for daily vitality',
    category: SoundscapeCategory.activity,
    audioFile: 'florist.mp3',
    tags: ['fresh', 'energy', 'vitality'],
  ),
  SoundscapeItem(
    id: 'activity_morning_rain',
    title: 'Morning Rain Flow',
    subtitle: 'Crisp morning shower pacing physical activity',
    category: SoundscapeCategory.activity,
    audioFile: 'morning_rain.mp3',
    tags: ['morning', 'rain', 'stretch'],
  ),
  SoundscapeItem(
    id: 'activity_oceanside',
    title: 'Oceanside Surge',
    subtitle: 'Dynamic coastal waves keeping your tempo',
    category: SoundscapeCategory.activity,
    audioFile: 'oceanside.mp3',
    tags: ['ocean', 'surge', 'tempo'],
  ),
  SoundscapeItem(
    id: 'activity_revelation',
    title: 'Revelation Pulse',
    subtitle: 'High-spirited acoustic pulses for deep energy',
    category: SoundscapeCategory.activity,
    audioFile: 'revelation.mp3',
    tags: ['revelation', 'high-energy', 'workout'],
  ),
  SoundscapeItem(
    id: 'activity_kinetic',
    title: 'Kinetic Movement',
    subtitle: 'High-energy audio pulses keeping you grounded in motion',
    category: SoundscapeCategory.activity,
    audioFile: 'activity.wav',
    tags: ['workout', 'kinetic', 'fitness'],
  ),
];
