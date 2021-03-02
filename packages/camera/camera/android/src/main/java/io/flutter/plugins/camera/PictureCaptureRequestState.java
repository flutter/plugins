package io.flutter.plugins.camera;

/**
 * This describes the state of the current picture capture request. This is different from the
 * camera state because this simply says whether or not the current capture is finished and if there
 * was an error.
 *
 * <p>We have to separate this state because a picture capture request only exists in the context of
 * a dart call where we have a result to return.
 */
public enum PictureCaptureRequestState {
  /** Not doing anything yet. */
  STATE_IDLE,

  /** Starting and waiting for autofocus to complete. */
  STATE_WAITING_FOCUS,

  /** Start performing autoexposure. */
  STATE_WAITING_PRECAPTURE_START,

  /** waiting for autoexposure to complete. */
  STATE_WAITING_PRECAPTURE_DONE,

  /** Picture is being captured. */
  STATE_CAPTURING,

  /** Picture capture is finished. */
  STATE_FINISHED,

  /** An error occurred. */
  STATE_ERROR,
}
