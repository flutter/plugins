// This is a Flutter widget test can take a screenshot.
//
// NOTE: Screenshots are only supported on Web for now.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:integration_test/integration_test.dart';

import 'example_integration_io_extended.dart'
    if (dart.library.html) 'example_integration_web_extended.dart' as tests;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  tests.main();
}
