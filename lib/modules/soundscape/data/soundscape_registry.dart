import '../domain/entities/soundscape_item.dart';
import '../domain/enums/soundscape_category.dart';

/// ============================================================================
/// 🎵 SOUNDSCAPE REGISTRY – nơi duy nhất cần chỉnh khi thêm nhạc/mục mới.
///
/// ─── THÊM BÀI NHẠC MỚI (chỉ 4-6 dòng) ──────────────────────────────────────
///  1. Đặt file âm thanh vào assets/audio/{category}/
///  2. Thêm SoundscapeItem vào đúng section bên dưới:
///
///    SoundscapeItem(
///      id: 'relax_rain',          // unique id
///      title: 'Rain Forest',      // tên hiển thị
///      subtitle: 'Mô tả ngắn',   // dòng mô tả
///      category: SoundscapeCategory.relax,
///      audioFile: 'rain.wav',     // chỉ tên file, path tự sinh
///      tags: ['nature', 'rain'],  // tags (optional)
///    ),
///
/// ─── THÊM CATEGORY MỚI ───────────────────────────────────────────────────────
///  1. Tạo thư mục assets/audio/{new_category}/
///  2. Khai báo trong pubspec.yaml:  - assets/audio/{new_category}/
///  3. Thêm giá trị + defaultTheme vào enum SoundscapeCategory (soundscape_category.dart)
///  4. Thêm section SoundscapeItem bên dưới.
/// ============================================================================
class SoundscapeRegistry {
  SoundscapeRegistry._();

  static const List<SoundscapeItem> _registry = [
    // ─── RELAX ──────────────────────────────────────────────────────────────
    // 📁 assets/audio/relax/   |  Visual: organic waves  |  60 BPM
    SoundscapeItem(
      id: 'relax_serenity',
      title: 'Serenity Waves',
      subtitle: 'Soft ambient textures for a calmer nervous system',
      category: SoundscapeCategory.relax,
      audioFile: 'relax.wav',
      tags: ['calm', 'ambient', 'alpha waves'],
    ),
    SoundscapeItem(
      id: 'relax_ripples',
      title: 'Tranquil Ripples',
      subtitle: 'Gentle droplet soundscapes for effortless easing',
      category: SoundscapeCategory.relax,
      audioFile: 'relax.wav',
      tags: ['peace', 'water', 'tranquility'],
    ),

    // ─── FOCUS ──────────────────────────────────────────────────────────────
    // 📁 assets/audio/focus/   |  Visual: geometric      |  120 BPM
    SoundscapeItem(
      id: 'focus_clarity',
      title: 'Deep Focus',
      subtitle: 'Steady ambient sound for high cognitive endurance',
      category: SoundscapeCategory.focus,
      audioFile: 'focus.wav',
      tags: ['work', 'study', 'coding', 'pomodoro'],
    ),
    SoundscapeItem(
      id: 'focus_state',
      title: 'Flow State',
      subtitle: 'A quiet backdrop for deep creative immersion',
      category: SoundscapeCategory.focus,
      audioFile: 'focus.wav',
      tags: ['hyperfocus', 'flow', 'creativity'],
    ),

    // ─── SLEEP ──────────────────────────────────────────────────────────────
    // 📁 assets/audio/sleep/   |  Visual: breathing aura |  48 BPM
    SoundscapeItem(
      id: 'sleep_nightfall',
      title: 'Deep Sleep',
      subtitle: 'Soft, slow acoustic textures guiding into restorative sleep',
      category: SoundscapeCategory.sleep,
      audioFile: 'sleep.wav',
      tags: ['night', 'delta', 'rest', 'melatonin'],
    ),
    SoundscapeItem(
      id: 'sleep_drift',
      title: 'Nightfall Drift',
      subtitle: 'Gentle cyclical textures for evening wind-down',
      category: SoundscapeCategory.sleep,
      audioFile: 'sleep.wav',
      tags: ['dream', 'calm night', 'lullaby'],
    ),

    // ─── ACTIVITY ───────────────────────────────────────────────────────────
    // 📁 assets/audio/activity/ | Visual: kinetic flux   |  135 BPM
    SoundscapeItem(
      id: 'activity_kinetic',
      title: 'Kinetic Movement',
      subtitle: 'High-energy audio pulses keeping you grounded in motion',
      category: SoundscapeCategory.activity,
      audioFile: 'activity.wav',
      tags: ['workout', 'kinetic', 'fitness'],
    ),
    SoundscapeItem(
      id: 'activity_flow',
      title: 'Dynamic Flow',
      subtitle: 'Balanced rhythmic pulses for steady physical momentum',
      category: SoundscapeCategory.activity,
      audioFile: 'activity.wav',
      tags: ['yoga', 'stretch', 'rhythm', 'breath'],
    ),

    // ─── MOVE ───────────────────────────────────────────────────────────────
    // 📁 assets/audio/move/    |  Visual: radar pulse    |  140 BPM
    SoundscapeItem(
      id: 'move_stride',
      title: 'Urban Stride',
      subtitle: 'Adaptive tempo pulses for walking and active commuting',
      category: SoundscapeCategory.move,
      audioFile: 'move.wav',
      tags: ['walk', 'commute', 'tempo', 'outdoor'],
    ),

    // ─── ADHD ───────────────────────────────────────────────────────────────
    // 📁 assets/audio/adhd/    |  Visual: constellation  |  110 BPM
    SoundscapeItem(
      id: 'adhd_balance',
      title: 'Clarity Orbit',
      subtitle: 'Resonant acoustic balance masking distractions and centering mind',
      category: SoundscapeCategory.adhd,
      audioFile: 'adhd.wav',
      tags: ['adhd', 'neurodiversity', 'calm focus', 'anchor'],
    ),
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
