// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher.utils;

import android.content.Intent;

import org.mockito.ArgumentMatcher;

public class IntentDataMatcher extends ArgumentMatcher<Intent> {
    public IntentDataMatcher(String dataString) {
        this.dataString = dataString;
    }

    private final String dataString;

    @Override
    public boolean matches(Object intent) {
        return ((Intent) intent).getDataString().equals(dataString);
    }
}
