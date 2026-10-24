import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rvc_mobile_application/modules/soundscape/presentation/widgets/endel_countdown_clock.dart';
import 'package:rvc_mobile_application/modules/soundscape/presentation/widgets/endel_timer_selector.dart';
import 'package:rvc_mobile_application/modules/soundscape/presentation/widgets/soundscape_category_bar.dart';
import 'package:rvc_mobile_application/modules/soundscape/domain/enums/soundscape_category.dart';

void main() {
  testWidgets('play control invokes the playback callback', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EndelCountdownClock(
            displayTime: '15:00',
            isPlaying: false,
            isLoading: false,
            progress: 1,
            onTogglePlayPause: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Play'));
    expect(tapped, isTrue);
  });

  testWidgets('timer preset returns its selected duration', (tester) async {
    Duration? selectedDuration;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EndelTimerSelector(
            selectedDuration: const Duration(minutes: 45),
            onDurationSelected: (duration) => selectedDuration = duration,
          ),
        ),
      ),
    );

    await tester.tap(find.text('15M'));
    expect(selectedDuration, const Duration(minutes: 15));
  });

  testWidgets('category bar exposes all soundscape modes', (tester) async {
    var selectedCategory = SoundscapeCategory.relax;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SoundscapeCategoryBar(
              selectedCategory: selectedCategory,
              onCategorySelected: (category) {
                setState(() => selectedCategory = category);
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('RELAX'), findsOneWidget);
    expect(find.text('FOCUS'), findsOneWidget);
    expect(find.text('SLEEP'), findsOneWidget);
    expect(find.text('ACTIVITY'), findsOneWidget);
    expect(find.text('MOVE'), findsOneWidget);
    expect(find.text('ADHD'), findsOneWidget);

    await tester.tap(find.text('FOCUS'));
    await tester.pumpAndSettle();
    expect(selectedCategory, SoundscapeCategory.focus);
  });

  testWidgets('custom timer accepts its upper bound', (tester) async {
    Duration? selectedDuration;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EndelTimerSelector(
            selectedDuration: const Duration(minutes: 45),
            onDurationSelected: (duration) => selectedDuration = duration,
          ),
        ),
      ),
    );

    await tester.tap(find.text('CUSTOM'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('480 MIN'));
    await tester.tap(find.text('APPLY'));
    await tester.pumpAndSettle();

    expect(selectedDuration, const Duration(hours: 8));
  });
}
