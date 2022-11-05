// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.content.Context;

import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class WebViewHostApiImplTest {
    @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

    @Mock Context mockContext;

    @Mock WebViewHostApiImpl.WebViewProxy mockWebViewProxy;

    // This can happen because of scenarios in https://github.com/flutter/flutter/issues/114500
    // In short, if an instance is already disposed, we should still be able to call loadUrl
    // without crashing the app
    @Test
    public void loadUrlWithoutInstance() {
        InstanceManager instanceManager = InstanceManager.open(identifier -> {});
        final WebViewHostApiImpl api = new WebViewHostApiImpl(instanceManager, mockWebViewProxy, mockContext, null);

        api.loadUrl(42L, "", null);
    }
}
