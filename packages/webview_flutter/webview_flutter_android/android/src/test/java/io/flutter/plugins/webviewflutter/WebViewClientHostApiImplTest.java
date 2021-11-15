// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import org.junit.Test;

public class WebViewClientHostApiImplTest {

  @Test
  public void
  WebViewClientImpl_doUpdateVisitedHistory_shouldCallOnUrlChangedEvent() {
    WebViewClientFlutterApiImpl mockFlutterApi = mock(WebViewClientFlutterApiImpl.class);
    WebViewClientHostApiImpl.WebViewClientImpl webViewClient = new WebViewClientHostApiImpl.WebViewClientImpl(mockFlutterApi, false);

    webViewClient.doUpdateVisitedHistory(null, "https://flutter.dev/", false);

    verify(mockFlutterApi)
            .onUrlChanged(eq(webViewClient), any(), eq("https://flutter.dev/"), any());
  }

  @Test
  public void
  WebViewClientCompatImpl_doUpdateVisitedHistory_shouldCallOnUrlChangedEvent() {
    WebViewClientFlutterApiImpl mockFlutterApi = mock(WebViewClientFlutterApiImpl.class);
    WebViewClientHostApiImpl.WebViewClientCompatImpl webViewClient = new WebViewClientHostApiImpl.WebViewClientCompatImpl(mockFlutterApi, false);

    webViewClient.doUpdateVisitedHistory(null, "https://flutter.dev/", false);

    verify(mockFlutterApi)
            .onUrlChanged(eq(webViewClient), any(), eq("https://flutter.dev/"), any());
  }
}
