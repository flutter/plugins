// Copyright 2019 The Chromium Authors. All rights reserved.
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

  private static final int REQUEST_TIMEOUT = 5000;
  private final Handler handler;
  private final MethodChannel.Result result;
  private State state;

  public PictureCaptureRequest(MethodChannel.Result result) {
    this.result = result;
    state = State.idle;
    this.handler = new Handler(Looper.getMainLooper());
  }

  public void setState(State state) {
    if (isFinished()) throw new IllegalStateException("Request has already been finished");
    this.state = state;
    if (state != State.idle && state != State.finished && state != State.error) {
      this.resetTimeout();
    } else {
      clearTimeout();
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
    clearTimeout();
    result.success(absolutePath);
    state = State.finished;
  }

  public void error(
      String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
    if (isFinished()) throw new IllegalStateException("Request has already been finished");
    clearTimeout();
    result.error(errorCode, errorMessage, errorDetails);
    state = State.error;
  }

  private final Runnable timeoutCallback =
      new Runnable() {
        @Override
        public void run() {
          error("captureTimeout", "Picture capture request timed out", state.toString());
        }
      };

  private void resetTimeout() {
    clearTimeout();
    handler.postDelayed(timeoutCallback, REQUEST_TIMEOUT);
  }

  private void clearTimeout() {
    handler.removeCallbacks(timeoutCallback);
  }
}
