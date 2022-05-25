// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_android/src/v4/android_webview_javascript_channel.dart';
import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';

import 'android_webview_javascript_channel_test.mocks.dart';

@GenerateMocks(<Type>[JavaScriptChannelParams])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('postMessage should call onMessageReceived', () {
    final JavaScriptChannelParams mockChannelParams =
        MockJavaScriptChannelParams();

    const JavaScriptMessage message =
        JavaScriptMessage(message: 'test message');

    when(mockChannelParams.name).thenReturn('test_name');
    when(mockChannelParams.onMessageReceived).thenReturn((_) => message);

    AndroidWebViewJavaScriptChannel.fromJavaScriptChannelParams(
            params: mockChannelParams)
        .postMessage('test message');

    verify(mockChannelParams.onMessageReceived(message)).called(1);
  });
}
