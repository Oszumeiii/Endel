import 'package:flutter/material.dart';

/// Listening timer with presets, custom duration, and continuous playback.
class EndelTimerSelector extends StatelessWidget {
  const EndelTimerSelector({
    super.key,
    required this.selectedDuration,
    required this.onDurationSelected,
  });

  final Duration? selectedDuration;
  final ValueChanged<Duration?> onDurationSelected;

  static const List<_PresetOption> _presets = [
    _PresetOption(label: '15M', duration: Duration(minutes: 15)),
    _PresetOption(label: '30M', duration: Duration(minutes: 30)),
    _PresetOption(label: '45M', duration: Duration(minutes: 45)),
    _PresetOption(label: '60M', duration: Duration(minutes: 60)),
  ];

  bool get _isPresetSelected =>
      _presets.any((opt) => opt.duration == selectedDuration);

  bool get _isEndless => selectedDuration == null;

  bool get _isCustom => !_isPresetSelected && !_isEndless;

  String get _customLabel {
    if (_isCustom && selectedDuration != null) {
      final mins = selectedDuration!.inMinutes;
      if (mins < 60) return '${mins}M';
      final hrs = mins ~/ 60;
      final remMins = mins % 60;
      return remMins == 0 ? '${hrs}H' : '${hrs}H${remMins}M';
    }
    return 'CUSTOM';
  }

  void _openCustomTimerSheet(BuildContext context) {
    showModalBottomSheet<Duration>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _EndelCustomTimerSheet(
        initialDuration: selectedDuration ?? const Duration(minutes: 25),
      ),
    ).then((chosen) {
      if (chosen != null) {
        onDurationSelected(chosen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Các preset mặc định: 15M, 30M, 45M, 60M
          ..._presets.map((opt) {
            final isSelected = selectedDuration == opt.duration;
            return _buildChip(
              label: opt.label,
              isSelected: isSelected,
              onTap: () => onDurationSelected(opt.duration),
            );
          }),

          // 2. Tùy chọn Custom thời gian (hẹn giờ tùy ý theo phút)
          _buildChip(
            label: _customLabel,
            isSelected: _isCustom,
            icon: Icons.tune_rounded,
            onTap: () => _openCustomTimerSheet(context),
          ),

          // Phát liên tục không giới hạn thời gian.
          _buildChip(
            label: '∞',
            isSelected: _isEndless,
            onTap: () => onDurationSelected(null),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.16)
                : const Color(0xFF141618),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.12),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 11,
                  color: isSelected ? Colors.white : const Color(0xFF777777),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF777777),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 1.0,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetOption {
  const _PresetOption({required this.label, required this.duration});
  final String label;
  final Duration duration;
}

/// BottomSheet chọn thời gian tùy chỉnh chuẩn phong cách tối giản Endel
class _EndelCustomTimerSheet extends StatefulWidget {
  const _EndelCustomTimerSheet({required this.initialDuration});

  final Duration initialDuration;

  @override
  State<_EndelCustomTimerSheet> createState() => _EndelCustomTimerSheetState();
}

class _EndelCustomTimerSheetState extends State<_EndelCustomTimerSheet> {
  late int _minutes;

  static const List<int> _quickMinutes = [5, 10, 20, 25, 90, 120, 480];

  @override
  void initState() {
    super.initState();
    _minutes = widget.initialDuration.inMinutes.clamp(1, 480);
  }

  String _formatDuration(int mins) {
    if (mins < 60) return '$mins MIN';
    final hrs = mins ~/ 60;
    final rem = mins % 60;
    if (rem == 0) return '$hrs HR';
    return '$hrs HR $rem MIN';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF101214),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thanh gạt ở đỉnh modal
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tiêu đề modal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SET SESSION DURATION',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    fontFamily: 'monospace',
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.close_rounded, color: Color(0xFF888888), size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Hiển thị thời lượng dạng số lớn
            Text(
              _formatDuration(_minutes),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w300,
                letterSpacing: 3.0,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 16),

            // Slider điều chỉnh thời gian
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                thumbColor: Colors.white,
                overlayColor: Colors.white.withValues(alpha: 0.1),
                trackHeight: 2.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
              ),
              child: Slider(
                value: _minutes.toDouble(),
                min: 5.0,
                max: 480.0,
                divisions: 95,
                onChanged: (val) {
                  setState(() {
                    _minutes = val.round();
                  });
                },
              ),
            ),
            const SizedBox(height: 12),

            // Các mốc thời lượng chọn nhanh.
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _quickMinutes.map((mins) {
                final isCurrent = _minutes == mins;
                final                 tag = '$mins MIN';

                return GestureDetector(
                  onTap: () => setState(() => _minutes = mins),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? Colors.white.withValues(alpha: 0.2)
                          : const Color(0xFF181B1D),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCurrent
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.1),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: isCurrent ? Colors.white : const Color(0xFF888888),
                        fontSize: 10,
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Nút Xác nhận
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, Duration(minutes: _minutes));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'APPLY',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
