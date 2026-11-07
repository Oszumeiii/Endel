import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rvc_mobile_application/modules/soundscape/domain/entities/visual_theme_config.dart';
import 'package:rvc_mobile_application/modules/soundscape/domain/enums/wave_style.dart';
import 'package:rvc_mobile_application/modules/soundscape/presentation/painters/visual_painter_factory.dart';
import 'package:rvc_mobile_application/modules/soundscape/presentation/widgets/endel_visualizer.dart';

void main() {
  group('EndelVisualizer Widget & Painter Tests', () {
    test('VisualPainterFactory returns strategy for every WaveStyle', () {
      for (final style in WaveStyle.values) {
        final painter = VisualPainterFactory.getPainter(style);
        expect(painter, isNotNull);
      }
    });

    testWidgets('EndelVisualizer renders cleanly across all wave styles', (
      tester,
    ) async {
      for (final style in WaveStyle.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 360,
                height: 640,
                child: EndelVisualizer(
                  isPlaying: true,
                  themeConfig: VisualThemeConfig(
                    waveStyle: style,
                    primaryColor: const Color(0xFFF0F4F8),
                    accentColor: const Color(0xFF88A0B8),
                  ),
                  activeWaveStyle: style,
                ),
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(EndelVisualizer), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('EndelVisualizer transitions smoothly from playing to paused', (
      tester,
    ) async {
      var isPlaying = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SizedBox(
                  width: 360,
                  height: 640,
                  child: EndelVisualizer(
                    isPlaying: isPlaying,
                    themeConfig: const VisualThemeConfig(
                      waveStyle: WaveStyle.organic,
                    ),
                    activeWaveStyle: WaveStyle.organic,
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      isPlaying = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 640,
              child: EndelVisualizer(
                isPlaying: isPlaying,
                themeConfig: const VisualThemeConfig(
                  waveStyle: WaveStyle.organic,
                ),
                activeWaveStyle: WaveStyle.organic,
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 2000));

      expect(tester.takeException(), isNull);
    });

    testWidgets('EndelVisualizer responds to audio position & volume streams cleanly', (
      tester,
    ) async {
      final positionController = StreamController<Duration>.broadcast();
      final volumeController = StreamController<double>.broadcast();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 640,
              child: EndelVisualizer(
                isPlaying: true,
                themeConfig: const VisualThemeConfig(
                  waveStyle: WaveStyle.organic,
                ),
                activeWaveStyle: WaveStyle.organic,
                audioPositionStream: positionController.stream,
                audioVolumeStream: volumeController.stream,
                bpm: 120,
              ),
            ),
          ),
        ),
      );

      // Phát các nhịp audio
      positionController.add(const Duration(seconds: 1));
      volumeController.add(0.8);
      await tester.pump(const Duration(milliseconds: 100));

      positionController.add(const Duration(seconds: 2));
      volumeController.add(1.0);
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);

      await positionController.close();
      await volumeController.close();
    });
  });
}
