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
                      waveStyle: WaveStyle.aurora,
                    ),
                    activeWaveStyle: WaveStyle.aurora,
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
                  waveStyle: WaveStyle.aurora,
                ),
                activeWaveStyle: WaveStyle.aurora,
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
                  waveStyle: WaveStyle.aurora,
                ),
                activeWaveStyle: WaveStyle.aurora,
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

    test('WaveStyle.fromId maps legacy ids safely without crashing', () {
      expect(WaveStyle.values.length, 7);
      expect(WaveStyle.fromId('geometric'), WaveStyle.constellation);
      expect(WaveStyle.fromId('dunes'), WaveStyle.nightSky);
      expect(WaveStyle.fromId('pulse'), WaveStyle.activity);
      expect(WaveStyle.fromId('night_sky'), WaveStyle.nightSky);
      expect(WaveStyle.fromId('cascade'), WaveStyle.cascade);
      expect(WaveStyle.fromId('bloom'), WaveStyle.bloom);
      expect(WaveStyle.fromId('unknown_id'), WaveStyle.aurora);
      expect(WaveStyle.fromId(null), WaveStyle.aurora);
    });

    testWidgets(
      'All painters render cleanly across phone, tablet sizes and layerCount=1 when paused',
      (tester) async {
        const sizes = [
          Size(320, 568),
          Size(1024, 768),
          Size(768, 1024),
        ];

        for (final size in sizes) {
          for (final style in WaveStyle.values) {
            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: EndelVisualizer(
                      isPlaying: false,
                      themeConfig: VisualThemeConfig(
                        waveStyle: style,
                        layerCount: 1,
                        primaryColor: const Color(0xFFE3F2FD),
                        accentColor: const Color(0xFF6488B4),
                      ),
                      activeWaveStyle: style,
                    ),
                  ),
                ),
              ),
            );
            await tester.pump(const Duration(milliseconds: 120));
            expect(tester.takeException(), isNull);
          }
        }
      },
    );
  });
}
