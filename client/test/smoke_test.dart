import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asset_tuner/app.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/di/injectable.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    initDependencies();
  });

  testWidgets('App builds', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);
  });
}
