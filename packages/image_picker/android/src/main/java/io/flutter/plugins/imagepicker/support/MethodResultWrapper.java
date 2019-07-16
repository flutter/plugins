package io.flutter.plugins.imagepicker.support;

import android.os.Handler;
import android.os.Looper;
import io.flutter.plugin.common.MethodChannel.Result;

// MethodChannel.Result wrapper that responds on the platform thread.
public class MethodResultWrapper implements Result {
  private Result methodResult;
  private Handler handler;

  public MethodResultWrapper(Result result) {
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
    final String errorCode, final String errorMessage, final Object errorDetails) {
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