import '../../domain/entities/soundscape_item.dart';
import '../../domain/enums/soundscape_category.dart';

/// ─── RELAX ──────────────────────────────────────────────────────────────────
/// 📁 assets/audio/relax/ | Visual: organic waves | 60 BPM
const List<SoundscapeItem> relaxSoundscapes = [
  SoundscapeItem(
    id: 'relax_countryside',
    title: 'Countryside',
    subtitle: 'Serene rural soundscape for peace of mind',
    category: SoundscapeCategory.relax,
    audioFile: 'countryside.mp3',
    tags: ['countryside', 'nature', 'serenity'],
  ),
  SoundscapeItem(
    id: 'relax_first_light_particles',
    title: 'First Light Particles',
    subtitle: 'Luminous acoustic textures unwinding physical tension',
    category: SoundscapeCategory.relax,
    audioFile: 'first_light_particles.wav',
    tags: ['light', 'particles', 'ambient'],
  ),
  SoundscapeItem(
    id: 'relax_morning_rain',
    title: 'Morning Rain',
    subtitle: 'Gentle rainfall easing tension and sensory fatigue',
    category: SoundscapeCategory.relax,
    audioFile: 'morning_rain.mp3',
    tags: ['rain', 'morning', 'water'],
  ),
  SoundscapeItem(
    id: 'relax_oceanside',
    title: 'Oceanside',
    subtitle: 'Calming rhythmic tides soothing the nervous system',
    category: SoundscapeCategory.relax,
    audioFile: 'oceanside.mp3',
    tags: ['ocean', 'waves', 'sea'],
  ),
  SoundscapeItem(
    id: 'relax_pretty',
    title: 'Pretty Melody',
    subtitle: 'Soft melodic warmth for restorative calm',
    category: SoundscapeCategory.relax,
    audioFile: 'pretty.mp3',
    tags: ['melody', 'warmth', 'peace'],
  ),
  SoundscapeItem(
    id: 'relax_rainy_forest',
    title: 'Rainy Forest',
    subtitle: 'Immersive canopy showers evoking tranquility',
    category: SoundscapeCategory.relax,
    audioFile: 'rainy_forest.mp3',
    tags: ['forest', 'rain', 'canopy'],
  ),
  SoundscapeItem(
    id: 'relax_relaxing',
    title: 'Relaxing Chords',
    subtitle: 'Pure gentle relaxation frequencies',
    category: SoundscapeCategory.relax,
    audioFile: 'relaxing.mp3',
    tags: ['calm', 'rest', 'soothing'],
  ),
  SoundscapeItem(
    id: 'relax_somnium',
    title: 'Somnium Calm',
    subtitle: 'Dreamlike acoustic veil drifting into deep relaxation',
    category: SoundscapeCategory.relax,
    audioFile: 'somnium.mp3',
    tags: ['dream', 'somnium', 'drift'],
  ),
  SoundscapeItem(
    id: 'relax_song_2',
    title: 'Harmonic Flow',
    subtitle: 'Subtle harmony centering body and mind',
    category: SoundscapeCategory.relax,
    audioFile: 'song_2.mp3',
    tags: ['harmony', 'balance', 'zen'],
  ),
];
