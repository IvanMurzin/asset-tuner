import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/presentation/overview/widget/tour_target_highlight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const overlayKey = ValueKey<String>('tour_target_highlight_overlay');

  Widget testApp({required Widget child}) {
    return MaterialApp(
      theme: lightTheme,
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('keeps the same size in inactive and active states', (tester) async {
    var isActive = false;

    await tester.pumpWidget(
      testApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TourTargetHighlight(
                  isActive: isActive,
                  child: const SizedBox(width: 180, height: 72),
                ),
                TextButton(
                  onPressed: () => setState(() => isActive = !isActive),
                  child: const Text('toggle'),
                ),
              ],
            );
          },
        ),
      ),
    );

    final target = find.byType(TourTargetHighlight);
    final sizeBefore = tester.getSize(target);

    await tester.tap(find.text('toggle'));
    await tester.pump();
    final sizeDuring = tester.getSize(target);

    await tester.pump(const Duration(milliseconds: 220));
    final sizeAfter = tester.getSize(target);

    expect(sizeDuring, equals(sizeBefore));
    expect(sizeAfter, equals(sizeBefore));
  });

  testWidgets('does not block taps on the wrapped child', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      testApp(
        child: TourTargetHighlight(
          isActive: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => taps++,
            child: const SizedBox(width: 180, height: 72),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TourTargetHighlight));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('shows active overlay and hides it after deactivate animation', (tester) async {
    var isActive = false;

    await tester.pumpWidget(
      testApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TourTargetHighlight(
                  isActive: isActive,
                  child: const SizedBox(width: 180, height: 72),
                ),
                TextButton(
                  onPressed: () => setState(() => isActive = !isActive),
                  child: const Text('toggle'),
                ),
              ],
            );
          },
        ),
      ),
    );

    expect(find.byKey(overlayKey), findsNothing);

    await tester.tap(find.text('toggle'));
    await tester.pump();
    expect(find.byKey(overlayKey), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('toggle'));
    await tester.pump();
    expect(find.byKey(overlayKey), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 220));
    expect(find.byKey(overlayKey), findsNothing);
  });
}
