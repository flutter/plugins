// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;

import androidx.annotation.Nullable;

import java.io.File;

import io.flutter.Log;
import io.flutter.plugin.common.MethodChannel;

/**
 * This is where we store the state of the camera. This conveniently
 * allows us to handle capture results and send results back to flutter
 * so we can handle errors.
 * <p>
 * It also handles a capture timeout so if a capture doesn't happen within
 * 5 seconds it will return an error to dart.
 */
class PictureCaptureRequest {

    /**
     * Timeout for the pre-capture sequence.
     */
    private static final long PRECAPTURE_TIMEOUT_MS = 1000;

    /**
     * This is the output file for the curent capture. The file is created
     * in Camera and passed here as reference to it.
     */
    final File mFile;

    /**
     * Dart method chanel result.
     */
    private final MethodChannel.Result result;

    /**
     * Timeout handler.
     */
    private final TimeoutHandler timeoutHandler;
    /**
     * To send errors back to dart
     */
    private final DartMessenger dartMessenger;
    /**
     * The time that the most recent capture started at. Used to check if
     * the current capture request has timed out.
     */
    private long preCaptureStartTime;
    /**
     * The state of this picture capture request.
     */
    private PictureCaptureRequestState state = PictureCaptureRequestState.STATE_IDLE;

    private final Runnable timeoutCallback =
            () -> {
                error("captureTimeout", "Picture capture request timed out", state.toString());
                setState(PictureCaptureRequestState.STATE_ERROR);
            };


    /**
     * Constructor to create a picture capture request.
     *
     * @param result
     * @param mFile
     */
    public PictureCaptureRequest(MethodChannel.Result result, File mFile, DartMessenger dartMessenger) {
        this.result = result;
        this.timeoutHandler = new TimeoutHandler();
        this.mFile = mFile;
        this.dartMessenger = dartMessenger;
    }

    /**
     * Constructor for unit tests where we can mock the timeout handler
     */
    public PictureCaptureRequest(MethodChannel.Result result, File mFile, DartMessenger dartMessenger, TimeoutHandler timeoutHandler) {
        this.result = result;
        this.timeoutHandler = timeoutHandler;
        this.mFile = mFile;
        this.dartMessenger = dartMessenger;
    }

    /**
     * Return the current state of this picture capture request.
     *
     * @return
     */
    public PictureCaptureRequestState getState() {
        return state;
    }

    /**
     * Set the picture capture request to a new state.
     *
     * @param newState
     */
    public void setState(PictureCaptureRequestState newState) {
        Log.i("Camera", "====> PictureCaptureRequest setState: " + newState);

        // Once a request is finished, that's it for its lifecycle.
        if (state == PictureCaptureRequestState.STATE_FINISHED) {
            dartMessenger.sendCameraErrorEvent("Request has already been finished");
            return;
        }

        final PictureCaptureRequestState oldState = state;
        state = newState;
        onStateChange(oldState);
    }

    public boolean isFinished() {
        return state == PictureCaptureRequestState.STATE_FINISHED ||
                state == PictureCaptureRequestState.STATE_ERROR;
    }

    /**
     * Send the picture result back to Flutter. Returns the image path.
     *
     * @param absolutePath
     */
    public void finish(String absolutePath) {
        if (state == PictureCaptureRequestState.STATE_ERROR) {
            return;
        }

        if (isFinished()) throw new IllegalStateException("Request has already been finished");
        setState(PictureCaptureRequestState.STATE_FINISHED);
        Log.i("Camera", "PictureCaptureRequest finish");
        result.success(absolutePath);
    }

    public void error(
            String errorCode, @Nullable String errorMessage,
            @Nullable Object errorDetails) {
        if (state == PictureCaptureRequestState.STATE_ERROR) {
            return;
        }

        if (isFinished()) throw new IllegalStateException("Request has already been finished");
        setState(PictureCaptureRequestState.STATE_ERROR);
        result.error(errorCode, errorMessage, errorDetails);
    }

    /**
     * Check if the timeout for the pre-capture sequence has been reached.
     *
     * @return true if the timeout is reached; otherwise false is returned.
     */
    public boolean hitPreCaptureTimeout() {
        Log.i("Camera", "hitPreCaptureTimeout | Time elapsed: " + (SystemClock.elapsedRealtime() - preCaptureStartTime));
        return (SystemClock.elapsedRealtime() - preCaptureStartTime) > PRECAPTURE_TIMEOUT_MS;
    }

    /**
     * Sets the time the pre-capture sequence started.
     */
    public void setPreCaptureStartTime() {
        preCaptureStartTime = SystemClock.elapsedRealtime();
    }

    /**
     * Handle new state changes.
     */
    private void onStateChange(PictureCaptureRequestState oldState) {
        switch (state) {
            case STATE_CAPTURING:
            case STATE_WAITING_FOCUS:
            case STATE_WAITING_PRECAPTURE_START:
                timeoutHandler.resetTimeout(timeoutCallback);
                break;

            case STATE_WAITING_PRECAPTURE_DONE:
                setPreCaptureStartTime();
                timeoutHandler.resetTimeout(timeoutCallback);
                break;

            case STATE_IDLE:
            case STATE_FINISHED:
            case STATE_ERROR:
                timeoutHandler.clearTimeout(timeoutCallback);
                break;
        }
    }

    /**
     * This handles the timeout for capture requests so they return within a
     * reasonable amount of time.
     */
    static class TimeoutHandler {
        private static final int REQUEST_TIMEOUT = 5000;
        private final Handler handler;

        TimeoutHandler() {
            this.handler = new Handler(Looper.getMainLooper());
        }

        public void resetTimeout(Runnable runnable) {
            Log.i("Camear", "PictureCaptureRequest | resetting timeout");
            clearTimeout(runnable);
            handler.postDelayed(runnable, REQUEST_TIMEOUT);
        }

        public void clearTimeout(Runnable runnable) {
            handler.removeCallbacks(runnable);
        }
    }
}
