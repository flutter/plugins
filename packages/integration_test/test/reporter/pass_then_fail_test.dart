import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'utils.dart';

void main() async {
  test('when one test passes, then another fails', () async {
    final Map<String, Object> results = await run(_testMain);
    expect(results, hasLength(2));
    expect(results, containsPair('Passing test', isSuccess));
    expect(results, containsPair('Failing test', isFailure));
  });
}

void _testMain() {
  testWidgets('Passing test', (WidgetTester tester) async {
    expect(true, true);
  });

  testWidgets('Failing test', (WidgetTester tester) async {
    expect(false, true);
  });
}
