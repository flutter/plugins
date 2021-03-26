// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.android_platform_images;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;

import java.io.ByteArrayOutputStream;

import androidx.core.content.ContextCompat;

class DrawableImageLoader extends ImageLoader {
    DrawableImageLoader(Context context) {
        this.appContext = context;
    }

    public byte[] loadBitmapDrawable(String name, int quality) {
        byte[] buffer = null;
        Drawable drawable = null;
        try {
            Integer id = AndroidPlatformImagesPlugin.resourceMap.get(name);
            if (id == null) {
                String type = "drawable";
                id = appContext.getResources().getIdentifier(name, type, appContext.getPackageName());
            }
            if (id <= 0) {
                return buffer;
            }
            drawable = ContextCompat.getDrawable(appContext, id);
        } catch (Exception ignore) {}

        if (drawable instanceof BitmapDrawable) {
            Bitmap bitmap = ((BitmapDrawable) drawable).getBitmap();
            if (bitmap != null) {
                ExposedByteArrayOutputStream stream = new ExposedByteArrayOutputStream();
                bitmap.compress(Bitmap.CompressFormat.PNG, quality, stream);
                 buffer = stream.buffer();
            }
        }

        return buffer;
    }

    /**
     * avoid {@link ByteArrayOutputStream#toByteArray()} with a duplicate copy.
     */
    static final class ExposedByteArrayOutputStream extends ByteArrayOutputStream {
        byte[] buffer() {
            return buf;
        }
    }
}
