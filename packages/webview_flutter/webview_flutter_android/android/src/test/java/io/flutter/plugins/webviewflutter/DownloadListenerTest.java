// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

import android.webkit.DownloadListener;
import io.flutter.plugins.webviewflutter.DownloadListenerHostApiImpl.DownloadListenerCreator;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.DownloadListenerFlutterApi;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class DownloadListenerTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public DownloadListenerFlutterApi mockFlutterApi;

  InstanceManager testInstanceManager;
  DownloadListenerHostApiImpl testHostApiImpl;
  DownloadListener testDownloadListener;

  @Before
  public void setUp() {
    testInstanceManager = new InstanceManager();

    final DownloadListenerCreator downloadListenerCreator =
        new DownloadListenerCreator() {
          @Override
          DownloadListener createDownloadListener(
              Long instanceId, DownloadListenerFlutterApi downloadListenerFlutterApi) {
            testDownloadListener =
                super.createDownloadListener(instanceId, downloadListenerFlutterApi);
            return testDownloadListener;
          }
        };

    testHostApiImpl =
        new DownloadListenerHostApiImpl(
            testInstanceManager, downloadListenerCreator, mockFlutterApi);
    testHostApiImpl.create(0L);
  }

  @Test
  public void postMessage() {
    testDownloadListener.onDownloadStart(
        "https://www.google.com", "userAgent", "contentDisposition", "mimetype", 54);
    verify(mockFlutterApi)
        .onDownloadStart(
            eq(0L),
            eq("https://www.google.com"),
            eq("userAgent"),
            eq("contentDisposition"),
            eq("mimetype"),
            eq(54L),
            any());
  }
}
