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
import static org.junit.Assert.assertTrue;
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
  public void itHandlesRequestForAvailableCamerasHappyPath() throws CameraAccessException {
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

  @Test
  public void itHandlesRequestForAvailableCamerasWhenCameraAccessFailed() throws CameraAccessException {
    // Setup test.
    // We mock the exception that we throw because instantiating one does not
    // seem to correctly assemble its "message". This might happen because this
    // is an Android exception, but I'm not sure.
    CameraAccessException fakeException = mock(CameraAccessException.class);
    when(fakeException.getMessage()).thenReturn("CameraAccessException intentionally thrown in test.");

    when(fakeCameraSystem.getAvailableCameras()).thenThrow(fakeException);

    final MethodCall availableCamerasRequest = new MethodCall("availableCameras", null);
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);
    boolean exceptionWasThrown = false;

    // Execute behavior under test.
    try {
      channelHandler.onMethodCall(availableCamerasRequest, fakeResult);
    } catch (Exception e) {
      exceptionWasThrown = true;
    }

    // Verify results.
    verify(fakeResult, times(1)).error(
        eq("CameraAccess"),
        eq("CameraAccessException intentionally thrown in test."),
        eq(null)
    );
    assertTrue(exceptionWasThrown);
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
    serializedCamera.put("lensFacing", lensDirection);
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
  public void itHandlesTakePictureRequestHappyPath() {
    // Setup test.
    final MethodCall takePictureRequest = createFakeTakePictureMethodCall(
        "/some/image/path"
    );
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(takePictureRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<Camera.OnPictureTakenCallback> callbackCaptor = ArgumentCaptor.forClass(Camera.OnPictureTakenCallback.class);
    verify(fakeCameraSystem, times(1)).takePicture(
        eq("/some/image/path"),
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().onPictureTaken();

    // Verify success response was sent from Android to Flutter.
    verify(fakeResult, times(1)).success(eq(null));
  }

  @Test
  public void itHandlesTakePictureRequestWhenFileAlreadyExists() {
    // Setup test.
    final MethodCall takePictureRequest = createFakeTakePictureMethodCall(
        "/some/image/path"
    );
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(takePictureRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<Camera.OnPictureTakenCallback> callbackCaptor = ArgumentCaptor.forClass(Camera.OnPictureTakenCallback.class);
    verify(fakeCameraSystem, times(1)).takePicture(
        eq("/some/image/path"),
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().onFileAlreadyExists();

    // Verify expected error response was sent from Android to Flutter.
    verify(fakeResult, times(1)).error(
        eq("fileExists"),
        eq("File at path '/some/image/path' already exists. Cannot overwrite."),
        eq(null)
    );
  }

  @Test
  public void itHandlesTakePictureRequestWhenFailedToSaveImage() {
    // Setup test.
    final MethodCall takePictureRequest = createFakeTakePictureMethodCall(
        "/some/image/path"
    );
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(takePictureRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<Camera.OnPictureTakenCallback> callbackCaptor = ArgumentCaptor.forClass(Camera.OnPictureTakenCallback.class);
    verify(fakeCameraSystem, times(1)).takePicture(
        eq("/some/image/path"),
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().onFailedToSaveImage();

    // Verify expected error response was sent from Android to Flutter.
    verify(fakeResult, times(1)).error(
        eq("IOError"),
        eq("Failed saving image"),
        eq(null)
    );
  }

  @Test
  public void itHandlesTakePictureRequestWhenCaptureFailed() {
    // Setup test.
    final MethodCall takePictureRequest = createFakeTakePictureMethodCall(
        "/some/image/path"
    );
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(takePictureRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<Camera.OnPictureTakenCallback> callbackCaptor = ArgumentCaptor.forClass(Camera.OnPictureTakenCallback.class);
    verify(fakeCameraSystem, times(1)).takePicture(
        eq("/some/image/path"),
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().onCaptureFailure("Because this is a test");

    // Verify expected error response was sent from Android to Flutter.
    verify(fakeResult, times(1)).error(
        eq("captureFailure"),
        eq("Because this is a test"),
        eq(null)
    );
  }

  @Test
  public void itHandlesTakePictureRequestWhenCameraAccessFailed() {
    // Setup test.
    final MethodCall takePictureRequest = createFakeTakePictureMethodCall(
        "/some/image/path"
    );
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(takePictureRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<Camera.OnPictureTakenCallback> callbackCaptor = ArgumentCaptor.forClass(Camera.OnPictureTakenCallback.class);
    verify(fakeCameraSystem, times(1)).takePicture(
        eq("/some/image/path"),
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().onCameraAccessFailure("Because this is a test");

    // Verify expected error response was sent from Android to Flutter.
    verify(fakeResult, times(1)).error(
        eq("cameraAccess"),
        eq("Because this is a test"),
        eq(null)
    );
  }

  @NonNull
  private MethodCall createFakeTakePictureMethodCall(
      @NonNull String filePath
  ) {
    Map<String, Object> requestArguments = new HashMap<>();
    requestArguments.put("path", filePath);
    return new MethodCall("takePicture", requestArguments);
  }

  @Test
  public void itHandlesStartVideoRecordingHappyPath() {
    // Setup test.
    final MethodCall startVideoRecordingRequest = createFakeStartVideoRecordingMethodCall(
        "/some/image/path"
    );
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(startVideoRecordingRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<CameraSystem.OnStartVideoRecordingCallback> callbackCaptor = ArgumentCaptor.forClass(CameraSystem.OnStartVideoRecordingCallback.class);
    verify(fakeCameraSystem, times(1)).startVideoRecording(
        eq("/some/image/path"),
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().success();

    // Verify success response was sent from Android to Flutter.
    verify(fakeResult, times(1)).success(eq(null));
  }

  @Test
  public void itHandlesStartVideoRecordingWhenFileAlreadyExists() {
    // Setup test.
    final MethodCall startVideoRecordingRequest = createFakeStartVideoRecordingMethodCall(
        "/some/image/path"
    );
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(startVideoRecordingRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<CameraSystem.OnStartVideoRecordingCallback> callbackCaptor = ArgumentCaptor.forClass(CameraSystem.OnStartVideoRecordingCallback.class);
    verify(fakeCameraSystem, times(1)).startVideoRecording(
        eq("/some/image/path"),
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().onFileAlreadyExists("/some/image/path");

    // Verify success response was sent from Android to Flutter.
    verify(fakeResult, times(1)).error(
        eq("fileExists"),
        eq("File at path '/some/image/path' already exists."),
        eq(null)
    );
  }

  @Test
  public void itHandlesStartVideoRecordingWhenVideoRecordingFailed() {
    // Setup test.
    final MethodCall startVideoRecordingRequest = createFakeStartVideoRecordingMethodCall(
        "/some/image/path"
    );
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(startVideoRecordingRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<CameraSystem.OnStartVideoRecordingCallback> callbackCaptor = ArgumentCaptor.forClass(CameraSystem.OnStartVideoRecordingCallback.class);
    verify(fakeCameraSystem, times(1)).startVideoRecording(
        eq("/some/image/path"),
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().onVideoRecordingFailed("Because this is a test");

    // Verify success response was sent from Android to Flutter.
    verify(fakeResult, times(1)).error(
        eq("videoRecordingFailed"),
        eq("Because this is a test"),
        eq(null)
    );
  }

  @NonNull
  private MethodCall createFakeStartVideoRecordingMethodCall(
      @NonNull String filePath
  ) {
    Map<String, Object> requestArguments = new HashMap<>();
    requestArguments.put("filePath", filePath);
    return new MethodCall("startVideoRecording", requestArguments);
  }

  @Test
  public void itHandlesStopVideoRecordingHappyPath() {
    // Setup test.
    final MethodCall stopVideoRecordingRequest = createFakeStopVideoRecordingMethodCall();
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(stopVideoRecordingRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<CameraSystem.OnVideoRecordingCommandCallback> callbackCaptor = ArgumentCaptor.forClass(CameraSystem.OnVideoRecordingCommandCallback.class);
    verify(fakeCameraSystem, times(1)).stopVideoRecording(
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().success();

    // Verify success response was sent from Android to Flutter.
    verify(fakeResult, times(1)).success(eq(null));
  }

  @Test
  public void itHandlesStopVideoRecordingWhenVideoRecordingFailed() {
    // Setup test.
    final MethodCall startVideoRecordingRequest = createFakeStopVideoRecordingMethodCall();
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(startVideoRecordingRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<CameraSystem.OnVideoRecordingCommandCallback> callbackCaptor = ArgumentCaptor.forClass(CameraSystem.OnVideoRecordingCommandCallback.class);
    verify(fakeCameraSystem, times(1)).stopVideoRecording(
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().onVideoRecordingFailed("Because this is a test");

    // Verify error response was sent from Android to Flutter.
    verify(fakeResult, times(1)).error(
        eq("videoRecordingFailed"),
        eq("Because this is a test"),
        eq(null)
    );
  }

  @NonNull
  private MethodCall createFakeStopVideoRecordingMethodCall() {
    Map<String, Object> requestArguments = new HashMap<>();
    return new MethodCall("stopVideoRecording", requestArguments);
  }

  @Test
  public void itHandlesPauseVideoRecordingHappyPath() {
    // Setup test.
    final MethodCall pauseVideoRecordingRequest = createFakePauseVideoRecordingMethodCall();
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(pauseVideoRecordingRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<CameraSystem.OnApiDependentVideoRecordingCommandCallback> callbackCaptor = ArgumentCaptor.forClass(CameraSystem.OnApiDependentVideoRecordingCommandCallback.class);
    verify(fakeCameraSystem, times(1)).pauseVideoRecording(
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().success();

    // Verify success response was sent from Android to Flutter.
    verify(fakeResult, times(1)).success(eq(null));
  }

  @Test
  public void itHandlesPauseVideoRecordingWhenOperationNotSupported() {
    // Setup test.
    final MethodCall pauseVideoRecordingRequest = createFakePauseVideoRecordingMethodCall();
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(pauseVideoRecordingRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<CameraSystem.OnApiDependentVideoRecordingCommandCallback> callbackCaptor = ArgumentCaptor.forClass(CameraSystem.OnApiDependentVideoRecordingCommandCallback.class);
    verify(fakeCameraSystem, times(1)).pauseVideoRecording(
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().onUnsupportedOperation();

    // Verify error response was sent from Android to Flutter.
    verify(fakeResult, times(1)).error(
        eq("videoRecordingFailed"),
        eq("pauseVideoRecording requires Android API +24."),
        eq(null)
    );
  }

  @Test
  public void itHandlesPauseVideoRecordingWhenVideoRecordingFailed() {
    // Setup test.
    final MethodCall pauseVideoRecordingRequest = createFakePauseVideoRecordingMethodCall();
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(pauseVideoRecordingRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<CameraSystem.OnApiDependentVideoRecordingCommandCallback> callbackCaptor = ArgumentCaptor.forClass(CameraSystem.OnApiDependentVideoRecordingCommandCallback.class);
    verify(fakeCameraSystem, times(1)).pauseVideoRecording(
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().onVideoRecordingFailed("Because this is a test");

    // Verify error response was sent from Android to Flutter.
    verify(fakeResult, times(1)).error(
        eq("videoRecordingFailed"),
        eq("Because this is a test"),
        eq(null)
    );
  }

  @NonNull
  private MethodCall createFakePauseVideoRecordingMethodCall() {
    Map<String, Object> requestArguments = new HashMap<>();
    return new MethodCall("pauseVideoRecording", requestArguments);
  }

  @Test
  public void itHandlesResumeVideoRecordingHappyPath() {
    // Setup test.
    final MethodCall resumeVideoRecordingRequest = createFakeResumeVideoRecordingMethodCall();
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(resumeVideoRecordingRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<CameraSystem.OnApiDependentVideoRecordingCommandCallback> callbackCaptor = ArgumentCaptor.forClass(CameraSystem.OnApiDependentVideoRecordingCommandCallback.class);
    verify(fakeCameraSystem, times(1)).resumeVideoRecording(
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().success();

    // Verify success response was sent from Android to Flutter.
    verify(fakeResult, times(1)).success(eq(null));
  }

  @Test
  public void itHandlesResumeVideoRecordingWhenOperationNotSupported() {
    // Setup test.
    final MethodCall resumeVideoRecordingRequest = createFakeResumeVideoRecordingMethodCall();
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(resumeVideoRecordingRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<CameraSystem.OnApiDependentVideoRecordingCommandCallback> callbackCaptor = ArgumentCaptor.forClass(CameraSystem.OnApiDependentVideoRecordingCommandCallback.class);
    verify(fakeCameraSystem, times(1)).resumeVideoRecording(
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().onUnsupportedOperation();

    // Verify error response was sent from Android to Flutter.
    verify(fakeResult, times(1)).error(
        eq("videoRecordingFailed"),
        eq("resumeVideoRecording requires Android API +24."),
        eq(null)
    );
  }

  @Test
  public void itHandlesResumeVideoRecordingWhenVideoRecordingFailed() {
    // Setup test.
    final MethodCall resumeVideoRecordingRequest = createFakeResumeVideoRecordingMethodCall();
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(resumeVideoRecordingRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<CameraSystem.OnApiDependentVideoRecordingCommandCallback> callbackCaptor = ArgumentCaptor.forClass(CameraSystem.OnApiDependentVideoRecordingCommandCallback.class);
    verify(fakeCameraSystem, times(1)).resumeVideoRecording(
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().onVideoRecordingFailed("Because this is a test");

    // Verify error response was sent from Android to Flutter.
    verify(fakeResult, times(1)).error(
        eq("videoRecordingFailed"),
        eq("Because this is a test"),
        eq(null)
    );
  }

  @NonNull
  private MethodCall createFakeResumeVideoRecordingMethodCall() {
    Map<String, Object> requestArguments = new HashMap<>();
    return new MethodCall("resumeVideoRecording", requestArguments);
  }

  @Test
  public void itHandlesStartImageStreamRequestHappyPath() {
    // Setup test.
    final MethodCall startImageStreamRequest = createFakeStartImageStreamMethodCall();
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(startImageStreamRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<CameraSystem.OnCameraAccessCommandCallback> callbackCaptor = ArgumentCaptor.forClass(CameraSystem.OnCameraAccessCommandCallback.class);
    verify(fakeCameraSystem, times(1)).startImageStream(
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().success();

    // Verify success response was sent from Android to Flutter.
    verify(fakeResult, times(1)).success(eq(null));
  }

  @Test
  public void itHandlesStartImageStreamRequestWhenCameraAccessFailed() {
    // Setup test.
    final MethodCall startImageStreamRequest = createFakeStartImageStreamMethodCall();
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(startImageStreamRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<CameraSystem.OnCameraAccessCommandCallback> callbackCaptor = ArgumentCaptor.forClass(CameraSystem.OnCameraAccessCommandCallback.class);
    verify(fakeCameraSystem, times(1)).startImageStream(
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().onCameraAccessFailure("Because this is a test");

    // Verify error response was sent from Android to Flutter.
    verify(fakeResult, times(1)).error(
        eq("CameraAccess"),
        eq("Because this is a test"),
        eq(null)
    );
  }

  @NonNull
  private MethodCall createFakeStartImageStreamMethodCall() {
    Map<String, Object> requestArguments = new HashMap<>();
    return new MethodCall("startImageStream", requestArguments);
  }

  @Test
  public void itHandlesStopImageStreamRequestHappyPath() {
    // Setup test.
    final MethodCall stopImageStreamRequest = createFakeStopImageStreamMethodCall();
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(stopImageStreamRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<CameraSystem.OnCameraAccessCommandCallback> callbackCaptor = ArgumentCaptor.forClass(CameraSystem.OnCameraAccessCommandCallback.class);
    verify(fakeCameraSystem, times(1)).stopImageStream(
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().success();

    // Verify success response was sent from Android to Flutter.
    verify(fakeResult, times(1)).success(eq(null));
  }

  @Test
  public void itHandlesStopImageStreamRequestWhenCameraAccessFailed() {
    // Setup test.
    final MethodCall stopImageStreamRequest = createFakeStopImageStreamMethodCall();
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(stopImageStreamRequest, fakeResult);

    // Verify that the CameraSystem was invoked with the expected request.
    // Then invoke the callback so that the channel sends a response.
    ArgumentCaptor<CameraSystem.OnCameraAccessCommandCallback> callbackCaptor = ArgumentCaptor.forClass(CameraSystem.OnCameraAccessCommandCallback.class);
    verify(fakeCameraSystem, times(1)).stopImageStream(
        callbackCaptor.capture()
    );
    callbackCaptor.getValue().onCameraAccessFailure("Because this is a test");

    // Verify error response was sent from Android to Flutter.
    verify(fakeResult, times(1)).error(
        eq("CameraAccess"),
        eq("Because this is a test"),
        eq(null)
    );
  }

  @NonNull
  private MethodCall createFakeStopImageStreamMethodCall() {
    Map<String, Object> requestArguments = new HashMap<>();
    return new MethodCall("stopImageStream", requestArguments);
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

  @Test
  public void itHandlesNonExistantRequestTypes() {
    // Setup test.
    final MethodCall nonExistentRequest = new MethodCall("doesNotExist", null);
    final MethodChannel.Result fakeResult = mock(MethodChannel.Result.class);

    // Execute behavior under test.
    channelHandler.onMethodCall(nonExistentRequest, fakeResult);

    // Verify results.
    verifyZeroInteractions(fakeCameraSystem);
    verify(fakeResult, times(1)).notImplemented();
  }

  @Test
  public void itDisposesCameraSystemWhenReleased() {
    // Execute behavior under test.
    protocol.release();

    // Verify results.
    verify(fakeCameraSystem, times(1)).dispose();
  }
}
