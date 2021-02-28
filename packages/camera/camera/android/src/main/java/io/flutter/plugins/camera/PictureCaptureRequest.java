// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.Nullable;

import java.io.File;

import io.flutter.Log;
import io.flutter.plugin.common.MethodChannel;

class PictureCaptureRequest {

  private final Runnable timeoutCallback =
      new Runnable() {
        @Override
        public void run() {
          error("captureTimeout", "Picture capture request timed out", state.toString());
        }
      };

  private final MethodChannel.Result result;
  private final TimeoutHandler timeoutHandler;
  private CaptureSessionState state = CaptureSessionState.IDLE;

  /**
   * This is the output file for our picture.
   */
  File mFile;

  public PictureCaptureRequest(MethodChannel.Result result) {
    this(result, new TimeoutHandler());
  }

  public PictureCaptureRequest(MethodChannel.Result result, TimeoutHandler timeoutHandler) {
    this.result = result;
    this.timeoutHandler = timeoutHandler;
  }

  public void setState(CaptureSessionState state) {
    if (isFinished()) throw new IllegalStateException("Request has already been finished");
    this.state = state;
    if (state != CaptureSessionState.IDLE && state != CaptureSessionState.FINISHED && state != CaptureSessionState.ERROR) {
      this.timeoutHandler.resetTimeout(timeoutCallback);
    } else {
      this.timeoutHandler.clearTimeout(timeoutCallback);
    }
  }

  public CaptureSessionState getState() {
    return state;
  }

  public boolean isFinished() {
    return state == CaptureSessionState.FINISHED || state == CaptureSessionState.ERROR;
  }

  public void finish(String absolutePath) {
    if (isFinished()) throw new IllegalStateException("Request has already been finished");
    Log.i("Camera", "PictureCaptureRequest finish");
    this.timeoutHandler.clearTimeout(timeoutCallback);
    result.success(absolutePath);
    setState(CaptureSessionState.FINISHED);
  }

  public void error(
      String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
    if (isFinished()) throw new IllegalStateException("Request has already been finished");
    this.timeoutHandler.clearTimeout(timeoutCallback);
    result.error(errorCode, errorMessage, errorDetails);
    setState(CaptureSessionState.ERROR);
  }

  static class TimeoutHandler {
    private static final int REQUEST_TIMEOUT = 5000;
    private final Handler handler;

    TimeoutHandler() {
      this.handler = new Handler(Looper.getMainLooper());
    }

    public void resetTimeout(Runnable runnable) {
      clearTimeout(runnable);
      handler.postDelayed(runnable, REQUEST_TIMEOUT);
    }

    public void clearTimeout(Runnable runnable) {
      handler.removeCallbacks(runnable);
    }
  }
}
