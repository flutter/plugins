// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.os.Handler;
import android.os.Looper;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.MethodChannel;

class PictureCaptureRequest {

  enum State {
    idle,
    focusing,
    preCapture,
    waitingPreCaptureReady,
    capturing,
    finished,
    error,
  }

  private final Runnable timeoutCallback =
      new Runnable() {
        @Override
        public void run() {
          error("captureTimeout", "Picture capture request timed out", state.toString());
        }
      };

  private final MethodChannel.Result result;
  private final TimeoutHandler timeoutHandler;
  private State state;

  public PictureCaptureRequest(MethodChannel.Result result) {
    this(result, new TimeoutHandler());
  }

  public PictureCaptureRequest(MethodChannel.Result result, TimeoutHandler timeoutHandler) {
    this.result = result;
    this.state = State.idle;
    this.timeoutHandler = timeoutHandler;
  }

  public void setState(State state) {
    if (isFinished()) throw new IllegalStateException("Request has already been finished");
    this.state = state;
    if (state != State.idle && state != State.finished && state != State.error) {
      this.timeoutHandler.resetTimeout(timeoutCallback);
    } else {
      this.timeoutHandler.clearTimeout(timeoutCallback);
    }
  }

  public State getState() {
    return state;
  }

  public boolean isFinished() {
    return state == State.finished || state == State.error;
  }

  public void finish(String absolutePath) {
    if (isFinished()) throw new IllegalStateException("Request has already been finished");
    this.timeoutHandler.clearTimeout(timeoutCallback);
    result.success(absolutePath);
    state = State.finished;
  }

  public void error(
      String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
    if (isFinished()) throw new IllegalStateException("Request has already been finished");
    this.timeoutHandler.clearTimeout(timeoutCallback);
    result.error(errorCode, errorMessage, errorDetails);
    state = State.error;
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
