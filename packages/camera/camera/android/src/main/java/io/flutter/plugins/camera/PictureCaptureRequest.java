// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.MethodChannel;
import java.io.File;

/**
 * This is where we store the state of the camera. This conveniently allows us to handle capture
 * results and send results back to flutter so we can handle errors.
 *
 * <p>It also handles a capture timeout so if a capture doesn't happen within 5 seconds it will
 * return an error to dart.
 */
class PictureCaptureRequest {

  /** Timeout for the pre-capture sequence. */
  private static final long PRECAPTURE_TIMEOUT_MS = 1000;

  /**
   * This is the output file for the curent capture. The file is created in Camera and passed here
   * as reference to it.
   */
  final File file;

  /** Dart method chanel result. */
  private final MethodChannel.Result result;

  /** Timeout handler. */
  private final TimeoutHandler timeoutHandler;
  /** To send errors back to dart */
  private final DartMessenger dartMessenger;
  /**
   * The time that the most recent capture started at. Used to check if the current capture request
   * has timed out.
   */
  private long preCaptureStartTime;

  private final Runnable timeoutCallback =
      () -> {
        error("captureTimeout", "Picture capture request timed out", null);
      };

  /**
   * Factory method to create a picture capture request.
   *
   * @param result
   * @param file
   */
  static PictureCaptureRequest create(
      MethodChannel.Result result, File file, DartMessenger dartMessenger) {
    return new PictureCaptureRequest(result, file, dartMessenger);
  }

  /**
   * Private constructor to create a picture capture request.
   *
   * @param result
   * @param file
   */
  private PictureCaptureRequest(
      MethodChannel.Result result, File file, DartMessenger dartMessenger) {

    this.result = result;
    this.file = file;
    this.dartMessenger = dartMessenger;
    this.timeoutHandler = TimeoutHandler.create();
  }

  /**
   * Send the picture result back to Flutter. Returns the image path.
   *
   * @param absolutePath
   */
  public void finish(String absolutePath) {
    result.success(absolutePath);
  }

  public void error(
      String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
    result.error(errorCode, errorMessage, errorDetails);
  }

  /**
   * Check if the timeout for the pre-capture sequence has been reached.
   *
   * @return true if the timeout is reached; otherwise false is returned.
   */
  public boolean hitPreCaptureTimeout() {
    // Log.i("Camera", "hitPreCaptureTimeout | Time elapsed: " + (SystemClock.elapsedRealtime() - preCaptureStartTime));
    return (SystemClock.elapsedRealtime() - preCaptureStartTime) > PRECAPTURE_TIMEOUT_MS;
  }

  /** Sets the time the pre-capture sequence started. */
  public void setPreCaptureStartTime() {
    preCaptureStartTime = SystemClock.elapsedRealtime();
  }

  /**
   * This handles the timeout for capture requests so they return within a reasonable amount of
   * time.
   */
  static class TimeoutHandler {
    private static final int REQUEST_TIMEOUT = 5000;
    private final Handler handler;

    public static TimeoutHandler create() {
      return new TimeoutHandler();
    }

    private TimeoutHandler() {
      this.handler = new Handler(Looper.getMainLooper());
    }

    public void resetTimeout(Runnable runnable) {
      // Log.i("Camera", "PictureCaptureRequest | resetting timeout");
      clearTimeout(runnable);
      handler.postDelayed(runnable, REQUEST_TIMEOUT);
    }

    public void clearTimeout(Runnable runnable) {
      handler.removeCallbacks(runnable);
    }
  }
}
