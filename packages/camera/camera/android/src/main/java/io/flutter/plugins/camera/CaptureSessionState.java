package io.flutter.plugins.camera;

public enum CaptureSessionState {
    IDLE, // Idle
    FOCUSING, // Focusing
    STATE_WAITING_PRECAPTURE, // Precapture
    STATE_WAITING_NON_PRECAPTURE, // Waiting precapture ready
    CAPTURING, // Capturing
    FINISHED, // Finished
    ERROR, // Error
}
