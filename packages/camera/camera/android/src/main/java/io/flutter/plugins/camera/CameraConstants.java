package io.flutter.plugins.camera;

public class CameraConstants {

    public static final AspectRatio DEFAULT_ASPECT_RATIO = AspectRatio.of(16, 9);

    public static final long AUTO_FOCUS_TIMEOUT_MS = 800;  //800ms timeout, Under normal circumstances need to a few hundred milliseconds

    public static final long OPEN_CAMERA_TIMEOUT_MS = 2500;  //2.5s

    public static final int FOCUS_HOLD_MILLIS = 3000;

    public static final float METERING_REGION_FRACTION = 0.1225f;

    public static final int ZOOM_REGION_DEFAULT = 1;

    public static final int FLASH_OFF = 0;
    public static final int FLASH_ON = 1;
    public static final int FLASH_TORCH = 2;
    public static final int FLASH_AUTO = 3;
    public static final int FLASH_RED_EYE = 4;

    public static final int FACING_BACK = 0;
    public static final int FACING_FRONT = 1;

}
