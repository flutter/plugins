package io.flutter.plugins.firebasemlvision;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class DetectorException extends Exception {
  private final String detectorExceptionType;
  private final String detectorExceptionDescription;
  private final Object exceptionData;

  public DetectorException(
      String detectorExceptionType, String detectorExceptionDescription, Object exceptionData) {
    super(detectorExceptionType + ": " + detectorExceptionDescription);
    this.detectorExceptionType = detectorExceptionType;
    this.detectorExceptionDescription = detectorExceptionDescription;
    this.exceptionData = exceptionData;
  }

  public void sendError(@NonNull EventChannel.EventSink eventSink) {
    eventSink.error(detectorExceptionType, detectorExceptionDescription, exceptionData);
  }

  public void sendError(MethodChannel.Result result) {
    result.error(detectorExceptionType, detectorExceptionDescription, exceptionData);
  }
}
