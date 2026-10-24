import 'package:flutter/material.dart';
import '../domain/entities/soundscape_item.dart';
import '../domain/entities/visual_theme_config.dart';
import '../domain/enums/soundscape_category.dart';
import '../domain/enums/wave_style.dart';

/// ============================================================================
/// 🎵 SOUNDSCAPE REGISTRY (SỔ ĐĂNG KÝ DANH MỤC ÂM THANH ENDEL)
/// Thêm soundscape, audio hoặc category mới chỉ cần thao tác tối thiểu:
/// Thêm 1 đối tượng SoundscapeItem vào danh sách _registry dưới đây.
/// ============================================================================
class SoundscapeRegistry {
  SoundscapeRegistry._();

  static final List<SoundscapeItem> _registry = [
    // -------------------------------------------------------------------------
    // 1. CHỦ ĐỀ: RELAX (Thư giãn, giảm stress, an thần)
    // -------------------------------------------------------------------------
    const SoundscapeItem(
      id: 'relax_serenity',
      title: 'Serenity Waves',
      subtitle: 'Soft ambient textures for a calmer nervous system',
      category: SoundscapeCategory.relax,
      audioPath: 'assets/audio/relax.wav',
      themeConfig: VisualThemeConfig(
        waveStyle: WaveStyle.organic,
        primaryColor: Color(0xFFF0F4F8),
        accentColor: Color(0xFF88A0B8),
        waveSpeed: 0.9,
        layerCount: 3,
        deformationIntensity: 1.0,
      ),
      tags: ['calm', 'ambient', 'alpha waves'],
    ),
    const SoundscapeItem(
      id: 'relax_ripples',
      title: 'Tranquil Ripples',
      subtitle: 'Gentle droplet soundscapes for effortless easing',
      category: SoundscapeCategory.relax,
      audioPath: 'assets/audio/relax.wav',
      themeConfig: VisualThemeConfig(
        waveStyle: WaveStyle.ripples,
        primaryColor: Color(0xFFE2E8F0),
        accentColor: Color(0xFF718096),
        waveSpeed: 0.8,
        layerCount: 4,
        deformationIntensity: 1.1,
      ),
      tags: ['peace', 'water', 'tranquility'],
    ),

    // -------------------------------------------------------------------------
    // 2. CHỦ ĐỀ: FOCUS (Tập trung làm việc, tư duy & lập trình)
    // -------------------------------------------------------------------------
    const SoundscapeItem(
      id: 'focus_clarity',
      title: 'Deep Focus',
      subtitle: 'Steady ambient sound for high cognitive endurance',
      category: SoundscapeCategory.focus,
      audioPath: 'assets/audio/focus.wav',
      themeConfig: VisualThemeConfig(
        waveStyle: WaveStyle.geometric,
        primaryColor: Color(0xFFFFFFFF),
        accentColor: Color(0xFF90A4AE),
        waveSpeed: 1.2,
        layerCount: 4,
        deformationIntensity: 1.2,
      ),
      tags: ['work', 'study', 'coding', 'pomodoro'],
    ),
    const SoundscapeItem(
      id: 'focus_state',
      title: 'Flow State',
      subtitle: 'A quiet backdrop for deep creative immersion',
      category: SoundscapeCategory.focus,
      audioPath: 'assets/audio/focus.wav',
      themeConfig: VisualThemeConfig(
        waveStyle: WaveStyle.geometric,
        primaryColor: Color(0xFFE0E0E0),
        accentColor: Color(0xFF78909C),
        waveSpeed: 1.05,
        layerCount: 3,
        deformationIntensity: 0.9,
      ),
      tags: ['hyperfocus', 'flow', 'creativity'],
    ),

    // -------------------------------------------------------------------------
    // 3. CHỦ ĐỀ: SLEEP (Ngủ sâu, thư giãn ban đêm)
    // -------------------------------------------------------------------------
    const SoundscapeItem(
      id: 'sleep_nightfall',
      title: 'Deep Sleep',
      subtitle: 'Soft, slow acoustic textures guiding into restorative sleep',
      category: SoundscapeCategory.sleep,
      audioPath: 'assets/audio/sleep.wav',
      themeConfig: VisualThemeConfig(
        waveStyle: WaveStyle.breathing,
        primaryColor: Color(0xFFB0BEC5),
        accentColor: Color(0xFF37474F),
        waveSpeed: 0.55,
        layerCount: 3,
        deformationIntensity: 0.8,
      ),
      tags: ['night', 'delta', 'rest', 'melatonin'],
    ),
    const SoundscapeItem(
      id: 'sleep_drift',
      title: 'Nightfall Drift',
      subtitle: 'Gentle cyclical textures for evening wind-down',
      category: SoundscapeCategory.sleep,
      audioPath: 'assets/audio/sleep.wav',
      themeConfig: VisualThemeConfig(
        waveStyle: WaveStyle.breathing,
        primaryColor: Color(0xFF90A4AE),
        accentColor: Color(0xFF263238),
        waveSpeed: 0.45,
        layerCount: 4,
        deformationIntensity: 0.7,
      ),
      tags: ['dream', 'calm night', 'lullaby'],
    ),

    // -------------------------------------------------------------------------
    // 4. CHỦ ĐỀ: ACTIVITY (Vận động thể chất, yoga, năng lượng thể thao)
    //    (Cập nhật chuẩn từ https://endel.io)
    // -------------------------------------------------------------------------
    const SoundscapeItem(
      id: 'activity_kinetic',
      title: 'Kinetic Movement',
      subtitle: 'High-energy audio pulses keeping you grounded in motion',
      category: SoundscapeCategory.activity,
      audioPath: 'assets/audio/move.wav',
      themeConfig: VisualThemeConfig(
        waveStyle: WaveStyle.activity,
        primaryColor: Color(0xFFECEFF1),
        accentColor: Color(0xFF607D8B),
        waveSpeed: 1.45,
        layerCount: 4,
        deformationIntensity: 1.3,
      ),
      tags: ['activity', 'workout', 'kinetic', 'fitness'],
    ),
    const SoundscapeItem(
      id: 'activity_flow',
      title: 'Dynamic Flow',
      subtitle: 'Balanced rhythmic pulses for steady physical momentum',
      category: SoundscapeCategory.activity,
      audioPath: 'assets/audio/move.wav',
      themeConfig: VisualThemeConfig(
        waveStyle: WaveStyle.activity,
        primaryColor: Color(0xFFCFD8DC),
        accentColor: Color(0xFF455A64),
        waveSpeed: 1.35,
        layerCount: 3,
        deformationIntensity: 1.1,
      ),
      tags: ['yoga', 'stretch', 'rhythm', 'breath'],
    ),

    // -------------------------------------------------------------------------
    // 5. CHỦ ĐỀ: MOVE (Đi bộ, dạo phố, di chuyển ngoài trời)
    // -------------------------------------------------------------------------
    const SoundscapeItem(
      id: 'move_stride',
      title: 'Urban Stride',
      subtitle: 'Adaptive tempo pulses for walking and active commuting',
      category: SoundscapeCategory.move,
      audioPath: 'assets/audio/move.wav',
      themeConfig: VisualThemeConfig(
        waveStyle: WaveStyle.pulse,
        primaryColor: Color(0xFFECEFF1),
        accentColor: Color(0xFF78909C),
        waveSpeed: 1.3,
        layerCount: 4,
        deformationIntensity: 1.2,
      ),
      tags: ['walk', 'commute', 'tempo', 'outdoor'],
    ),

    // -------------------------------------------------------------------------
    // 6. CHỦ ĐỀ: ADHD (Cân bằng sóng não, ổn định chú ý theo khoa học Endel)
    //    (Cập nhật chuẩn từ https://endel.io/adhd)
    // -------------------------------------------------------------------------
    const SoundscapeItem(
      id: 'adhd_balance',
      title: 'Clarity Orbit',
      subtitle: 'Resonant acoustic balance masking distractions and centering mind',
      category: SoundscapeCategory.adhd,
      audioPath: 'assets/audio/focus.wav',
      themeConfig: VisualThemeConfig(
        waveStyle: WaveStyle.constellation,
        primaryColor: Color(0xFFE8EAF6),
        accentColor: Color(0xFF7986CB),
        waveSpeed: 1.15,
        layerCount: 4,
        deformationIntensity: 1.0,
      ),
      tags: ['adhd', 'neurodiversity', 'calm focus', 'anchor'],
    ),
  ];

  /// Danh sách toàn bộ các soundscape đã đăng ký
  static List<SoundscapeItem> get allSoundscapes => List.unmodifiable(_registry);

  /// Lọc theo danh mục (Relax, Focus, Sleep, Activity, Move, ADHD)
  static List<SoundscapeItem> getByCategory(SoundscapeCategory category) {
    return _registry.where((item) => item.category == category).toList();
  }

  /// Tìm theo id
  static SoundscapeItem? getById(String id) {
    try {
      return _registry.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Soundscape mặc định khi người dùng mở ứng dụng lần đầu
  static SoundscapeItem get defaultSoundscape => _registry.first;

  /// Danh sách tất cả các danh mục có soundscapes
  static List<SoundscapeCategory> get availableCategories =>
      SoundscapeCategory.values;
}
