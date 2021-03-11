package io.flutter.plugins.camera;

import androidx.annotation.Nullable;
import io.flutter.plugin.common.MethodChannel;
import java.io.File;

/**
 * Holds the temporary things associated with an image capture like the file, the dartMessenger to
 * send errors, and the dart result to send the image file back as the capture result.
 */
public class PictureCaptureRequest {
  /** The file for saving the capture. */
  public final File file;
  /**
   * The timeout related to pre-capture focusing. Will ensure that we reach focus in a reasonable
   * amount of time.
   */
  public final Timeout preCaptureFocusing;
  /**
   * The the timeout related to pre-capture metering. Will ensure that we reach a metering result in
   * a reasonable amount of time.
   */
  public final Timeout preCaptureMetering;
  /** Dart method chanel result. */
  private final MethodChannel.Result result;

  /**
   * Factory method to create a picture capture request
   *
   * @param result dart result.
   * @param file file to capture into.
   * @param preCaptureFocusingTimeoutMs focusing timeout milliseconds.
   * @param preCaptureMeteringTimeoutMs metering timeout milliseconds.
   * @return returns a new PictureCaptureRequest.
   */
  static PictureCaptureRequest create(
      MethodChannel.Result result,
      File file,
      long preCaptureFocusingTimeoutMs,
      long preCaptureMeteringTimeoutMs) {
    return new PictureCaptureRequest(
        result, file, preCaptureFocusingTimeoutMs, preCaptureMeteringTimeoutMs);
  }

  /** Create a new picture capture request */
  private PictureCaptureRequest(
      MethodChannel.Result result,
      File file,
      long preCaptureFocusingTimeoutMs,
      long preCaptureMeteringTimeoutMs) {
    this.result = result;
    this.file = file;
    this.preCaptureFocusing = Timeout.create(preCaptureFocusingTimeoutMs);
    this.preCaptureMetering = Timeout.create(preCaptureMeteringTimeoutMs);
  }

  /**
   * Send the picture result back to Flutter. Returns the image path.
   *
   * @param absolutePath
   */
  public void finish(String absolutePath) {
    result.success(absolutePath);
  }

  /**
   * Return an error to dart for this picture capture request.
   *
   * @param errorCode error code.
   * @param errorMessage error message.
   * @param errorDetails error details.
   */
  public void error(
      String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
    result.error(errorCode, errorMessage, errorDetails);
  }
}
