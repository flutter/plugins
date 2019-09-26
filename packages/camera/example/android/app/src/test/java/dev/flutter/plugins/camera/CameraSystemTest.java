package dev.flutter.plugins.camera;

import android.hardware.camera2.CameraAccessException;

import androidx.annotation.NonNull;

import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.invocation.InvocationOnMock;
import org.mockito.stubbing.Answer;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

import dev.flutter.plugins.camera.CameraPermissions.ResultCallback;
import io.flutter.plugin.common.EventChannel;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

/**
 * Most of the tests in this suite are white box tests that unabashedly verify implementation
 * details. This is not ideal. There are probably a number of end-to-end tests that would render
 * most of these verifications superfluous. If such tests are added, consider removed some or
 * all of the tests in this suite.
 */
public class CameraSystemTest {

  private CameraPermissions cameraPermissions;
  private CameraHardware cameraHardware;
  private CameraPreviewDisplay cameraPreviewDisplay;
  private CameraPluginProtocol.CameraEventChannelFactory cameraEventChannelFactory;
  private CameraFactory cameraFactory;

  private CameraSystem cameraSystem; // object under test.

  @Before
  public void setup() {
    cameraPermissions = mock(CameraPermissions.class);
    cameraHardware = mock(CameraHardware.class);
    cameraPreviewDisplay = mock(CameraPreviewDisplay.class);
    cameraEventChannelFactory = mock(CameraPluginProtocol.CameraEventChannelFactory.class);
    cameraFactory = mock(CameraFactory.class);

    cameraSystem = new CameraSystem(
        cameraPermissions,
        cameraHardware,
        cameraPreviewDisplay,
        cameraEventChannelFactory,
        cameraFactory
    );
  }

  @Test
  public void itLooksUpAvailableCameras() throws CameraAccessException {
    // Setup test.
    final CameraDetails cameraDetails = new CameraDetails(
        "fake_camera_1",
        1,
        "front"
    );
    when(cameraHardware.getAvailableCameras()).thenReturn(Collections.singletonList(cameraDetails));

    // Execute the behavior under test.
    final List<CameraDetails> actualCameraDetails = cameraSystem.getAvailableCameras();

    // Verify results.
    assertEquals(1, actualCameraDetails.size());
    assertEquals(cameraDetails, actualCameraDetails.get(0));
  }

  @Test
  public void itInitializesSingleCameraHappyPath() throws CameraAccessException {
    // Setup test.
    // Grant all permissions.
    grantFakePermissions();

    // Setup CameraFactory to return a fake Camera.
    final Camera fakeCamera = mock(Camera.class);
    when(cameraFactory.createCamera(anyString(), anyString(), anyBoolean())).thenReturn(fakeCamera);

    // Configure CameraEventChannelFactory to return a fake EventChannel
    final EventChannel fakeEventChannel = mock(EventChannel.class);
    when(cameraEventChannelFactory.createCameraEventChannel(anyLong())).thenReturn(fakeEventChannel);
    final EventChannel.EventSink fakeEventSink = mock(EventChannel.EventSink.class);

    final CameraSystem.CameraConfigurationRequest request = new CameraSystem.CameraConfigurationRequest(
        "fake_camera_1",
        "fake_preset",
        true
    );

    CameraSystem.OnCameraInitializationCallback callback = mock(CameraSystem.OnCameraInitializationCallback.class);

    // Execute behavior under test.
    cameraSystem.initialize(request, callback);

    // Capture the cameraEventChannel's stream handler and invoke it.
    ArgumentCaptor<EventChannel.StreamHandler> streamHandlerCaptor = ArgumentCaptor.forClass(EventChannel.StreamHandler.class);
    verify(fakeEventChannel, times(1)).setStreamHandler(streamHandlerCaptor.capture());

    // Simulate a successful opening of the camera's event stream.
    streamHandlerCaptor.getValue().onListen(null, fakeEventSink);

    // Capture the OnCameraOpenedCallback.
    ArgumentCaptor<Camera.OnCameraOpenedCallback> openedCallbackCaptor = ArgumentCaptor.forClass(Camera.OnCameraOpenedCallback.class);
    verify(fakeCamera, times(1)).open(openedCallbackCaptor.capture());

    // Simulate a successful camera open.
    openedCallbackCaptor.getValue().onCameraOpened(
        12345l,
        1920,
        1080
    );

    // Verify results.
    verify(callback, times(1)).onSuccess(
        12345l,
        1920,
        1080
    );
    // TODO(mattcarroll): verify that an event handler was setup
  }

  @Test
  public void itReportsPermissionErrorWhenInitializingSingleCamera() throws CameraAccessException {
    // Setup test.
    // Automatically decline permissions.
    declineFakePermissions("FakeError", "Permissions denied in test.");

    // Setup CameraFactory to return a fake Camera.
    final Camera fakeCamera = mock(Camera.class);
    when(cameraFactory.createCamera(anyString(), anyString(), anyBoolean())).thenReturn(fakeCamera);

    // Configure CameraEventChannelFactory to return a fake EventChannel
    final EventChannel fakeEventChannel = mock(EventChannel.class);
    when(cameraEventChannelFactory.createCameraEventChannel(anyLong())).thenReturn(fakeEventChannel);

    final CameraSystem.CameraConfigurationRequest request = new CameraSystem.CameraConfigurationRequest(
        "fake_camera_1",
        "fake_preset",
        true
    );

    CameraSystem.OnCameraInitializationCallback callback = mock(CameraSystem.OnCameraInitializationCallback.class);

    // Execute behavior under test.
    cameraSystem.initialize(request, callback);

    // Verify results.
    verify(callback, times(1)).onCameraPermissionError("FakeError", "Permissions denied in test.");
  }

  @Test
  public void itReportsCameraCreationErrorWhenInitializingSingleCamera() throws CameraAccessException {
    // Setup test.
    // Grant all permissions.
    grantFakePermissions();

    // Setup CameraFactory to throw an exception.
    CameraAccessException exception = mock(CameraAccessException.class);
    when(exception.getMessage()).thenReturn("fake message");
    when(cameraFactory.createCamera(anyString(), anyString(), anyBoolean())).thenThrow(exception);

    final CameraSystem.CameraConfigurationRequest request = new CameraSystem.CameraConfigurationRequest(
        "fake_camera_1",
        "fake_preset",
        true
    );

    CameraSystem.OnCameraInitializationCallback callback = mock(CameraSystem.OnCameraInitializationCallback.class);

    // Execute behavior under test.
    cameraSystem.initialize(request, callback);

    // Verify results.
    verify(callback, times(1)).onError("CameraAccess", "fake message");
  }

  @Test
  public void itReportsCameraOpenErrorWhenInitializingSingleCamera() throws CameraAccessException {
    // Setup test.
    // Grant all permissions.
    grantFakePermissions();

    // Setup CameraFactory to return a fake Camera.
    final Camera fakeCamera = mock(Camera.class);
    when(cameraFactory.createCamera(anyString(), anyString(), anyBoolean())).thenReturn(fakeCamera);

    // Configure CameraEventChannelFactory to return a fake EventChannel
    final EventChannel fakeEventChannel = mock(EventChannel.class);
    when(cameraEventChannelFactory.createCameraEventChannel(anyLong())).thenReturn(fakeEventChannel);
    final EventChannel.EventSink fakeEventSink = mock(EventChannel.EventSink.class);

    final CameraSystem.CameraConfigurationRequest request = new CameraSystem.CameraConfigurationRequest(
        "fake_camera_1",
        "fake_preset",
        true
    );

    CameraSystem.OnCameraInitializationCallback callback = mock(CameraSystem.OnCameraInitializationCallback.class);

    // Execute behavior under test.
    cameraSystem.initialize(request, callback);

    // Capture the cameraEventChannel's stream handler and invoke it.
    ArgumentCaptor<EventChannel.StreamHandler> streamHandlerCaptor = ArgumentCaptor.forClass(EventChannel.StreamHandler.class);
    verify(fakeEventChannel, times(1)).setStreamHandler(streamHandlerCaptor.capture());

    // Simulate a successful opening of the camera's event stream.
    streamHandlerCaptor.getValue().onListen(null, fakeEventSink);

    // Capture the OnCameraOpenedCallback.
    ArgumentCaptor<Camera.OnCameraOpenedCallback> openedCallbackCaptor = ArgumentCaptor.forClass(Camera.OnCameraOpenedCallback.class);
    verify(fakeCamera, times(1)).open(openedCallbackCaptor.capture());

    // Simulate a successful camera open.
    openedCallbackCaptor.getValue().onCameraOpenFailed("Testing a failure.");

    // Verify results.
    verify(callback, times(1)).onError("CameraAccess", "Testing a failure.");
  }

  @Test
  public void itTakesPicture() throws CameraAccessException {
    // Setup test.
    final Camera fakeCamera = initializeFakeCamera(
        cameraSystem,
        "fake_camera",
        "fake_preset",
        true,
        12345l,
        1920,
        1080
    );

    final Camera.OnPictureTakenCallback callback = mock(Camera.OnPictureTakenCallback.class);

    // Execute behavior under test.
    cameraSystem.takePicture("/some/file/path", callback);

    // Verify results.
    verify(fakeCamera, times(1)).takePicture(eq("/some/file/path"), eq(callback));
  }

  @Test
  public void itStartsVideoRecordingHappyPath() throws CameraAccessException, IOException {
    // Setup test.
    final Camera fakeCamera = initializeFakeCamera(
        cameraSystem,
        "fake_camera",
        "fake_preset",
        true,
        12345l,
        1920,
        1080
    );

    final CameraSystem.OnStartVideoRecordingCallback callback = mock(CameraSystem.OnStartVideoRecordingCallback.class);

    // Execute behavior under test.
    cameraSystem.startVideoRecording("/some/file/path", callback);

    // Verify results.
    verify(fakeCamera, times(1)).startVideoRecording(eq("/some/file/path"));
    verifyNoMoreInteractions(callback);
  }

  @Test
  public void itReportsFileAlreadyExistsWhenStartingVideoRecording() throws CameraAccessException, IOException {
    // Setup test.
    final Camera fakeCamera = initializeFakeCamera(
        cameraSystem,
        "fake_camera",
        "fake_preset",
        true,
        12345l,
        1920,
        1080
    );
    doThrow(new IllegalStateException("file already exists"))
        .when(fakeCamera)
        .startVideoRecording(anyString());

    final CameraSystem.OnStartVideoRecordingCallback callback = mock(CameraSystem.OnStartVideoRecordingCallback.class);

    // Execute behavior under test.
    cameraSystem.startVideoRecording("/some/file/path", callback);

    // Verify results.
    verify(callback, times(1)).onFileAlreadyExists(eq("/some/file/path"));
  }

  @Test
  public void itReportsVideoRecordingFailedWhenStartingVideoRecording() throws CameraAccessException, IOException {
    // Setup test.
    final Camera fakeCamera = initializeFakeCamera(
        cameraSystem,
        "fake_camera",
        "fake_preset",
        true,
        12345l,
        1920,
        1080
    );

    CameraAccessException exception = mock(CameraAccessException.class);
    when(exception.getMessage()).thenReturn("fake message");

    doThrow(exception)
        .when(fakeCamera)
        .startVideoRecording(anyString());

    final CameraSystem.OnStartVideoRecordingCallback callback = mock(CameraSystem.OnStartVideoRecordingCallback.class);

    // Execute behavior under test.
    cameraSystem.startVideoRecording("/some/file/path", callback);

    // Verify results.
    verify(callback, times(1)).onVideoRecordingFailed("fake message");
  }

  @Test
  public void itStopsVideoRecordingHappyPath() throws CameraAccessException, IOException {
    // Setup test.
    final Camera fakeCamera = initializeFakeCamera(
        cameraSystem,
        "fake_camera",
        "fake_preset",
        true,
        12345l,
        1920,
        1080
    );

    final CameraSystem.OnVideoRecordingCommandCallback callback = mock(CameraSystem.OnVideoRecordingCommandCallback.class);

    // Execute behavior under test.
    cameraSystem.stopVideoRecording(callback);

    // Verify results.
    verify(fakeCamera, times(1)).stopVideoRecording();
    verify(callback, times(1)).success();
  }

  @Test
  public void itReportsVideoRecordingFailedWhenStoppingVideoRecording() throws CameraAccessException, IOException {
    // Setup test.
    final Camera fakeCamera = initializeFakeCamera(
        cameraSystem,
        "fake_camera",
        "fake_preset",
        true,
        12345l,
        1920,
        1080
    );

    CameraAccessException exception = mock(CameraAccessException.class);
    when(exception.getMessage()).thenReturn("fake message");

    doThrow(exception)
        .when(fakeCamera)
        .stopVideoRecording();

    final CameraSystem.OnVideoRecordingCommandCallback callback = mock(CameraSystem.OnVideoRecordingCommandCallback.class);

    // Execute behavior under test.
    cameraSystem.stopVideoRecording(callback);

    // Verify results.
    verify(callback, times(1)).onVideoRecordingFailed("fake message");
  }

  @Test
  public void itPausesVideoRecordingHappyPath() throws CameraAccessException {
    // Setup test.
    final Camera fakeCamera = initializeFakeCamera(
        cameraSystem,
        "fake_camera",
        "fake_preset",
        true,
        12345l,
        1920,
        1080
    );

    final CameraSystem.OnApiDependentVideoRecordingCommandCallback callback = mock(CameraSystem.OnApiDependentVideoRecordingCommandCallback.class);

    // Execute behavior under test.
    cameraSystem.pauseVideoRecording(callback);

    // Verify results.
    verify(fakeCamera, times(1)).pauseVideoRecording();
    verifyNoMoreInteractions(callback);
  }

  @Test
  public void itReportsUnsupportedOperationWhenPausingVideoRecording() throws CameraAccessException {
    // Setup test.
    final Camera fakeCamera = initializeFakeCamera(
        cameraSystem,
        "fake_camera",
        "fake_preset",
        true,
        12345l,
        1920,
        1080
    );

    doThrow(new UnsupportedOperationException())
        .when(fakeCamera)
        .pauseVideoRecording();

    final CameraSystem.OnApiDependentVideoRecordingCommandCallback callback = mock(CameraSystem.OnApiDependentVideoRecordingCommandCallback.class);

    // Execute behavior under test.
    cameraSystem.pauseVideoRecording(callback);

    // Verify results.
    verify(callback, times(1)).onUnsupportedOperation();
  }

  @Test
  public void itReportsVideoRecordingFailedWhenPausingVideoRecording() throws CameraAccessException {
    // Setup test.
    final Camera fakeCamera = initializeFakeCamera(
        cameraSystem,
        "fake_camera",
        "fake_preset",
        true,
        12345l,
        1920,
        1080
    );

    doThrow(new IllegalStateException("fake failure"))
        .when(fakeCamera)
        .pauseVideoRecording();

    final CameraSystem.OnApiDependentVideoRecordingCommandCallback callback = mock(CameraSystem.OnApiDependentVideoRecordingCommandCallback.class);

    // Execute behavior under test.
    cameraSystem.pauseVideoRecording(callback);

    // Verify results.
    verify(callback, times(1)).onVideoRecordingFailed(eq("fake failure"));
  }

  @Test
  public void itResumesVideoRecordingHappyPath() throws CameraAccessException {
    // Setup test.
    final Camera fakeCamera = initializeFakeCamera(
        cameraSystem,
        "fake_camera",
        "fake_preset",
        true,
        12345l,
        1920,
        1080
    );

    final CameraSystem.OnApiDependentVideoRecordingCommandCallback callback = mock(CameraSystem.OnApiDependentVideoRecordingCommandCallback.class);

    // Execute behavior under test.
    cameraSystem.resumeVideoRecording(callback);

    // Verify results.
    verify(fakeCamera, times(1)).resumeVideoRecording();
    verifyNoMoreInteractions(callback);
  }

  @Test
  public void itReportsUnsupportedOperationWhenResumingVideoRecording() throws CameraAccessException {
    // Setup test.
    final Camera fakeCamera = initializeFakeCamera(
        cameraSystem,
        "fake_camera",
        "fake_preset",
        true,
        12345l,
        1920,
        1080
    );

    doThrow(new UnsupportedOperationException())
        .when(fakeCamera)
        .resumeVideoRecording();

    final CameraSystem.OnApiDependentVideoRecordingCommandCallback callback = mock(CameraSystem.OnApiDependentVideoRecordingCommandCallback.class);

    // Execute behavior under test.
    cameraSystem.resumeVideoRecording(callback);

    // Verify results.
    verify(callback, times(1)).onUnsupportedOperation();
  }

  @Test
  public void itReportsVideoRecordingFailedWhenResumingVideoRecording() throws CameraAccessException {
    // Setup test.
    final Camera fakeCamera = initializeFakeCamera(
        cameraSystem,
        "fake_camera",
        "fake_preset",
        true,
        12345l,
        1920,
        1080
    );

    doThrow(new IllegalStateException("fake failure"))
        .when(fakeCamera)
        .resumeVideoRecording();

    final CameraSystem.OnApiDependentVideoRecordingCommandCallback callback = mock(CameraSystem.OnApiDependentVideoRecordingCommandCallback.class);

    // Execute behavior under test.
    cameraSystem.resumeVideoRecording(callback);

    // Verify results.
    verify(callback, times(1)).onVideoRecordingFailed(eq("fake failure"));
  }

  @Test
  public void itStartsImageStreamHappyPath() throws CameraAccessException {
    // Setup test.
    final Camera fakeCamera = initializeFakeCamera(
        cameraSystem,
        "fake_camera",
        "fake_preset",
        true,
        12345l,
        1920,
        1080
    );

    final CameraSystem.OnCameraAccessCommandCallback callback = mock(CameraSystem.OnCameraAccessCommandCallback.class);

    // Execute behavior under test.
    cameraSystem.startImageStream(callback);

    // Verify results.
    verify(fakeCamera, times(1)).startPreviewWithImageStream(any(CameraPreviewDisplay.class));
    verify(callback, times(1)).success();
  }

  @Test
  public void itReportsCameraAccessFailureWhenStartingImageStream() throws CameraAccessException {
    // Setup test.
    final Camera fakeCamera = initializeFakeCamera(
        cameraSystem,
        "fake_camera",
        "fake_preset",
        true,
        12345l,
        1920,
        1080
    );

    CameraAccessException exception = mock(CameraAccessException.class);
    when(exception.getMessage()).thenReturn("fake failure");

    doThrow(exception)
        .when(fakeCamera)
        .startPreviewWithImageStream(any(CameraPreviewDisplay.class));

    final CameraSystem.OnCameraAccessCommandCallback callback = mock(CameraSystem.OnCameraAccessCommandCallback.class);

    // Execute behavior under test.
    cameraSystem.startImageStream(callback);

    // Verify results.
    verify(callback, times(1)).onCameraAccessFailure(eq("fake failure"));
  }

  @Test
  public void itStopsImageStreamHappyPath() throws CameraAccessException {
    // Setup test.
    final Camera fakeCamera = initializeFakeCamera(
        cameraSystem,
        "fake_camera",
        "fake_preset",
        true,
        12345l,
        1920,
        1080
    );

    final CameraSystem.OnCameraAccessCommandCallback callback = mock(CameraSystem.OnCameraAccessCommandCallback.class);

    // Execute behavior under test.
    cameraSystem.stopImageStream(callback);

    // Verify results.
    verify(fakeCamera, times(1)).startPreview();
    verify(callback, times(1)).success();
  }

  @Test
  public void itReportsCameraAccessFailureWhenStoppingImageStream() throws CameraAccessException {
    // Setup test.
    final Camera fakeCamera = initializeFakeCamera(
        cameraSystem,
        "fake_camera",
        "fake_preset",
        true,
        12345l,
        1920,
        1080
    );

    CameraAccessException exception = mock(CameraAccessException.class);
    when(exception.getMessage()).thenReturn("fake failure");

    doThrow(exception)
        .when(fakeCamera)
        .startPreview();

    final CameraSystem.OnCameraAccessCommandCallback callback = mock(CameraSystem.OnCameraAccessCommandCallback.class);

    // Execute behavior under test.
    cameraSystem.stopImageStream(callback);

    // Verify results.
    verify(callback, times(1)).onCameraAccessFailure(eq("fake failure"));
  }

  @Test
  public void itDisposesActiveCamera() throws CameraAccessException {
    // Setup test.
    final Camera fakeCamera = initializeFakeCamera(
        cameraSystem,
        "fake_camera",
        "fake_preset",
        true,
        12345l,
        1920,
        1080
    );

    // Execute behavior under test.
    cameraSystem.dispose();

    // Verify results.
    verify(fakeCamera, times(1)).dispose();
  }

  /**
   * Most CameraSystem behaviors depend on first having a Camera created and opened. This method
   * sets up fakes and runs CameraSystem through its initialization process, preparing it for
   * camera-specific behaviors.
   */
  private Camera initializeFakeCamera(
      @NonNull CameraSystem cameraSystem,
      @NonNull String cameraName,
      @NonNull String resolutionPreset,
      boolean enableAudio,
      long textureId,
      int previewWidth,
      int previewHeight
  ) throws CameraAccessException {
    // Grant all permissions.
    grantFakePermissions();

    // Setup CameraFactory to return a fake Camera.
    final Camera fakeCamera = mock(Camera.class);
    when(cameraFactory.createCamera(anyString(), anyString(), anyBoolean())).thenReturn(fakeCamera);

    // Configure CameraEventChannelFactory to return a fake EventChannel
    final EventChannel fakeEventChannel = mock(EventChannel.class);
    when(cameraEventChannelFactory.createCameraEventChannel(anyLong())).thenReturn(fakeEventChannel);
    final EventChannel.EventSink fakeEventSink = mock(EventChannel.EventSink.class);

    final CameraSystem.CameraConfigurationRequest request = new CameraSystem.CameraConfigurationRequest(
        cameraName,
        resolutionPreset,
        enableAudio
    );

    CameraSystem.OnCameraInitializationCallback callback = mock(CameraSystem.OnCameraInitializationCallback.class);

    // Execute behavior under test.
    cameraSystem.initialize(request, callback);

    // Capture the cameraEventChannel's stream handler and invoke it.
    ArgumentCaptor<EventChannel.StreamHandler> streamHandlerCaptor = ArgumentCaptor.forClass(EventChannel.StreamHandler.class);
    verify(fakeEventChannel, times(1)).setStreamHandler(streamHandlerCaptor.capture());

    // Simulate a successful opening of the camera's event stream.
    streamHandlerCaptor.getValue().onListen(null, fakeEventSink);

    // Capture the OnCameraOpenedCallback.
    ArgumentCaptor<Camera.OnCameraOpenedCallback> openedCallbackCaptor = ArgumentCaptor.forClass(Camera.OnCameraOpenedCallback.class);
    verify(fakeCamera, times(1)).open(openedCallbackCaptor.capture());

    // Simulate a successful camera open.
    openedCallbackCaptor.getValue().onCameraOpened(
        12345l,
        1920,
        1080
    );

    return fakeCamera;
  }

  private void grantFakePermissions() {
    // Permission queries return true.
    when(cameraPermissions.hasCameraPermission()).thenReturn(true);
    when(cameraPermissions.hasAudioPermission()).thenReturn(true);

    // Permission requests automatically report success.
    doAnswer(new Answer<Void>() {
      @Override
      public Void answer(InvocationOnMock invocation) {
        // immediately invoke success to pretend permissions are granted.
        CameraPermissions.ResultCallback callback = invocation.getArgument(1);
        callback.onSuccess();
        return null;
      }
    }).when(cameraPermissions).requestPermissions(anyBoolean(), any(ResultCallback.class));
  }

  private void declineFakePermissions(
      @NonNull String errorCode,
      @NonNull String errorDescription
  ) {
    // Permission queries return false.
    when(cameraPermissions.hasCameraPermission()).thenReturn(false);
    when(cameraPermissions.hasAudioPermission()).thenReturn(false);

    // Permission requests automatically report failure.
    doAnswer(new Answer<Void>() {
      @Override
      public Void answer(InvocationOnMock invocation) {
        // immediately invoke success to pretend permissions are granted.
        CameraPermissions.ResultCallback callback = invocation.getArgument(1);
        callback.onResult(errorCode, errorDescription);
        return null;
      }
    }).when(cameraPermissions).requestPermissions(anyBoolean(), any(ResultCallback.class));
  }
}
