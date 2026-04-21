import 'package:asset_tuner/core/utils/external_url_launcher.dart';
import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  group('launchExternalUrl', () {
    testWidgets('uses external launcher for valid URL', (tester) async {
      Uri? capturedUri;
      LaunchMode? capturedMode;

      await _pumpHarness(
        tester,
        url: 'https://example.com/terms',
        launcher: (uri, {mode = LaunchMode.platformDefault}) async {
          capturedUri = uri;
          capturedMode = mode;
          return true;
        },
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(capturedUri, Uri.parse('https://example.com/terms'));
      expect(capturedMode, LaunchMode.externalApplication);
      expect(find.text(_errorMessage), findsNothing);
    });

    testWidgets('shows snackbar for invalid URL', (tester) async {
      var launcherCalled = false;

      await _pumpHarness(
        tester,
        url: 'not a valid uri',
        launcher: (uri, {mode = LaunchMode.platformDefault}) async {
          launcherCalled = true;
          return true;
        },
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(launcherCalled, isFalse);
      expect(find.text(_errorMessage), findsOneWidget);
    });

    testWidgets('shows snackbar when launcher returns false', (tester) async {
      await _pumpHarness(
        tester,
        url: 'https://example.com/privacy',
        launcher: (uri, {mode = LaunchMode.platformDefault}) async => false,
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text(_errorMessage), findsOneWidget);
    });
  });
}

const _errorMessage = 'Could not open URL';

Future<void> _pumpHarness(
  WidgetTester tester, {
  required String url,
  required ExternalUrlLauncher launcher,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: lightTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () => launchExternalUrl(
                  context,
                  url: url,
                  errorMessage: _errorMessage,
                  launcher: launcher,
                ),
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    ),
  );
}
