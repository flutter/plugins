import 'package:flutter/material.dart';

import 'package:e2e/e2e.dart';
import 'package:e2e/common.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  Future<Map<String, dynamic>> request;

  group('Test E2E binding', () {
    final WidgetsBinding binding = E2EWidgetsFlutterBinding.ensureInitialized();
    assert(binding is E2EWidgetsFlutterBinding);
    final E2EWidgetsFlutterBinding e2eBinding =
        binding as E2EWidgetsFlutterBinding;

    setUp(() {
      request = e2eBinding.callback(<String, String>{
        'command': 'request_data',
      });
    });

    testWidgets('Run E2E app', (WidgetTester tester) async {
      runApp(MaterialApp(
        home: Text('Test'),
      ));
      expect(tester.binding, e2eBinding);
      e2eBinding.reportData = <String, dynamic>{'answer': 42};
    });

    testWidgets('setSurfaceSize works', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Center(child: Text('Test'))));

      final Size windowCenter = tester.binding.window.physicalSize /
          tester.binding.window.devicePixelRatio /
          2;
      final double windowCenterX = windowCenter.width;
      final double windowCenterY = windowCenter.height;

      Offset widgetCenter = tester.getRect(find.byType(Text)).center;
      expect(widgetCenter.dx, windowCenterX);
      expect(widgetCenter.dy, windowCenterY);

      await tester.binding.setSurfaceSize(const Size(200, 300));
      await tester.pump();
      widgetCenter = tester.getRect(find.byType(Text)).center;
      expect(widgetCenter.dx, 100);
      expect(widgetCenter.dy, 150);

      await tester.binding.setSurfaceSize(null);
      await tester.pump();
      widgetCenter = tester.getRect(find.byType(Text)).center;
      expect(widgetCenter.dx, windowCenterX);
      expect(widgetCenter.dy, windowCenterY);
    });
  });

  tearDownAll(() async {
    // This part is outside the group so that `request` has been compeleted as
    // part of the `tearDownAll` registerred in the group during
    // `E2EWidgetsFlutterBinding` initialization.
    final Map<String, dynamic> response =
        (await request)['response'] as Map<String, dynamic>;
    final String message = response['message'] as String;
    Response result = Response.fromJson(message);
    assert(result.data['answer'] == 42);
  });
}
