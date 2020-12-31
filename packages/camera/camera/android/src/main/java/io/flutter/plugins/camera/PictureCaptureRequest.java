package io.flutter.plugins.camera;

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

  private final MethodChannel.Result result;
  private State state;

  public PictureCaptureRequest(MethodChannel.Result result) {
    this.result = result;
    state = State.idle;
  }

  public void setState(State state) {
    if (isFinished()) throw new IllegalStateException("Request has already been finished");
    this.state = state;
  }

  public State getState() {
    return state;
  }

  public boolean isFinished() {
    return state == State.finished || state == State.error;
  }

  public void finish(String absolutePath) {
    if (isFinished()) throw new IllegalStateException("Request has already been finished");
    result.success(absolutePath);
    state = State.finished;
  }

  public void error(
      String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
    if (isFinished()) throw new IllegalStateException("Request has already been finished");
    result.error(errorCode, errorMessage, errorDetails);
    state = State.error;
  }
}
