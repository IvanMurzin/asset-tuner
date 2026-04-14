import 'package:asset_tuner/core/local_storage/guided_tour_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GuidedTourStorage', () {
    late GuidedTourStorage storage;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage = GuidedTourStorage();
    });

    test('returns false when completed flag is absent', () async {
      final completed = await storage.getCompleted();

      expect(completed, isFalse);
    });

    test('persists completed flag', () async {
      await storage.setCompleted();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('guided_tour_overview_completed'), isTrue);
      expect(await storage.getCompleted(), isTrue);
    });
  });
}
