package io.flutter.plugins.camera;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.graphics.ImageFormat;
import android.graphics.Rect;
import android.graphics.SurfaceTexture;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.CaptureFailure;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.CaptureResult;
import android.hardware.camera2.TotalCaptureResult;
import android.hardware.camera2.params.OutputConfiguration;
import android.hardware.camera2.params.SessionConfiguration;
import android.media.CamcorderProfile;
import android.media.Image;
import android.media.ImageReader;
import android.media.MediaRecorder;
import android.os.Build;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.util.Size;
import android.view.OrientationEventListener;
import android.view.Surface;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.Executors;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.camera.PictureCaptureRequest.State;
import io.flutter.plugins.camera.media.MediaRecorderBuilder;
import io.flutter.plugins.camera.types.FlashMode;
import io.flutter.plugins.camera.types.ResolutionPreset;
import io.flutter.view.TextureRegistry.SurfaceTextureEntry;

import static android.view.OrientationEventListener.ORIENTATION_UNKNOWN;
import static io.flutter.plugins.camera.CameraUtils.computeBestPreviewSize;

public class Camera {
    private final SurfaceTextureEntry flutterTexture;
    private final CameraManager cameraManager;
    private final OrientationEventListener orientationEventListener;
    private final boolean isFrontFacing;
    private final int sensorOrientation;
    private final String cameraName;
    private final Size captureSize;
    private final Size previewSize;
    private final boolean enableAudio;
    private final Context applicationContext;
    private final CamcorderProfile recordingProfile;
    private final DartMessenger dartMessenger;
    private final CameraZoom cameraZoom;

    private CameraDevice cameraDevice;
    private CameraCaptureSession cameraCaptureSession;
    private ImageReader pictureImageReader;
    private ImageReader imageStreamReader;
    private CaptureRequest.Builder captureRequestBuilder;
    private MediaRecorder mediaRecorder;
    private boolean recordingVideo;
    private File videoRecordingFile;
    private int currentOrientation = ORIENTATION_UNKNOWN;
    private FlashMode flashMode;
    private PictureCaptureRequest pictureCaptureRequest;

    public Camera(
            final Activity activity,
            final SurfaceTextureEntry flutterTexture,
            final DartMessenger dartMessenger,
            final String cameraName,
            final String resolutionPreset,
            final boolean enableAudio)
            throws CameraAccessException {
        if (activity == null) {
            throw new IllegalStateException("No activity available!");
        }
        this.cameraName = cameraName;
        this.enableAudio = enableAudio;
        this.flutterTexture = flutterTexture;
        this.dartMessenger = dartMessenger;
        this.cameraManager = (CameraManager) activity.getSystemService(Context.CAMERA_SERVICE);
        this.applicationContext = activity.getApplicationContext();
        this.flashMode = FlashMode.auto;
        orientationEventListener =
                new OrientationEventListener(activity.getApplicationContext()) {
                    @Override
                    public void onOrientationChanged(int i) {
                        if (i == ORIENTATION_UNKNOWN) {
                            return;
                        }
                        // Convert the raw deg angle to the nearest multiple of 90.
                        currentOrientation = (int) Math.round(i / 90.0) * 90;
                    }
                };
        orientationEventListener.enable();

        CameraCharacteristics characteristics = cameraManager.getCameraCharacteristics(cameraName);
        sensorOrientation = characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION);
        isFrontFacing =
                characteristics.get(CameraCharacteristics.LENS_FACING) == CameraMetadata.LENS_FACING_FRONT;
        ResolutionPreset preset = ResolutionPreset.valueOf(resolutionPreset);
        recordingProfile =
                CameraUtils.getBestAvailableCamcorderProfileForResolutionPreset(cameraName, preset);
        captureSize = new Size(recordingProfile.videoFrameWidth, recordingProfile.videoFrameHeight);
        previewSize = computeBestPreviewSize(cameraName, preset);
        cameraZoom =
                new CameraZoom(
                        characteristics.get(CameraCharacteristics.SENSOR_INFO_ACTIVE_ARRAY_SIZE),
                        characteristics.get(CameraCharacteristics.SCALER_AVAILABLE_MAX_DIGITAL_ZOOM));
    }

    private void prepareMediaRecorder(String outputFilePath) throws IOException {
        if (mediaRecorder != null) {
            mediaRecorder.release();
        }

        mediaRecorder =
                new MediaRecorderBuilder(recordingProfile, outputFilePath)
                        .setEnableAudio(enableAudio)
                        .setMediaOrientation(getMediaOrientation())
                        .build();
    }

    @SuppressLint("MissingPermission")
    public void open() throws CameraAccessException {
        pictureImageReader =
                ImageReader.newInstance(
                        captureSize.getWidth(), captureSize.getHeight(), ImageFormat.JPEG, 2);

        // Used to steam image byte data to dart side.
        imageStreamReader =
                ImageReader.newInstance(
                        previewSize.getWidth(), previewSize.getHeight(), ImageFormat.YUV_420_888, 2);

        cameraManager.openCamera(
                cameraName,
                new CameraDevice.StateCallback() {
                    @Override
                    public void onOpened(@NonNull CameraDevice device) {
                        cameraDevice = device;
                        try {
                            startPreview();
                        } catch (CameraAccessException e) {
                            dartMessenger.sendCameraErrorEvent(e.getMessage());
                            close();
                            return;
                        }

                        dartMessenger.sendCameraInitializedEvent(
                                previewSize.getWidth(), previewSize.getHeight());
                    }

                    @Override
                    public void onClosed(@NonNull CameraDevice camera) {
                        dartMessenger.sendCameraClosingEvent();
                        super.onClosed(camera);
                    }

                    @Override
                    public void onDisconnected(@NonNull CameraDevice cameraDevice) {
                        close();
                        dartMessenger.sendCameraErrorEvent("The camera was disconnected.");
                    }

                    @Override
                    public void onError(@NonNull CameraDevice cameraDevice, int errorCode) {
                        close();
                        String errorDescription;
                        switch (errorCode) {
                            case ERROR_CAMERA_IN_USE:
                                errorDescription = "The camera device is in use already.";
                                break;
                            case ERROR_MAX_CAMERAS_IN_USE:
                                errorDescription = "Max cameras in use";
                                break;
                            case ERROR_CAMERA_DISABLED:
                                errorDescription = "The camera device could not be opened due to a device policy.";
                                break;
                            case ERROR_CAMERA_DEVICE:
                                errorDescription = "The camera device has encountered a fatal error";
                                break;
                            case ERROR_CAMERA_SERVICE:
                                errorDescription = "The camera service has encountered a fatal error.";
                                break;
                            default:
                                errorDescription = "Unknown camera error";
                        }
                        dartMessenger.sendCameraErrorEvent(errorDescription);
                    }
                },
                null);
    }

    private void writeToFile(ByteBuffer buffer, File file) throws IOException {
        try (FileOutputStream outputStream = new FileOutputStream(file)) {
            while (0 < buffer.remaining()) {
                outputStream.getChannel().write(buffer);
            }
        }
    }

    public void takePicture(@NonNull final Result result) {
        // Only take 1 picture at a time
        if (pictureCaptureRequest != null && !pictureCaptureRequest.isFinished()) {
            result.error("captureAlreadyActive", "Picture is currently already being captured", null);
            return;
        }
        // Store the result
        this.pictureCaptureRequest = new PictureCaptureRequest(result);

        // Create temporary file
        final File outputDir = applicationContext.getCacheDir();
        final File file;
        try {
            file = File.createTempFile("CAP", ".jpg", outputDir);
        } catch (IOException | SecurityException e) {
            pictureCaptureRequest.error("cannotCreateFile", e.getMessage(), null);
            return;
        }

        // Listen for picture being taken
        pictureImageReader.setOnImageAvailableListener(
                reader -> {
                    try (Image image = reader.acquireLatestImage()) {
                        ByteBuffer buffer = image.getPlanes()[0].getBuffer();
                        writeToFile(buffer, file);
                        pictureCaptureRequest.finish(file.getAbsolutePath());
                        cameraCaptureSession.setRepeatingRequest(captureRequestBuilder.build(), pictureCaptureCallback, null);
                    } catch (CameraAccessException e) {
                        pictureCaptureRequest.error("cameraAccess", e.getMessage(), null);
                    } catch (IOException e) {
                        pictureCaptureRequest.error("IOError", "Failed saving image", null);
                    }
                },
                null);

        runPictureAutoFocus();
    }

    private final CameraCaptureSession.CaptureCallback pictureCaptureCallback =
            new CameraCaptureSession.CaptureCallback() {
                @Override
                public void onCaptureCompleted(
                        @NonNull CameraCaptureSession session,
                        @NonNull CaptureRequest request,
                        @NonNull TotalCaptureResult result) {
                    processCapture(result);
                }

                @Override
                public void onCaptureProgressed(@NonNull CameraCaptureSession session,
                                                @NonNull CaptureRequest request, @NonNull CaptureResult partialResult) {
                    processCapture(partialResult);
                }

                @Override
                public void onCaptureFailed(
                        @NonNull CameraCaptureSession session,
                        @NonNull CaptureRequest request,
                        @NonNull CaptureFailure failure) {
                    assert (pictureCaptureRequest != null);
                    String reason;
                    switch (failure.getReason()) {
                        case CaptureFailure.REASON_ERROR:
                            reason = "An error happened in the framework";
                            break;
                        case CaptureFailure.REASON_FLUSHED:
                            reason = "The capture has failed due to an abortCaptures() call";
                            break;
                        default:
                            reason = "Unknown reason";
                    }
                    pictureCaptureRequest.error("captureFailure", reason, null);
                }

                private void processCapture(CaptureResult result) {
                    if (pictureCaptureRequest == null) {
                        return;
                    }

                    Integer aeState = result.get(CaptureResult.CONTROL_AE_STATE);
                    Integer afState = result.get(CaptureResult.CONTROL_AF_STATE);
                    switch (pictureCaptureRequest.getState()) {
                        case focusing:
                            if (afState == null) {
                                return;
                            } else if (afState == CaptureResult.CONTROL_AF_STATE_FOCUSED_LOCKED ||
                                    afState == CaptureResult.CONTROL_AF_STATE_NOT_FOCUSED_LOCKED) {
                                // Some devices might return null here, in which case we will also continue.
                                if (aeState == null || aeState == CaptureResult.CONTROL_AE_STATE_CONVERGED) {
                                    runPictureCapture();
                                } else {
                                    runPicturePreCapture();
                                }
                            }
                            break;
                        case preCapture:
                            // Some devices might return null here, in which case we will also continue.
                            if (aeState == null
                                    || aeState == CaptureRequest.CONTROL_AE_STATE_PRECAPTURE
                                    || aeState == CaptureRequest.CONTROL_AE_STATE_FLASH_REQUIRED
                                    || aeState == CaptureRequest.CONTROL_AE_STATE_CONVERGED) {
                                pictureCaptureRequest.setState(State.waitingPreCaptureReady);
                            }
                            break;
                        case waitingPreCaptureReady:
                            if (aeState == null
                                    || aeState != CaptureRequest.CONTROL_AE_STATE_PRECAPTURE) {
                                runPictureCapture();
                            }
                    }
                }
            };

    private void runPictureAutoFocus() {
        assert (pictureCaptureRequest != null);
        pictureCaptureRequest.setState(PictureCaptureRequest.State.focusing);

        captureRequestBuilder.set(
                CaptureRequest.CONTROL_AF_TRIGGER,
                CaptureRequest.CONTROL_AF_TRIGGER_START);
        try {
            cameraCaptureSession.capture(captureRequestBuilder.build(), pictureCaptureCallback, null);
            captureRequestBuilder.set(
                    CaptureRequest.CONTROL_AF_TRIGGER,
                    CaptureRequest.CONTROL_AF_TRIGGER_IDLE);
        } catch (CameraAccessException e) {
            pictureCaptureRequest.error("cameraAccess", e.getMessage(), null);
        }
    }

    private void runPicturePreCapture() {
        assert (pictureCaptureRequest != null);
        pictureCaptureRequest.setState(PictureCaptureRequest.State.preCapture);

        captureRequestBuilder.set(
                CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER,
                CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER_START);
        try {
            cameraCaptureSession.capture(captureRequestBuilder.build(), pictureCaptureCallback, null);
            captureRequestBuilder.set(
                    CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER,
                    CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER_IDLE);
        } catch (CameraAccessException e) {
            pictureCaptureRequest.error("cameraAccess", e.getMessage(), null);
        }
    }

    private void runPictureCapture() {
        assert (pictureCaptureRequest != null);
        pictureCaptureRequest.setState(PictureCaptureRequest.State.capturing);
        try {
            final CaptureRequest.Builder captureBuilder =
                    cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_STILL_CAPTURE);
            captureBuilder.addTarget(pictureImageReader.getSurface());
            captureBuilder.set(CaptureRequest.JPEG_ORIENTATION, getMediaOrientation());
            switch (flashMode) {
                case off:
                    captureBuilder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON);
                    captureBuilder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF);
                    break;
                case auto:
                    captureBuilder.set(
                            CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON_AUTO_FLASH);
                    break;
                case always:
                default:
                    captureBuilder.set(
                            CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON_ALWAYS_FLASH);
                    break;
            }
            cameraCaptureSession.stopRepeating();
            cameraCaptureSession.capture(captureBuilder.build(), null, null);
        } catch (CameraAccessException e) {
            pictureCaptureRequest.error("cameraAccess", e.getMessage(), null);
        }
    }

    private void createCaptureSession(int templateType, Surface... surfaces)
            throws CameraAccessException {
        createCaptureSession(templateType, null, surfaces);
    }

    private void createCaptureSession(
            int templateType, Runnable onSuccessCallback, Surface... surfaces)
            throws CameraAccessException {
        // Close any existing capture session.
        closeCaptureSession();

        // Create a new capture builder.
        captureRequestBuilder = cameraDevice.createCaptureRequest(templateType);

        // Build Flutter surface to render to
        SurfaceTexture surfaceTexture = flutterTexture.surfaceTexture();
        surfaceTexture.setDefaultBufferSize(previewSize.getWidth(), previewSize.getHeight());
        Surface flutterSurface = new Surface(surfaceTexture);
        captureRequestBuilder.addTarget(flutterSurface);

        List<Surface> remainingSurfaces = Arrays.asList(surfaces);
        if (templateType != CameraDevice.TEMPLATE_PREVIEW) {
            // If it is not preview mode, add all surfaces as targets.
            for (Surface surface : remainingSurfaces) {
                captureRequestBuilder.addTarget(surface);
            }
        }

        // Prepare the callback
        CameraCaptureSession.StateCallback callback =
                new CameraCaptureSession.StateCallback() {
                    @Override
                    public void onConfigured(@NonNull CameraCaptureSession session) {
                        try {
                            if (cameraDevice == null) {
                                dartMessenger.sendCameraErrorEvent("The camera was closed during configuration.");
                                return;
                            }
                            cameraCaptureSession = session;
                            initPreviewCaptureBuilder();
                            cameraCaptureSession.setRepeatingRequest(captureRequestBuilder.build(), pictureCaptureCallback, new Handler(Looper.getMainLooper()));
                            if (onSuccessCallback != null) {
                                onSuccessCallback.run();
                            }
                        } catch (CameraAccessException | IllegalStateException | IllegalArgumentException e) {
                            e.printStackTrace();
                            Log.d("WOOPS", e.getMessage());
                            dartMessenger.sendCameraErrorEvent(e.getMessage());
                        }
                    }

                    @Override
                    public void onConfigureFailed(@NonNull CameraCaptureSession cameraCaptureSession) {
                        dartMessenger.sendCameraErrorEvent("Failed to configure camera session.");
                    }
                };

        // Start the session
        if (VERSION.SDK_INT >= VERSION_CODES.P) {
            // Collect all surfaces we want to render to.
            List<OutputConfiguration> configs = new ArrayList<>();
            configs.add(new OutputConfiguration(flutterSurface));
            for (Surface surface : remainingSurfaces) {
                configs.add(new OutputConfiguration(surface));
            }
            createCaptureSessionWithSessionConfig(configs, callback);
        } else {
            // Collect all surfaces we want to render to.
            List<Surface> surfaceList = new ArrayList<>();
            surfaceList.add(flutterSurface);
            surfaceList.addAll(remainingSurfaces);
            createCaptureSession(surfaceList, callback);
        }
    }

    @TargetApi(VERSION_CODES.P)
    private void createCaptureSessionWithSessionConfig(
            List<OutputConfiguration> outputConfigs, CameraCaptureSession.StateCallback callback)
            throws CameraAccessException {
        cameraDevice.createCaptureSession(
                new SessionConfiguration(
                        SessionConfiguration.SESSION_REGULAR,
                        outputConfigs,
                        Executors.newSingleThreadExecutor(),
                        callback));
    }

    @TargetApi(VERSION_CODES.LOLLIPOP)
    @SuppressWarnings("deprecation")
    private void createCaptureSession(
            List<Surface> surfaces, CameraCaptureSession.StateCallback callback)
            throws CameraAccessException {
        cameraDevice.createCaptureSession(surfaces, callback, null);
    }

    public void startVideoRecording(Result result) {
        final File outputDir = applicationContext.getCacheDir();
        try {
            videoRecordingFile = File.createTempFile("REC", ".mp4", outputDir);
        } catch (IOException | SecurityException e) {
            result.error("cannotCreateFile", e.getMessage(), null);
            return;
        }

        try {
            prepareMediaRecorder(videoRecordingFile.getAbsolutePath());
            recordingVideo = true;
            createCaptureSession(
                    CameraDevice.TEMPLATE_RECORD, () -> mediaRecorder.start(), mediaRecorder.getSurface());
            result.success(null);
        } catch (CameraAccessException | IOException e) {
            recordingVideo = false;
            videoRecordingFile = null;
            result.error("videoRecordingFailed", e.getMessage(), null);
        }
    }

    public void stopVideoRecording(@NonNull final Result result) {
        if (!recordingVideo) {
            result.success(null);
            return;
        }

        try {
            recordingVideo = false;
            mediaRecorder.stop();
            mediaRecorder.reset();
            startPreview();
            result.success(videoRecordingFile.getAbsolutePath());
            videoRecordingFile = null;
        } catch (CameraAccessException | IllegalStateException e) {
            result.error("videoRecordingFailed", e.getMessage(), null);
        }
    }

    public void pauseVideoRecording(@NonNull final Result result) {
        if (!recordingVideo) {
            result.success(null);
            return;
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                mediaRecorder.pause();
            } else {
                result.error("videoRecordingFailed", "pauseVideoRecording requires Android API +24.", null);
                return;
            }
        } catch (IllegalStateException e) {
            result.error("videoRecordingFailed", e.getMessage(), null);
            return;
        }

        result.success(null);
    }

    public void resumeVideoRecording(@NonNull final Result result) {
        if (!recordingVideo) {
            result.success(null);
            return;
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                mediaRecorder.resume();
            } else {
                result.error(
                        "videoRecordingFailed", "resumeVideoRecording requires Android API +24.", null);
                return;
            }
        } catch (IllegalStateException e) {
            result.error("videoRecordingFailed", e.getMessage(), null);
            return;
        }

        result.success(null);
    }

    public void setFlashMode(@NonNull final Result result, FlashMode mode)
            throws CameraAccessException {
        // Get the flash availability
        Boolean flashAvailable;
        try {
            flashAvailable =
                    cameraManager
                            .getCameraCharacteristics(cameraDevice.getId())
                            .get(CameraCharacteristics.FLASH_INFO_AVAILABLE);
        } catch (CameraAccessException e) {
            result.error("setFlashModeFailed", e.getMessage(), null);
            return;
        }
        // Check if flash is available.
        if (flashAvailable == null || !flashAvailable) {
            result.error("setFlashModeFailed", "Device does not have flash capabilities", null);
            return;
        }
        // Get flash
        this.flashMode = mode;
        initPreviewCaptureBuilder();
        this.cameraCaptureSession.setRepeatingRequest(captureRequestBuilder.build(), pictureCaptureCallback, null);
        result.success(null);
    }

    private void initPreviewCaptureBuilder() {
        captureRequestBuilder.set(CaptureRequest.CONTROL_MODE, CaptureRequest.CONTROL_MODE_AUTO);
        switch (flashMode) {
            case off:
                captureRequestBuilder.set(
                        CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON);
                captureRequestBuilder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF);
                break;
            case auto:
                captureRequestBuilder.set(
                        CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON_AUTO_FLASH);
                captureRequestBuilder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF);
                break;
            case always:
                captureRequestBuilder.set(
                        CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON_ALWAYS_FLASH);
                captureRequestBuilder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF);
                break;
            case torch:
            default:
                captureRequestBuilder.set(
                        CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON);
                captureRequestBuilder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_TORCH);
                break;
        }
        captureRequestBuilder.set(CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_PICTURE);
    }

    public void startPreview() throws CameraAccessException {
        if (pictureImageReader == null || pictureImageReader.getSurface() == null) return;

        createCaptureSession(CameraDevice.TEMPLATE_PREVIEW, pictureImageReader.getSurface());
    }

    public void startPreviewWithImageStream(EventChannel imageStreamChannel)
            throws CameraAccessException {
        createCaptureSession(CameraDevice.TEMPLATE_RECORD, imageStreamReader.getSurface());

        imageStreamChannel.setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object o, EventChannel.EventSink imageStreamSink) {
                        setImageStreamImageAvailableListener(imageStreamSink);
                    }

                    @Override
                    public void onCancel(Object o) {
                        imageStreamReader.setOnImageAvailableListener(null, null);
                    }
                });
    }

    private void setImageStreamImageAvailableListener(final EventChannel.EventSink imageStreamSink) {
        imageStreamReader.setOnImageAvailableListener(
                reader -> {
                    Image img = reader.acquireLatestImage();
                    if (img == null) return;

                    List<Map<String, Object>> planes = new ArrayList<>();
                    for (Image.Plane plane : img.getPlanes()) {
                        ByteBuffer buffer = plane.getBuffer();

                        byte[] bytes = new byte[buffer.remaining()];
                        buffer.get(bytes, 0, bytes.length);

                        Map<String, Object> planeBuffer = new HashMap<>();
                        planeBuffer.put("bytesPerRow", plane.getRowStride());
                        planeBuffer.put("bytesPerPixel", plane.getPixelStride());
                        planeBuffer.put("bytes", bytes);

                        planes.add(planeBuffer);
                    }

                    Map<String, Object> imageBuffer = new HashMap<>();
                    imageBuffer.put("width", img.getWidth());
                    imageBuffer.put("height", img.getHeight());
                    imageBuffer.put("format", img.getFormat());
                    imageBuffer.put("planes", planes);

                    imageStreamSink.success(imageBuffer);
                    img.close();
                },
                null);
    }

    public float getMaxZoomLevel() {
        return cameraZoom.maxZoom;
    }

    public float getMinZoomLevel() {
        return CameraZoom.DEFAULT_ZOOM_FACTOR;
    }

    public void setZoomLevel(@NonNull final Result result, float zoom) throws CameraAccessException {
        float maxZoom = cameraZoom.maxZoom;
        float minZoom = CameraZoom.DEFAULT_ZOOM_FACTOR;

        if (zoom > maxZoom || zoom < minZoom) {
            String errorMessage =
                    String.format(
                            Locale.ENGLISH,
                            "Zoom level out of bounds (zoom level should be between %f and %f).",
                            minZoom,
                            maxZoom);
            result.error("ZOOM_ERROR", errorMessage, null);
            return;
        }

        //Zoom area is calculated relative to sensor area (activeRect)
        if (captureRequestBuilder != null) {
            final Rect computedZoom = cameraZoom.computeZoom(zoom);
            captureRequestBuilder.set(CaptureRequest.SCALER_CROP_REGION, computedZoom);
            cameraCaptureSession.setRepeatingRequest(captureRequestBuilder.build(), null, null);
        }

        result.success(null);
    }

    private void closeCaptureSession() {
        if (cameraCaptureSession != null) {
            cameraCaptureSession.close();
            cameraCaptureSession = null;
        }
    }

    public void close() {
        closeCaptureSession();

        if (cameraDevice != null) {
            cameraDevice.close();
            cameraDevice = null;
        }
        if (pictureImageReader != null) {
            pictureImageReader.close();
            pictureImageReader = null;
        }
        if (imageStreamReader != null) {
            imageStreamReader.close();
            imageStreamReader = null;
        }
        if (mediaRecorder != null) {
            mediaRecorder.reset();
            mediaRecorder.release();
            mediaRecorder = null;
        }
    }

    public void dispose() {
        close();
        flutterTexture.release();
        orientationEventListener.disable();
    }

    private int getMediaOrientation() {
        final int sensorOrientationOffset =
                (currentOrientation == ORIENTATION_UNKNOWN)
                        ? 0
                        : (isFrontFacing) ? -currentOrientation : currentOrientation;
        return (sensorOrientationOffset + sensorOrientation + 360) % 360;
    }
}
