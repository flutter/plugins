package io.flutter.plugins.camera;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.CaptureResult;
import android.hardware.camera2.CaptureResult.Key;
import io.flutter.plugins.camera.CameraCaptureCallback.CameraCaptureStateListener;
import io.flutter.plugins.camera.utils.TestUtils;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class CameraCaptureCallbackTest {
  private CameraCaptureStateListener mockCaptureStateListener;

  @Before
  public void before() {
    mockCaptureStateListener = mock(CameraCaptureStateListener.class);
  }

  @Test
  public void getCameraState_should_return_camera_preview_if_not_set() {
    CameraCaptureCallback captureCallback = CameraCaptureCallback.create(mockCaptureStateListener);

    assertEquals(CameraState.STATE_PREVIEW, captureCallback.getCameraState());
  }

  @Test
  public void getCameraState_should_echo_setCameraState_value() {
    CameraCaptureCallback captureCallback = CameraCaptureCallback.create(mockCaptureStateListener);

    captureCallback.setCameraState(CameraState.STATE_CAPTURING);

    assertEquals(CameraState.STATE_CAPTURING, captureCallback.getCameraState());
  }

  public static class CameraStateWaitingFocusTests {
    private CameraCaptureStateListener mockCaptureStateListener;
    private CameraCaptureSession mockCameraCaptureSession;
    private CaptureRequest mockCaptureRequest;
    private CaptureResult mockCaptureResult;

    @Before
    @SuppressWarnings("unchecked")
    public void before() {
      mockCaptureStateListener = mock(CameraCaptureStateListener.class);
      mockCameraCaptureSession = mock(CameraCaptureSession.class);
      mockCaptureRequest = mock(CaptureRequest.class);
      mockCaptureResult = mock(CaptureResult.class);
      Key<Integer> mockAeStateKey = mock(Key.class);
      Key<Integer> mockAfStateKey = mock(Key.class);

      TestUtils.setFinalStatic(CaptureResult.class, "CONTROL_AE_STATE", mockAeStateKey);
      TestUtils.setFinalStatic(CaptureResult.class, "CONTROL_AF_STATE", mockAfStateKey);
    }

    @After
    public void after() {
      TestUtils.setFinalStatic(CaptureResult.class, "CONTROL_AE_STATE", null);
      TestUtils.setFinalStatic(CaptureResult.class, "CONTROL_AF_STATE", null);
    }

    @Test
    public void process_should_converge_when_af_state_is_focus_locked_and_ae_state_is_null() {
      CameraCaptureCallback captureCallback =
          CameraCaptureCallback.create(mockCaptureStateListener);

      when(mockCaptureResult.get(CaptureResult.CONTROL_AF_STATE))
          .thenReturn(CaptureResult.CONTROL_AF_STATE_FOCUSED_LOCKED);
      when(mockCaptureResult.get(CaptureResult.CONTROL_AE_STATE)).thenReturn(null);

      captureCallback.setCameraState(CameraState.STATE_WAITING_FOCUS);
      captureCallback.onCaptureProgressed(
          mockCameraCaptureSession, mockCaptureRequest, mockCaptureResult);

      verify(mockCaptureStateListener, times(1)).onConverged();
    }

    @Test
    public void process_should_converge_when_af_state_is_focus_locked_and_ae_state_is_converged() {
      CameraCaptureCallback captureCallback =
          CameraCaptureCallback.create(mockCaptureStateListener);

      when(mockCaptureResult.get(CaptureResult.CONTROL_AF_STATE))
          .thenReturn(CaptureResult.CONTROL_AF_STATE_FOCUSED_LOCKED);
      when(mockCaptureResult.get(CaptureResult.CONTROL_AE_STATE))
          .thenReturn(CaptureResult.CONTROL_AE_STATE_CONVERGED);

      captureCallback.setCameraState(CameraState.STATE_WAITING_FOCUS);
      captureCallback.onCaptureProgressed(
          mockCameraCaptureSession, mockCaptureRequest, mockCaptureResult);

      verify(mockCaptureStateListener, times(1)).onConverged();
    }

    @Test
    public void
        process_should_converge_when_af_state_is_focus_locked_and_ae_state_is_not_null_and_not_converged() {
      CameraCaptureCallback captureCallback =
          CameraCaptureCallback.create(mockCaptureStateListener);

      when(mockCaptureResult.get(CaptureResult.CONTROL_AF_STATE))
          .thenReturn(CaptureResult.CONTROL_AF_STATE_FOCUSED_LOCKED);
      captureCallback.setCameraState(CameraState.STATE_WAITING_FOCUS);

      when(mockCaptureResult.get(CaptureResult.CONTROL_AE_STATE))
          .thenReturn(CaptureResult.CONTROL_AE_STATE_LOCKED);
      captureCallback.onCaptureProgressed(
          mockCameraCaptureSession, mockCaptureRequest, mockCaptureResult);

      when(mockCaptureResult.get(CaptureResult.CONTROL_AE_STATE))
          .thenReturn(CaptureResult.CONTROL_AE_STATE_INACTIVE);
      captureCallback.onCaptureProgressed(
          mockCameraCaptureSession, mockCaptureRequest, mockCaptureResult);

      when(mockCaptureResult.get(CaptureResult.CONTROL_AE_STATE))
          .thenReturn(CaptureResult.CONTROL_AE_STATE_PRECAPTURE);
      captureCallback.onCaptureProgressed(
          mockCameraCaptureSession, mockCaptureRequest, mockCaptureResult);

      when(mockCaptureResult.get(CaptureResult.CONTROL_AE_STATE))
          .thenReturn(CaptureResult.CONTROL_AE_STATE_SEARCHING);
      captureCallback.onCaptureProgressed(
          mockCameraCaptureSession, mockCaptureRequest, mockCaptureResult);

      when(mockCaptureResult.get(CaptureResult.CONTROL_AE_STATE))
          .thenReturn(CaptureResult.CONTROL_AE_STATE_PRECAPTURE);
      captureCallback.onCaptureProgressed(
          mockCameraCaptureSession, mockCaptureRequest, mockCaptureResult);

      when(mockCaptureResult.get(CaptureResult.CONTROL_AE_STATE))
          .thenReturn(CaptureResult.CONTROL_AE_STATE_FLASH_REQUIRED);
      captureCallback.onCaptureProgressed(
          mockCameraCaptureSession, mockCaptureRequest, mockCaptureResult);

      verify(mockCaptureStateListener, times(6)).onPrecapture();
    }
  }
}
