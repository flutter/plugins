import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:url_launcher_example/main.dart';

void main() {
  final MockUrlLauncher mock = MockUrlLauncher();
  UrlLauncherPlatform.instance = mock;

  testWidgets('Can open URLs', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    const String defaultUrl = 'https://www.cylog.org/headers/';
    when(mock.canLaunch(defaultUrl)).thenAnswer((_) => Future.value(true));
    const Map<String, String> defaultHeaders = {
      'my_header_key': 'my_header_value'
    };
    verifyNever(mock.launch(defaultUrl,
        useSafariVC: false,
        useWebView: false,
        enableDomStorage: false,
        enableJavaScript: false,
        universalLinksOnly: false,
        headers: defaultHeaders));

    Finder browserlaunchBtn =
        find.widgetWithText(RaisedButton, 'Launch in browser');
    expect(browserlaunchBtn, findsOneWidget);
    await tester.tap(browserlaunchBtn);

    verify(mock.launch(defaultUrl,
            useSafariVC: false,
            useWebView: false,
            enableDomStorage: false,
            enableJavaScript: false,
            universalLinksOnly: false,
            headers: defaultHeaders))
        .called(1);
  });
}

class MockUrlLauncher extends Mock
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {}
