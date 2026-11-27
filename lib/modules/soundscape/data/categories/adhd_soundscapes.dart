import '../../domain/entities/soundscape_item.dart';
import '../../domain/enums/soundscape_category.dart';

/// ─── ADHD ───────────────────────────────────────────────────────────────────
/// 📁 assets/audio/adhd/ | Visual: constellation | 110 BPM
const List<SoundscapeItem> adhdSoundscapes = [
  SoundscapeItem(
    id: 'adhd_chill_loopable',
    title: 'Chill Loopable',
    subtitle: 'Seamless soothing loops to anchor wandering thoughts',
    category: SoundscapeCategory.adhd,
    audioFile: 'chillloopable.mp3',
    tags: ['adhd', 'anchor', 'loop'],
  ),
  SoundscapeItem(
    id: 'adhd_mindstream',
    title: 'Mind Stream',
    subtitle: 'Continuous harmonic flow easing restless attention',
    category: SoundscapeCategory.adhd,
    audioFile: 'dst_mindstream.mp3',
    tags: ['flow', 'clarity', 'mind'],
  ),
  SoundscapeItem(
    id: 'adhd_into_the_caves',
    title: 'Into the Caves',
    subtitle: 'Deep resonant tones masking external distractions',
    category: SoundscapeCategory.adhd,
    audioFile: 'into_the_caves.mp3',
    tags: ['deep', 'focus', 'masking'],
  ),
  SoundscapeItem(
    id: 'adhd_persistence',
    title: 'Persistence Steady',
    subtitle: 'Stable grounding frequency for sustained clarity',
    category: SoundscapeCategory.adhd,
    audioFile: 'persistence.mp3',
    tags: ['grounding', 'clarity', 'steady'],
  ),
  SoundscapeItem(
    id: 'adhd_relaxing',
    title: 'Relaxing Orbit',
    subtitle: 'Gentle auditory cocoon for sensory regulation',
    category: SoundscapeCategory.adhd,
    audioFile: 'relaxing.mp3',
    tags: ['cocoon', 'sensory', 'orbit'],
  ),
];
