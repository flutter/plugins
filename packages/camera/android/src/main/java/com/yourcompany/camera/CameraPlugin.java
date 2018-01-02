package com.yourcompany.camera;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.ImageFormat;
import android.graphics.Point;
import android.graphics.SurfaceTexture;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterView;

import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.TotalCaptureResult;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.media.Image;
import android.media.ImageReader;
import android.os.Bundle;
import android.os.Environment;
import android.support.annotation.NonNull;
import android.util.Log;
import android.util.Size;
import android.util.SparseIntArray;
import android.view.Surface;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CameraPlugin implements MethodCallHandler {

    private static CameraManager cameraManager;

    private Activity activity;
    private Registrar registrar;

    // The code to run after requesting the permission.
    private Runnable cameraPermissionContinuation;
    private Runnable storagePermissionContinuation;

    private static final int cameraRequestId = 513469796;
    private static final int storageRequestId = 513469797;

    private class CameraRequestPermissionListener implements PluginRegistry.RequestPermissionResultListener {
        @Override
        public boolean onRequestPermissionResult(int id, String[] permissions, int[] grantResults) {
            if (id == cameraRequestId) {
                cameraPermissionContinuation.run();
            } else if (id == storageRequestId) {
                storagePermissionContinuation.run();
            }
            return false;
        }
    }

    private static class CompareSizesByArea implements Comparator<Size> {
        @Override
        public int compare(Size lhs, Size rhs) {
            // We cast here to ensure the multiplications won't overflow
            return Long.signum((long) lhs.getWidth() * lhs.getHeight() -
                    (long) rhs.getWidth() * rhs.getHeight());
        }
    }

    private static final SparseIntArray ORIENTATIONS = new SparseIntArray();

    static {
        ORIENTATIONS.append(Surface.ROTATION_0, 0);
        ORIENTATIONS.append(Surface.ROTATION_90, 90);
        ORIENTATIONS.append(Surface.ROTATION_180, 180);
        ORIENTATIONS.append(Surface.ROTATION_270, 270);
    }

    private class Cam {
        private final FlutterView.SurfaceTextureEntry textureEntry;
        private CameraDevice cameraDevice;
        private Surface previewSurface;
        private CameraCaptureSession cameraCaptureSession;
        private EventChannel.EventSink eventSink;
        private ImageReader imageReader;
        private boolean started = false;
        private int sensorOrientation;
        private boolean facingFront;
        private String cameraName;
        private boolean initialized = false;

        Cam(final EventChannel eventChannel,
            final FlutterView.SurfaceTextureEntry textureEntry,
            final String cameraName,
            final Result result,
            final Size previewSize,
            final Size captureSize) {
            this.textureEntry = textureEntry;
            this.cameraName = cameraName;
            imageReader = ImageReader.newInstance(captureSize.getWidth(), captureSize.getHeight(), ImageFormat.JPEG, 2);
            SurfaceTexture surfaceTexture = textureEntry.surfaceTexture();
            surfaceTexture.setDefaultBufferSize(previewSize.getWidth(), previewSize.getHeight());
            previewSurface = new Surface(surfaceTexture);
            eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
                @Override
                public void onListen(Object arguments, EventChannel.EventSink eventSink) {
                    Cam.this.eventSink = eventSink;
                }

                @Override
                public void onCancel(Object arguments) {
                    Cam.this.eventSink = null;
                }
            });
            if (cameraPermissionContinuation != null) {
                result.error("cameraPermission", "Camera permission request ongoing", null);
            }
            cameraPermissionContinuation = new Runnable() {
                @Override
                public void run() {
                    cameraPermissionContinuation = null;

                    openCamera(result);
                }
            };
            if (activity.checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                cameraPermissionContinuation.run();
            } else {
                activity.requestPermissions(new String[]{Manifest.permission.CAMERA}, cameraRequestId);
            }

        }

        private void openCamera(final Result result) {
            if (activity.checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                result.error("cameraPermission", "Camera permission not granted", null);
            } else {
                try {
                    //noinspection ConstantConditions
                    sensorOrientation = cameraManager.getCameraCharacteristics(cameraName).get(CameraCharacteristics.SENSOR_ORIENTATION);
                    //noinspection ConstantConditions
                    facingFront = cameraManager.getCameraCharacteristics(cameraName).get(CameraCharacteristics.LENS_FACING) == CameraMetadata.LENS_FACING_FRONT;
                    cameraManager.openCamera(cameraName, new CameraDevice.StateCallback() {
                        @Override
                        public void onOpened(@NonNull CameraDevice cameraDevice) {
                            Cam.this.cameraDevice = cameraDevice;
                            List<Surface> surfaceList = new ArrayList<>();
                            surfaceList.add(previewSurface);
                            surfaceList.add(imageReader.getSurface());

                            try {
                                cameraDevice.createCaptureSession(surfaceList, new CameraCaptureSession.StateCallback() {
                                    @Override
                                    public void onConfigured(@NonNull CameraCaptureSession cameraCaptureSession) {
                                        Cam.this.cameraCaptureSession = cameraCaptureSession;
                                        initialized = true;
                                        result.success(textureEntry.id());
                                    }

                                    @Override
                                    public void onConfigureFailed(@NonNull CameraCaptureSession cameraCaptureSession) {
                                        result.error("configureFailed", "Failed to configure camera session", null);
                                    }
                                }, null);
                            } catch (CameraAccessException e) {
                                result.error("cameraAccess", e.toString(), null);
                            }
                        }

                        @Override
                        public void onDisconnected(@NonNull CameraDevice cameraDevice) {
                            if (eventSink != null) {
                                eventSink.success("disconnected");
                            }
                        }

                        @Override
                        public void onError(@NonNull CameraDevice cameraDevice, int i) {
                            if (eventSink != null) {
                                // TODO (sigurdm): Add error description.
                                eventSink.success("error");
                            }
                        }
                    }, null);
                } catch (CameraAccessException e) {
                    result.error("cameraAccess", e.toString(), null);
                }

            }
        }

        void start() throws CameraAccessException {
            final CaptureRequest.Builder previewRequestBuilder = cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW);
            previewRequestBuilder.set(CaptureRequest.CONTROL_AF_MODE,
                    CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_PICTURE);
            previewRequestBuilder.addTarget(previewSurface);
            CaptureRequest previewRequest = previewRequestBuilder.build();
            cameraCaptureSession.setRepeatingRequest(previewRequest,
                    new CameraCaptureSession.CaptureCallback() {
                        @Override
                        public void onCaptureBufferLost(@NonNull CameraCaptureSession session, @NonNull CaptureRequest request, @NonNull Surface target, long frameNumber) {
                            super.onCaptureBufferLost(session, request, target, frameNumber);
                            if (eventSink != null) {
                                eventSink.success("lost buffer");
                            }
                        }
                    }, null);
            started = true;
        }

        void pause() {
            if (!initialized) return;
            if (started) {
                try {
                    cameraCaptureSession.stopRepeating();
                } catch (CameraAccessException e) {
                    e.printStackTrace();
                }
            }
            if (cameraCaptureSession != null) {
                cameraCaptureSession.close();
            }
            if (cameraDevice != null) {
                cameraDevice.close();
            }
        }

        void resume() {
            if (!initialized) return;
            openCamera(new Result() {
                @Override
                public void success(Object o) {
                    if (started) {
                        try {
                            start();
                        } catch (CameraAccessException e) {
                            // TODO(sigurdm): Report error to Flutter.
                            e.printStackTrace();
                        }
                    }
                }

                @Override
                public void error(String s, String s1, Object o) {
                }

                @Override
                public void notImplemented() {
                }
            });
        }

        void capture(String filename, final Result result) throws CameraAccessException {
            final File file = new File(Environment.getExternalStorageDirectory() + "/" + filename + ".jpg");
            imageReader.setOnImageAvailableListener(new ImageReader.OnImageAvailableListener() {
                @Override
                public void onImageAvailable(ImageReader reader) {
                    Image image = null;
                    boolean success = false;
                    try {
                        image = reader.acquireLatestImage();
                        ByteBuffer buffer = image.getPlanes()[0].getBuffer();
                        byte[] bytes = new byte[buffer.capacity()];
                        buffer.get(bytes);
                        OutputStream output = null;
                        try {
                            output = new FileOutputStream(file);
                            output.write(bytes);
                            result.success(file.getAbsolutePath());
                            success = true;
                        } finally {
                            if (null != output) {
                                output.close();
                                try {
                                    start();
                                } catch (CameraAccessException e) {
                                    e.printStackTrace();
                                }
                            }
                        }
                    } catch (IOException e) {
                        e.printStackTrace();  // TODO: error handling
                    } finally {
                        if (image != null) {
                            image.close();
                        }
                        if (!success) result.error("Failed", null, null);
                    }
                }
            }, null);


            storagePermissionContinuation = new Runnable() {
                @Override
                public void run() {
                    storagePermissionContinuation = null;
                    try {
                        final CaptureRequest.Builder captureBuilder = cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_STILL_CAPTURE);
                        captureBuilder.addTarget(imageReader.getSurface());
                        int displayRotation = activity.getWindowManager().getDefaultDisplay().getRotation();
                        int displayOrientation = ORIENTATIONS.get(displayRotation);
                        if (facingFront) displayOrientation = -displayOrientation;

                        captureBuilder.set(CaptureRequest.JPEG_ORIENTATION, (-displayOrientation + sensorOrientation) % 360);

                        cameraCaptureSession.capture(captureBuilder.build(), new CameraCaptureSession.CaptureCallback() {
                            @Override
                            public void onCaptureCompleted(@NonNull CameraCaptureSession session, @NonNull CaptureRequest request, @NonNull TotalCaptureResult result) {
                                super.onCaptureCompleted(session, request, result);
                            }
                        }, null);
                    } catch (CameraAccessException e) {
                        result.error("cameraAccess", e.toString(), null);
                    }
                }
            };
            if (activity.checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED &&
                    activity.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {
                storagePermissionContinuation.run();
            } else {
                activity.requestPermissions(
                        new String[]{
                                Manifest.permission.READ_EXTERNAL_STORAGE,
                                Manifest.permission.WRITE_EXTERNAL_STORAGE
                        },
                        storageRequestId);
            }
        }

        void stop() throws CameraAccessException {
            started = false;
            cameraCaptureSession.abortCaptures();
        }

        long getTextureId() {
            return textureEntry.id();
        }

        void dispose() {
            if (cameraCaptureSession != null) {
                cameraCaptureSession.close();
            }
            if (cameraDevice != null) {
                cameraDevice.close();
            }
            cameraDevice = null;
            textureEntry.release();
        }
    }

    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "camera");
        cameraManager = (CameraManager) registrar.activity().getSystemService(Context.CAMERA_SERVICE);

        channel.setMethodCallHandler(new CameraPlugin(registrar, registrar.view(), registrar.activity()));
    }

    private CameraPlugin(Registrar registrar, FlutterView view, Activity activity) {
        this.registrar = registrar;

        registrar.addRequestPermissionResultListener(new CameraRequestPermissionListener());
        this.view = view;
        this.activity = activity;

        activity.getApplication().registerActivityLifecycleCallbacks(new Application.ActivityLifecycleCallbacks() {
            @Override
            public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
            }

            @Override
            public void onActivityStarted(Activity activity) {
            }

            @Override
            public void onActivityResumed(Activity activity) {
                if (activity == CameraPlugin.this.activity) {
                    for (Cam cam : cams.values()) {
                        cam.resume();
                    }
                }
            }

            @Override
            public void onActivityPaused(Activity activity) {
                if (activity == CameraPlugin.this.activity) {
                    for (Cam cam : cams.values()) {
                        cam.pause();
                    }
                }
            }

            @Override
            public void onActivityStopped(Activity activity) {
            }

            @Override
            public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
            }

            @Override
            public void onActivityDestroyed(Activity activity) {
            }
        });
    }

    private static final String TAG = "camera plugin";
    @SuppressLint("UseSparseArrays")
    private static Map<Long, Cam> cams = new HashMap<>();
    private final FlutterView view;


    private Size getBestPreviewSize(StreamConfigurationMap streamConfigurationMap) {
       return new Size(640, 480); // TODO(sigurdm): Do something more clever.
    }

    private Size getBestCaptureSize(StreamConfigurationMap streamConfigurationMap) {
        return new Size(640, 480); // TODO(sigurdm): Do something more clever.
    }

    private Map<String, Integer> encodeSize(Size size) {
        Map<String, Integer> result = new HashMap<>();
        result.put("width", size.getWidth());
        result.put("height", size.getHeight());
        return result;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "init":
                for (Cam cam : cams.values()) {
                    cam.dispose();
                }
                cams.clear();
            case "list":
                try {
                    String[] cameraNames = cameraManager.getCameraIdList();
                    List<Map<String, Object>> cameras = new ArrayList<>();
                    for (String cameraName : cameraNames) {
                        HashMap<String, Object> details = new HashMap<>();
                        CameraCharacteristics characteristics = cameraManager.getCameraCharacteristics(cameraName);
                        details.put("name", cameraName);
                        @SuppressWarnings("ConstantConditions")
                        int lens_facing = characteristics.get(CameraCharacteristics.LENS_FACING);
                        switch (lens_facing) {
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
                        StreamConfigurationMap streamConfigurationMap = characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
                        details.put("captureFormat", encodeSize(getBestCaptureSize(streamConfigurationMap)));
                        details.put("previewFormat", encodeSize(getBestPreviewSize(streamConfigurationMap)));
                        cameras.add(details);
                    }
                    result.success(cameras);
                } catch (CameraAccessException e) {
                    result.error("cameraAccess", e.toString(), null);
                }
                break;
            case "create": {
                FlutterView.SurfaceTextureEntry surfaceTexture = view.createSurfaceTexture();
                final EventChannel eventChannel =
                        new EventChannel(registrar.messenger(), "cameraPlugin/cameraEvents" + surfaceTexture.id());
                String cameraName = call.argument("cameraName");
                Size previewSize = new Size((Integer) call.argument("previewWidth"), (Integer) call.argument("previewHeight"));
                Size captureSize = new Size((Integer) call.argument("captureWidth"), (Integer) call.argument("captureHeight"));
                Cam cam = new Cam(eventChannel, surfaceTexture, cameraName, result, previewSize, captureSize);
                cams.put(cam.getTextureId(), cam);
                break;
            }
            case "start": {
                long textureId = ((Number) call.argument("textureId")).longValue();
                Cam cam = cams.get(textureId);
                try {
                    cam.start();
                    result.success(true);
                } catch (CameraAccessException e) {
                    result.error("cameraAccess", e.toString(), null);
                }
                break;
            }
            case "capture": {
                long textureId = ((Number) call.argument("textureId")).longValue();
                Cam cam = cams.get(textureId);
                try {
                    cam.capture((String) call.argument("filename"), result);
                } catch (CameraAccessException e) {
                    result.error("cameraAccess", e.toString(), null);
                }
                break;
            }
            case "stop": {
                long textureId = ((Number) call.argument("textureId")).longValue();
                Cam cam = cams.get(textureId);
                try {
                    cam.stop();
                } catch (CameraAccessException e) {
                    result.error("cameraAccess", e.toString(), null);
                }
                result.success(true);
                break;
            }
            case "dispose": {
                long textureId = ((Number) call.argument("textureId")).longValue();
                Cam cam = cams.remove(textureId);
                if (cam != null) {
                    cam.dispose();
                }
                result.success(true);
                break;
            }
            default:
                result.notImplemented();
                break;
        }
    }
}
