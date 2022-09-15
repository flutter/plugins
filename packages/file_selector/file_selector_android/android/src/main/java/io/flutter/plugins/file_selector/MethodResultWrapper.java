// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.file_selector;

import android.os.Handler;
import android.os.Looper;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodChannel;

public class MethodResultWrapper implements MethodChannel.Result {
  private final MethodChannel.Result methodResult;
  private final Handler handler;

  MethodResultWrapper(MethodChannel.Result result) {
    methodResult = result;
    handler = new Handler(Looper.getMainLooper());
  }

  @Override
  public void success(final Object result) {
    handler.post(
        new Runnable() {
          @Override
          public void run() {
            methodResult.success(result);
          }
        });
  }

  @Override
  public void error(
      @NonNull final String errorCode, final String errorMessage, final Object errorDetails) {
    handler.post(
        new Runnable() {
          @Override
          public void run() {
            methodResult.error(errorCode, errorMessage, errorDetails);
          }
        });
  }

  @Override
  public void notImplemented() {
    handler.post(
        new Runnable() {
          @Override
          public void run() {
            methodResult.notImplemented();
          }
        });
  }
}
