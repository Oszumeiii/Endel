import 'package:flutter/material.dart';
import 'wave_style.dart';
import '../entities/visual_theme_config.dart';

/// ============================================================================
/// Các danh mục chủ đề chính của Endel (đối chiếu chuẩn từ https://endel.io)
///
/// ─── THÊM CATEGORY MỚI ───────────────────────────────────────────────────────
///  Bước 1 (file này): Thêm giá trị enum mới kèm đủ các thuộc tính.
///  Bước 2 (pubspec.yaml): Thêm dòng  - assets/audio/{new_category}/
///  Bước 3 (soundscape_registry.dart): Thêm SoundscapeEntry với category mới.
///
///  Chỉ cần 2 file lib + pubspec là đủ, không cần sửa thêm chỗ nào khác!
/// ─────────────────────────────────────────────────────────────────────────────
enum SoundscapeCategory {
  relax(
    id: 'relax',
    label: 'Relax',
    bpmLabel: '60 BPM',
    circadianPhase: 'REST & RECHARGE',
    description: 'Calm your mind and create comfort',
    defaultTheme: VisualThemeConfig(
      waveStyle: WaveStyle.organic,
      primaryColor: Color(0xFFF0F4F8),
      accentColor: Color(0xFF88A0B8),
      waveSpeed: 0.9,
      layerCount: 3,
      deformationIntensity: 1.0,
    ),
  ),
  focus(
    id: 'focus',
    label: 'Focus',
    bpmLabel: '120 BPM',
    circadianPhase: 'COGNITIVE PEAK',
    description: 'Boosts productivity by helping you concentrate for longer',
    defaultTheme: VisualThemeConfig(
      waveStyle: WaveStyle.geometric,
      primaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF90A4AE),
      waveSpeed: 1.2,
      layerCount: 4,
      deformationIntensity: 1.1,
    ),
  ),
  sleep(
    id: 'sleep',
    label: 'Sleep',
    bpmLabel: '48 BPM',
    circadianPhase: 'MELATONIN RELEASE',
    description: 'Soothes you into a deep, restful sleep with soft textures',
    defaultTheme: VisualThemeConfig(
      waveStyle: WaveStyle.breathing,
      primaryColor: Color(0xFFB0BEC5),
      accentColor: Color(0xFF37474F),
      waveSpeed: 0.5,
      layerCount: 3,
      deformationIntensity: 0.75,
    ),
  ),
  activity(
    id: 'activity',
    label: 'Activity',
    bpmLabel: '135 BPM',
    circadianPhase: 'PHYSICAL FLOW',
    description: 'Powers your movement with sounds to keep you present and grounded',
    defaultTheme: VisualThemeConfig(
      waveStyle: WaveStyle.activity,
      primaryColor: Color(0xFFECEFF1),
      accentColor: Color(0xFF607D8B),
      waveSpeed: 1.4,
      layerCount: 4,
      deformationIntensity: 1.2,
    ),
  ),
  move(
    id: 'move',
    label: 'Move',
    bpmLabel: '140 BPM',
    circadianPhase: 'PHYSICAL CADENCE',
    description: 'Adaptive tempo pulses for walking, sports and commute',
    defaultTheme: VisualThemeConfig(
      waveStyle: WaveStyle.pulse,
      primaryColor: Color(0xFFECEFF1),
      accentColor: Color(0xFF78909C),
      waveSpeed: 1.3,
      layerCount: 4,
      deformationIntensity: 1.2,
    ),
  ),
  adhd(
    id: 'adhd',
    label: 'ADHD',
    bpmLabel: '110 BPM',
    circadianPhase: 'CALM & STEADY',
    description: 'Calms restless minds and supports steady attention',
    defaultTheme: VisualThemeConfig(
      waveStyle: WaveStyle.constellation,
      primaryColor: Color(0xFFE8EAF6),
      accentColor: Color(0xFF7986CB),
      waveSpeed: 1.15,
      layerCount: 4,
      deformationIntensity: 1.0,
    ),
  );

  const SoundscapeCategory({
    required this.id,
    required this.label,
    required this.bpmLabel,
    required this.circadianPhase,
    required this.description,
    required this.defaultTheme,
  });

  final String id;
  final String label;
  final String bpmLabel;
  final String circadianPhase;
  final String description;

  /// Visual theme mặc định cho tất cả bài trong category này.
  /// Có thể bị override ở từng SoundscapeEntry nếu cần.
  final VisualThemeConfig defaultTheme;

  /// Đường dẫn thư mục audio của category: assets/audio/{id}/
  String get audioDir => 'assets/audio/$id/';
}
