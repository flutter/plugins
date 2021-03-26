// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.android_platform_images;

import android.content.Context;
import android.content.res.AssetManager;

import java.io.IOException;
import java.io.InputStream;

class AssetsImageLoader extends ImageLoader {
    AssetsImageLoader(Context context) {
        this.appContext = context;
    }

    /**
     * @param path location of assets images.
     */
    public byte[] loadImage(String path) {
        byte[] buffer = null;
        AssetManager assetManager = appContext.getAssets();
        InputStream inputStream;
        try {
            inputStream = assetManager.open(path);
            buffer = new byte[inputStream.available()];
            //noinspection ResultOfMethodCallIgnored
            inputStream.read(buffer);
        } catch (IOException ignored){ }
        return buffer;
    }
}
