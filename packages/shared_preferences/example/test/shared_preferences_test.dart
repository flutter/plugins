import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences_example/main.dart';

void main() {
  testWidgets('SharedPreferences example widget test',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.text('SharedPreferences Demo'), findsOneWidget);
  });
}
