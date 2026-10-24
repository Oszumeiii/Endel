import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rvc_mobile_application/modules/soundscape/domain/entities/soundscape_item.dart';
import 'package:rvc_mobile_application/modules/soundscape/domain/entities/visual_theme_config.dart';
import 'package:rvc_mobile_application/modules/soundscape/domain/enums/soundscape_category.dart';
import 'package:rvc_mobile_application/modules/soundscape/domain/enums/wave_style.dart';
import 'package:rvc_mobile_application/modules/soundscape/domain/services/audio_player_service.dart';
import 'package:rvc_mobile_application/modules/soundscape/presentation/widgets/soundscape_hud_header.dart';

void main() {
  testWidgets('category label does not overflow beside a long visual mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: SoundscapeHudHeader(
                soundscape: const SoundscapeItem(
                  id: 'activity',
                  title: 'Activity',
                  subtitle: 'Activity soundscape',
                  category: SoundscapeCategory.activity,
                  audioPath: 'assets/audio/move.wav',
                  themeConfig: VisualThemeConfig(waveStyle: WaveStyle.activity),
                ),
                audioStatus: AudioEngineStatus.idle,
                activeWaveStyle: WaveStyle.constellation,
                isAutoVisual: false,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('ACTIVITY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
