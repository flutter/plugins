// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.android_platform_images;

import android.content.Context;

abstract class ImageLoader {
    protected Context appContext;

    public void dispose() {
        appContext = null;
    }
}
