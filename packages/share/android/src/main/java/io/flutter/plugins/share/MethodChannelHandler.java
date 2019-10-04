// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.share;

import android.app.Activity;
import android.content.Intent;

import androidx.annotation.Nullable;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Handles the method channel for the plugin.
 */
public class MethodChannelHandler implements MethodChannel.MethodCallHandler {

    private Activity activity;

    /**
     * Constructs the MethodChannelHandler
     * @param activity can be null. Use {@link #setActivity(Activity)} to set it later if it is not available when constructing.
     */
    MethodChannelHandler(@Nullable Activity activity) {
        this.activity = activity;
    }

    /**
     * Sets the activity.
     * @param activity When the activity is available, use this method to set it. If activity becomes unavailable, use this method to set it to null.
     */
    public void setActivity(@Nullable Activity activity) {
        this.activity = activity;
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("share")) {
            if (!(call.arguments instanceof Map)) {
                throw new IllegalArgumentException("Map argument expected");
            }
            // Android does not support showing the share sheet at a particular point on screen.
            share((String) call.argument("text"), (String) call.argument("subject"));
            result.success(null);
        } else {
            result.notImplemented();
        }
    }

    private void share(String text, String subject) {
        if (text == null || text.isEmpty()) {
            throw new IllegalArgumentException("Non-empty text expected");
        }

        Intent shareIntent = new Intent();
        shareIntent.setAction(Intent.ACTION_SEND);
        shareIntent.putExtra(Intent.EXTRA_TEXT, text);
        shareIntent.putExtra(Intent.EXTRA_SUBJECT, subject);
        shareIntent.setType("text/plain");
        Intent chooserIntent = Intent.createChooser(shareIntent, null /* dialog title optional */);
        if (activity != null) {
            activity.startActivity(chooserIntent);
        } else {
            chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            activity.startActivity(chooserIntent);
        }
    }
}
