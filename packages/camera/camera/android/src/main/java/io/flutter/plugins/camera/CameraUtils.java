package io.flutter.plugins.camera;

import android.app.Activity;
import android.content.Context;
import android.graphics.ImageFormat;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.media.CamcorderProfile;
import android.util.Size;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugins.camera.types.ResolutionPreset;

/**
 * Provides various utilities for camera.
 */
public final class CameraUtils {

    private CameraUtils() {
    }

    static PlatformChannel.DeviceOrientation getDeviceOrientationFromDegrees(int degrees) {
        // Round to the nearest 90 degrees.
        degrees = (int) (Math.round(degrees / 90.0) * 90) % 360;
        // Determine the corresponding device orientation.
        switch (degrees) {
            case 90:
                return PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT;
            case 180:
                return PlatformChannel.DeviceOrientation.PORTRAIT_DOWN;
            case 270:
                return PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT;
            case 0:
            default:
                return PlatformChannel.DeviceOrientation.PORTRAIT_UP;
        }
    }

    static String serializeDeviceOrientation(PlatformChannel.DeviceOrientation orientation) {
        if (orientation == null)
            throw new UnsupportedOperationException("Could not serialize null device orientation.");
        switch (orientation) {
            case PORTRAIT_UP:
                return "portraitUp";
            case PORTRAIT_DOWN:
                return "portraitDown";
            case LANDSCAPE_LEFT:
                return "landscapeLeft";
            case LANDSCAPE_RIGHT:
                return "landscapeRight";
            default:
                throw new UnsupportedOperationException(
                        "Could not serialize device orientation: " + orientation.toString());
        }
    }

    static PlatformChannel.DeviceOrientation deserializeDeviceOrientation(String orientation) {
        if (orientation == null)
            throw new UnsupportedOperationException("Could not deserialize null device orientation.");
        switch (orientation) {
            case "portraitUp":
                return PlatformChannel.DeviceOrientation.PORTRAIT_UP;
            case "portraitDown":
                return PlatformChannel.DeviceOrientation.PORTRAIT_DOWN;
            case "landscapeLeft":
                return PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT;
            case "landscapeRight":
                return PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT;
            default:
                throw new UnsupportedOperationException(
                        "Could not deserialize device orientation: " + orientation);
        }
    }

    static Size computeBestPreviewSize(String cameraName, ResolutionPreset preset) {
        if (preset.ordinal() > ResolutionPreset.high.ordinal()) {
            preset = ResolutionPreset.high;
        }

        CamcorderProfile profile =
                getBestAvailableCamcorderProfileForResolutionPreset(cameraName, preset);
        return new Size(profile.videoFrameWidth, profile.videoFrameHeight);
    }

    static Size computeBestCaptureSize(StreamConfigurationMap streamConfigurationMap) {
        // For still image captures, we use the largest available size.
        return Collections.max(
                Arrays.asList(streamConfigurationMap.getOutputSizes(ImageFormat.JPEG)),
                new CompareSizesByArea());
    }

    public static List<Map<String, Object>> getAvailableCameras(Activity activity)
            throws CameraAccessException {
        CameraManager cameraManager = (CameraManager) activity.getSystemService(Context.CAMERA_SERVICE);
        String[] cameraNames = cameraManager.getCameraIdList();
        List<Map<String, Object>> cameras = new ArrayList<>();
        for (String cameraName : cameraNames) {
            HashMap<String, Object> details = new HashMap<>();
            CameraCharacteristics characteristics = cameraManager.getCameraCharacteristics(cameraName);
            details.put("name", cameraName);
            int sensorOrientation = characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION);
            details.put("sensorOrientation", sensorOrientation);

            int lensFacing = characteristics.get(CameraCharacteristics.LENS_FACING);
            switch (lensFacing) {
                case CameraMetadata.LENS_FACING_FRONT:
                    details.put("lensFacing", "front");
                    break;
                case CameraMetadata.LENS_FACING_BACK:
                    details.put("lensFacing", "back");
                    break;
                case CameraMetadata.LENS_FACING_EXTERNAL:
                    details.put("lensFacing", "external");
                    break;
            }
            cameras.add(details);
        }
        return cameras;
    }

    static CamcorderProfile getBestAvailableCamcorderProfileForResolutionPreset(
            String cameraName, ResolutionPreset preset) {
        int cameraId = Integer.parseInt(cameraName);
        switch (preset) {
            // All of these cases deliberately fall through to get the best available profile.
            case max:
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_HIGH)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_HIGH);
                }
            case ultraHigh:
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_2160P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_2160P);
                }
            case veryHigh:
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_1080P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_1080P);
                }
            case high:
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_720P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_720P);
                }
            case medium:
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_480P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_480P);
                }
            case low:
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_QVGA)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_QVGA);
                }
            default:
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_LOW)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_LOW);
                } else {
                    throw new IllegalArgumentException(
                            "No capture session available for current capture session.");
                }
        }
    }

    private static class CompareSizesByArea implements Comparator<Size> {
        @Override
        public int compare(Size lhs, Size rhs) {
            // We cast here to ensure the multiplications won't overflow.
            return Long.signum(
                    (long) lhs.getWidth() * lhs.getHeight() - (long) rhs.getWidth() * rhs.getHeight());
        }
    }
}
