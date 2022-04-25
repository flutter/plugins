// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_example/main.dart';

void main() {
  testWidgets('Test snackbar from ScaffoldMessenger',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WebViewExample(cookieManager: FakeCookieManager()),
      ),
    );
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });
}

class FakeCookieManager implements CookieManager {
  factory FakeCookieManager() {
    return _instance ??= FakeCookieManager._();
  }

  FakeCookieManager._();

  static FakeCookieManager? _instance;

  @override
  Future<bool> clearCookies() => throw UnimplementedError();

  @override
  Future<void> setCookie(WebViewCookie cookie) => throw UnimplementedError();
}
