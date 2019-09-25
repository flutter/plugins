package dev.flutter.plugins.camera;

import android.hardware.camera2.CameraAccessException;

import androidx.annotation.NonNull;

import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentCaptor;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import static junit.framework.TestCase.assertEquals;
import static org.mockito.Matchers.any;
import static org.mockito.Matchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyZeroInteractions;
import static org.mockito.Mockito.when;

public class CameraPluginProtocolTest {

  private CameraSystem fakeCameraSystem;
  private CameraPluginProtocol protocol; // This is the object under test.
  private MethodChannel.MethodCallHandler channelHandler;

  @Before
  public void setup() {
    fakeCameraSystem = mock(CameraSystem.class);
    protocol = new CameraPluginProtocol(fakeCameraSystem);
    channelHandler = protocol.getCameraSystemChannelHandler();
  }

  @Test
  public void itHandlesRequestForAvailableCameras() throws CameraAccessException {
    // Setup test.
    // Hard code the value that we expect to be sent from Android to Flutter.
    final List<Map<String, Object>> expectedResponse = Arrays.asList(
        createFakeSerializedCameraConfig(
            "fake_camera_1",
            1,
            "front"
        ),
        createFakeSerializedCameraConfig(
            "fake_camera_2",
            1,
            "back"
        )
    );

    // Fake the CameraSystem to return CameraDetails that should yield our
    // expected output.
    List<CameraDetails> fakeCameraList = Arrays.asList(
        new CameraDetails(
            "fake_camera_1",
            1,
            "front"
        ),
        new CameraDetails(
            "fake_camera_2",
            1,
            "back"
        )
    );
    when(fakeCameraSystem.getAvailableCameras()).thenReturn(fakeCameraList);

    final MethodCall availableCamerasRequest = new MethodCall("availableCameras", null);
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(availableCamerasRequest, fakeResult);

    // Verify results.
    ArgumentCaptor<List> responseCaptor = ArgumentCaptor.forClass(List.class);
    verify(fakeResult, times(1)).success(responseCaptor.capture());

    // Verify that we received the expected 2 cameras.
    final List actualResponse = responseCaptor.getValue();
    assertEquals(expectedResponse, actualResponse);
  }

  @NonNull
  private Map<String, Object> createFakeSerializedCameraConfig(
      @NonNull String cameraName,
      @NonNull int sensorOrientation,
      @NonNull String lensDirection
  ) {
    final Map<String, Object> serializedCamera = new HashMap<>();
    serializedCamera.put("name", cameraName);
    serializedCamera.put("sensorOrientation", sensorOrientation);
    serializedCamera.put("lensDirection", lensDirection);
    return serializedCamera;
  }

  @Test
  public void itHandlesCameraInitializationHappyPath() {
    // Setup test.
    final CameraSystem.CameraConfigurationRequest expectedCameraRequest = createFakeCameraConfigurationRequest();
    final Map<String, Object> expectedSuccessResponse = createFakeInitializationResponse(
        1l, // Do not forget to make a "long"
        1920,
        1080
    );

    // Wire up fakes.
    final MethodCall initializeCameraRequest = createFakeInitializationMethodCall(
        "fake_camera_1",
        "fake_resolution_preset",
        true
    );
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(initializeCameraRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<CameraSystem.OnCameraInitializationCallback> callbackCaptor = ArgumentCaptor.forClass(CameraSystem.OnCameraInitializationCallback.class);
    verify(fakeCameraSystem, times(1)).initialize(eq(expectedCameraRequest), callbackCaptor.capture());
    callbackCaptor.getValue().onSuccess(1, 1920, 1080);

    // Verify expected success response was sent from Android to Flutter.
    verify(fakeResult, times(1)).success(eq(expectedSuccessResponse));
  }

  @Test
  public void itHandlesCameraInitializationWithPermissionError() {
    // Setup test.
    // Wire up fakes.
    final MethodCall initializeCameraRequest = createFakeInitializationMethodCall(
        "fake_camera_1",
        "fake_resolution_preset",
        true
    );
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(initializeCameraRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<CameraSystem.OnCameraInitializationCallback> callbackCaptor = ArgumentCaptor.forClass(CameraSystem.OnCameraInitializationCallback.class);
    verify(fakeCameraSystem, times(1)).initialize(
        any(CameraSystem.CameraConfigurationRequest.class),
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().onCameraPermissionError("fake_error", "fake_description");

    // Verify expected error response was sent from Android to Flutter.
    verify(fakeResult, times(1)).error(
        eq("fake_error"),
        eq("fake_description"),
        eq(null)
    );
  }

  @Test
  public void itHandlesCameraInitializationWithGenericError() {
    // Setup test.
    final MethodCall initializeCameraRequest = createFakeInitializationMethodCall(
        "fake_camera_1",
        "fake_resolution_preset",
        true
    );
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(initializeCameraRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<CameraSystem.OnCameraInitializationCallback> callbackCaptor = ArgumentCaptor.forClass(CameraSystem.OnCameraInitializationCallback.class);
    verify(fakeCameraSystem, times(1)).initialize(
        any(CameraSystem.CameraConfigurationRequest.class),
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().onError("fake_error", "fake_description");

    // Verify expected error response was sent from Android to Flutter.
    verify(fakeResult, times(1)).error(
        eq("fake_error"),
        eq("fake_description"),
        eq(null)
    );
  }

  @NonNull
  private MethodCall createFakeInitializationMethodCall(
      @NonNull String cameraName,
      @NonNull String resolutionPreset,
      boolean enableAudio
  ) {
    Map<String, Object> requestArguments = new HashMap<>();
    requestArguments.put("cameraName", cameraName);
    requestArguments.put("resolutionPreset", resolutionPreset);
    requestArguments.put("enableAudio", enableAudio);
    return new MethodCall("initialize", requestArguments);
  }

  @NonNull
  private CameraSystem.CameraConfigurationRequest createFakeCameraConfigurationRequest() {
    return new CameraSystem.CameraConfigurationRequest(
        "fake_camera_1",
        "fake_resolution_preset",
        true
    );
  }

  @NonNull
  private Map<String, Object> createFakeInitializationResponse(
      long textureId,
      int previewWidth,
      int previewHeight
  ) {
    Map<String, Object> initializationResponse = new HashMap<>();
    initializationResponse.put("textureId", textureId); // Do not forget to make a "long"
    initializationResponse.put("previewWidth", previewWidth);
    initializationResponse.put("previewHeight", previewHeight);
    return initializationResponse;
  }

  @Test
  public void itHandlesPrepareForVideoRecordingWithAutomaticSuccess() {
    // Setup test.
    final MethodCall prepareForVideoRecording = new MethodCall("prepareForVideoRecording", null);
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(prepareForVideoRecording, fakeResult);

    // Verify results.
    verifyZeroInteractions(fakeCameraSystem);
    verify(fakeResult, times(1)).success(eq(null));
  }

  @Test
  public void itHandlesDisposeRequest() {
    // Setup test.
    final MethodCall disposeRequest = new MethodCall("dispose", null);
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(disposeRequest, fakeResult);

    // Verify results.
    verify(fakeCameraSystem, times(1)).dispose();
    verify(fakeResult, times(1)).success(eq(null));
  }
}
