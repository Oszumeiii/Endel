import '../../domain/entities/soundscape_item.dart';
import '../../domain/enums/soundscape_category.dart';

/// ─── FOCUS ──────────────────────────────────────────────────────────────────
/// 📁 assets/audio/focus/ | Visual: geometric | 120 BPM
const List<SoundscapeItem> focusSoundscapes = [
  SoundscapeItem(
    id: 'focus_cup_of_tea',
    title: 'A Cup of Tea',
    subtitle: 'Warm acoustic clarity for concentrated deep work',
    category: SoundscapeCategory.focus,
    audioFile: 'a_cup_of_tea.mp3',
    tags: ['tea', 'clarity', 'study'],
  ),
  SoundscapeItem(
    id: 'focus_bartender',
    title: 'Bartender',
    subtitle: 'Subtle rhythmic pulse for effortless focus',
    category: SoundscapeCategory.focus,
    audioFile: 'bartender.mp3',
    tags: ['lounge', 'rhythm', 'coding'],
  ),
  SoundscapeItem(
    id: 'focus_cat_caffe',
    title: 'Cat Café',
    subtitle: 'Cozy ambient backdrop keeping distractions at bay',
    category: SoundscapeCategory.focus,
    audioFile: 'cat_caffe.mp3',
    tags: ['cafe', 'cozy', 'flow'],
  ),
  SoundscapeItem(
    id: 'focus_cue',
    title: 'Cue Pulse',
    subtitle: 'Minimalist precision tones for task execution',
    category: SoundscapeCategory.focus,
    audioFile: 'cue.mp3',
    tags: ['precision', 'minimal', 'pomodoro'],
  ),
  SoundscapeItem(
    id: 'focus_florist',
    title: 'Florist',
    subtitle: 'Light organic textures for creative problem solving',
    category: SoundscapeCategory.focus,
    audioFile: 'florist.mp3',
    tags: ['creative', 'fresh', 'flow'],
  ),
  SoundscapeItem(
    id: 'focus_clarity',
    title: 'Deep Focus',
    subtitle: 'Steady ambient sound for high cognitive endurance',
    category: SoundscapeCategory.focus,
    audioFile: 'focus.wav',
    tags: ['work', 'study', 'coding', 'pomodoro'],
  ),
];
