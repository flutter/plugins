package io.flutter.plugins.firebase.cloud_firestore;

/** Thrown to indicate that a Flutter method invocation failed on the Flutter side. */
public class FlutterException extends RuntimeException {
  public final String code;
  public final Object details;

  FlutterException(String code, String message, Object details) {
    super(message);
    assert code != null;
    this.code = code;
    this.details = details;
  }
}
