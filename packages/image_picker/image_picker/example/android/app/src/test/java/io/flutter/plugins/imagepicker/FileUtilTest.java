// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.content.Context;
import android.net.Uri;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.shadows.ShadowContentResolver;

import java.io.ByteArrayInputStream;

import androidx.test.core.app.ApplicationProvider;

import static java.nio.charset.StandardCharsets.UTF_8;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.robolectric.Shadows.shadowOf;

@RunWith(RobolectricTestRunner.class)
public class FileUtilTest {

    private Context context;
    private FileUtils fileUtils;
    ShadowContentResolver shadowContentResolver;

    @Before
    public void before() {
        context = ApplicationProvider.getApplicationContext();
        shadowContentResolver = shadowOf(context.getContentResolver());
        fileUtils = new FileUtils();
    }

    @Test
    public void FileUtil_GetPathFromUri() {
        Uri uri = Uri.parse("content://dummy/dummy.png");
        shadowContentResolver.registerInputStream(uri, new ByteArrayInputStream("imageStream".getBytes(UTF_8)));
        String path = fileUtils.getPathFromUri(context, uri);
        assertNotNull(path);
        // The correct path should contain below components.
        assertTrue(path.contains("image_picker"));
        assertTrue(path.contains("png"));
        assertTrue(path.contains("/cache/"));
    }
}
