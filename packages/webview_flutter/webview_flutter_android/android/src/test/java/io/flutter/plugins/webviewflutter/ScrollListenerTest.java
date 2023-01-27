// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

import io.flutter.plugins.webviewflutter.ScrollListenerHostApiImpl.ScrollListenerCreator;
import io.flutter.plugins.webviewflutter.ScrollListenerHostApiImpl.ScrollListenerImpl;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class ScrollListenerTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public ScrollListenerFlutterApiImpl mockFlutterApi;

  InstanceManager instanceManager;
  ScrollListenerHostApiImpl hostApiImpl;
  ScrollListenerImpl scrollListener;

  @Before
  public void setUp() {
    instanceManager = InstanceManager.open(identifier -> {});

    final ScrollListenerCreator ScrollListenerCreator =
        new ScrollListenerCreator() {
          @Override
          public ScrollListenerImpl createScrollListener(ScrollListenerFlutterApiImpl flutterApi) {
            scrollListener = super.createScrollListener(flutterApi);
            return scrollListener;
          }
        };

    hostApiImpl =
        new ScrollListenerHostApiImpl(instanceManager, ScrollListenerCreator, mockFlutterApi);
    hostApiImpl.create(0L);
  }

  @After
  public void tearDown() {
    instanceManager.close();
  }

  @Test
  public void scrollPosChange() {
    scrollListener.onScrollPosChange(1, 2);
    verify(mockFlutterApi).onScrollPosChange(eq(scrollListener), eq(1L), eq(2L), any());
  }
}
