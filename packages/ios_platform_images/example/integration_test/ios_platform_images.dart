import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:ios_platform_images_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'load ios bundled image',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Flutter logo'), findsOneWidget);
    },
  );

  testWidgets(
    'load ios system image',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Smiling face'), findsOneWidget);
    },
  );
}
