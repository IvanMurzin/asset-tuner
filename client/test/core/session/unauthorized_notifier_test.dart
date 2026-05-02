import 'package:flutter_test/flutter_test.dart';

import 'package:asset_tuner/core/session/unauthorized_notifier.dart';

void main() {
  group('UnauthorizedNotifier', () {
    test('notify reaches subscriber', () async {
      final notifier = UnauthorizedNotifier();
      addTearDown(notifier.dispose);

      var ticks = 0;
      notifier.stream.listen((_) => ticks += 1);

      notifier.notifyUnauthorized();
      await Future<void>.delayed(Duration.zero);

      expect(ticks, 1);
    });

    test('broadcasts to multiple subscribers', () async {
      final notifier = UnauthorizedNotifier();
      addTearDown(notifier.dispose);

      var a = 0;
      var b = 0;
      notifier.stream.listen((_) => a += 1);
      notifier.stream.listen((_) => b += 1);

      notifier.notifyUnauthorized();
      await Future<void>.delayed(Duration.zero);

      expect(a, 1);
      expect(b, 1);
    });

    test('notify after dispose is a no-op (does not throw)', () async {
      final notifier = UnauthorizedNotifier();
      await notifier.dispose();

      // must not throw
      notifier.notifyUnauthorized();
    });
  });
}
