/// Các danh mục chủ đề chính của Endel (đối chiếu chuẩn từ https://endel.io)
enum SoundscapeCategory {
  relax(
    id: 'relax',
    label: 'Relax',
    bpmLabel: '60 BPM',
    circadianPhase: 'REST & RECHARGE',
    description: 'Calm your mind and create comfort',
  ),
  focus(
    id: 'focus',
    label: 'Focus',
    bpmLabel: '120 BPM',
    circadianPhase: 'COGNITIVE PEAK',
    description: 'Boosts productivity by helping you concentrate for longer',
  ),
  sleep(
    id: 'sleep',
    label: 'Sleep',
    bpmLabel: '48 BPM',
    circadianPhase: 'MELATONIN RELEASE',
    description: 'Soothes you into a deep, restful sleep with soft textures',
  ),
  activity(
    id: 'activity',
    label: 'Activity',
    bpmLabel: '135 BPM',
    circadianPhase: 'PHYSICAL FLOW',
    description: 'Powers your movement with sounds to keep you present and grounded',
  ),
  move(
    id: 'move',
    label: 'Move',
    bpmLabel: '140 BPM',
    circadianPhase: 'PHYSICAL CADENCE',
    description: 'Adaptive tempo pulses for walking, sports and commute',
  ),
  adhd(
    id: 'adhd',
    label: 'ADHD',
    bpmLabel: '110 BPM',
    circadianPhase: 'CALM & STEADY',
    description: 'Calms restless minds and supports steady attention',
  );

  const SoundscapeCategory({
    required this.id,
    required this.label,
    required this.bpmLabel,
    required this.circadianPhase,
    required this.description,
  });

  final String id;
  final String label;
  final String bpmLabel;
  final String circadianPhase;
  final String description;
}
