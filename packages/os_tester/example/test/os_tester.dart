import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:os_tester/os_tester.dart';
import 'package:os_tester_example/main.dart';

void main() {
  testWidgets('OSTester Example App', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    os.wait('Flutter website loads on startup', () {
      os.expect(os.label('Done'), os.visible);
    });
    os.tap(os.label('Done'));
    os.wait('Can navigate back to app', () {
      os.expect(os.label('TEST'), os.visible);
    });
    os.tap(os.label('TEST'));
    os.wait('Can relaunch browser', () {
      os.expect(os.label('Done'), os.visible);
    });
    // Can also use the WidgetTester at any point in the test
    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is Text &&
                           widget.data.startsWith('TEST'),
      ),
      findsOneWidget,
    );
  });
}
