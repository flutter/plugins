package io.flutter.plugins.camera;

import android.app.Activity;
import android.content.Context;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.util.Range;

import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.isNotNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import io.flutter.view.TextureRegistry;

public class CameraTest {
    @Test
    public void should_create_camera_plugin() throws CameraAccessException {
        final Activity mockActivity = mock(Activity.class);
        final TextureRegistry.SurfaceTextureEntry flutterTextureMock = mock(TextureRegistry.SurfaceTextureEntry.class);
        final DartMessenger dartMessengerMock = mock(DartMessenger.class);
        final String cameraName = "camera1";
        final String resolutionPreset = "high";
        final boolean enableAudio = false;
        final CameraCharacteristics mockCameraCharacteristics = mock(CameraCharacteristics.class);

        // Mocks
        final CameraManager mockCameraManager = mock(CameraManager.class);
        when(mockActivity.getSystemService(Context.CAMERA_SERVICE)).thenReturn(mockCameraManager);
        when(mockCameraManager.getCameraCharacteristics(cameraName)).thenReturn(mockCameraCharacteristics);
        when(mockCameraCharacteristics.get(CameraCharacteristics.CONTROL_AF_AVAILABLE_MODES)).thenReturn(new int[]{0, 1, 2});
        when(mockCameraCharacteristics.get(CameraCharacteristics.CONTROL_AE_AVAILABLE_TARGET_FPS_RANGES)).thenReturn(null);

        final Camera camera = new Camera(mockActivity,
                flutterTextureMock,
                dartMessengerMock,
                cameraName,
                resolutionPreset,
                enableAudio);

        assertEquals("should create a camera", camera, isNotNull());
        assertEquals("should be in preview state from the start", camera.getState(), CameraState.STATE_PREVIEW);
    }
}
