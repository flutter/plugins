package io.flutter.plugins.camera;

import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CaptureFailure;
import android.hardware.camera2.CaptureRequest;
import android.media.Image;
import android.media.ImageReader;
import android.util.Log;
import android.util.Range;
import androidx.annotation.NonNull;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.camera.features.CameraFeatures;
import io.flutter.plugins.camera.features.exposurelock.ExposureMode;
import io.flutter.plugins.camera.types.CameraCaptureProperties;

public class BracketingCamara {

  private final CameraFeatures cameraFeatures;
  private final CameraCaptureSession captureSession;
  private final CameraProperties cameraProperties;
  private final CameraCaptureProperties captureProps;
  private final ImageReader pictureImageReader;
  private final CameraDeviceWrapper cameraDevice;

  public BracketingCamara(CameraFeatures cameraFeatures,
                          CameraCaptureSession captureSession,
                          CameraProperties cameraProperties,
                          CameraCaptureProperties captureProps,
                          ImageReader pictureImageReader,
                          CameraDeviceWrapper cameraDevice) {
    this.cameraFeatures = cameraFeatures;
    this.captureSession = captureSession;
    this.cameraProperties = cameraProperties;
    this.captureProps = captureProps;
    this.pictureImageReader = pictureImageReader;
    this.cameraDevice = cameraDevice;
  }

  enum BracketingMode {
    autoExposureCompensation, fixedIsoTimeCompensation
  }

  public void takeBracketingPictures(String basePath, BracketingMode bracketingMode, @NonNull final MethodChannel.Result result) {
    try {
      List<CaptureRequest> captureList = null;
      boolean aeLock = cameraFeatures.getExposureLock().getValue() == ExposureMode.locked;

      if (bracketingMode == BracketingMode.autoExposureCompensation && !aeLock) {
        Log.d("CAMERA", "BracketingMode.autoExposureCompensation");
        captureList = createAeCompensationReaderSession(basePath, result);
      } else if (bracketingMode == BracketingMode.fixedIsoTimeCompensation || aeLock) {
        Log.d("CAMERA", "BracketingMode.fixedIsoTimeCompensation");
        captureList = createFixedIsoBracketingReaderSession(basePath, result);
      }

      if (captureList != null) {
        captureSession.captureBurst(
            captureList,
            new CameraCaptureSession.CaptureCallback() {
              @Override
              public void onCaptureFailed(
                  @NonNull CameraCaptureSession session,
                  @NonNull CaptureRequest request,
                  @NonNull CaptureFailure failure) {

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
                result.error("captureFailure", reason, null);
              }
            },
            null);
      }
    } catch (CameraAccessException e) {
      result.error("cameraAccess", e.getMessage(), null);
    }
  }

  private List<CaptureRequest> createFixedIsoBracketingReaderSession(String basePath, @NonNull MethodChannel.Result result) throws CameraAccessException {
    Range<Long> exposureTimeRange = cameraProperties.getSensorInfoExposureTimeRange();
    List<CaptureRequest> captureList = new ArrayList<CaptureRequest>();
    int numberOfBursts = 3;
    long time = captureProps.getLastSensorExposureTime();
    int iso = captureProps.getLastSensorSensitivity();
    for (int n = -1; n < numberOfBursts - 1; n++) {
      long exposureTime = exposureTimeRange.clamp((long) (time * Math.pow(2, n * 1.3)));
      Log.d("CAMERA", exposureTimeRange + " possible, selected " + exposureTime + " and iso: " + iso + ", current time + " + time);
      CaptureRequest.Builder captureBuilder = createManualCompensationBuilder(iso, exposureTime);
      captureList.add(captureBuilder.build());
    }

    final AtomicInteger index = new AtomicInteger(0);
    final AtomicLong firstShot = new AtomicLong(0);
    final List<String> paths = new ArrayList<>();

    pictureImageReader.setOnImageAvailableListener(
        reader -> {
          try (Image image = reader.acquireNextImage()) {

            if (firstShot.get() == 0) {
              firstShot.set(System.currentTimeMillis());
            }

            int i = index.getAndIncrement();
            Log.d("CAMERA", System.currentTimeMillis() - firstShot.get() + "msec for " + i + " before writing");
            String path = writeToFile(image, basePath + "_" + (i + 1));
            Log.d("CAMERA", "Wrote to " + path);
            paths.add(path);

            Log.d("CAMERA", System.currentTimeMillis() - firstShot.get() + "msec for " + i + " after writing");
            if (i == captureList.size() - 1) {
              result.success(paths);
            }

          } catch (Exception e) {
            result.error("IOError", "Failed saving image", null);
          }
        },
        null);

    return captureList;
  }

  private String writeToFile(Image image, String basePath) throws IOException {
//    if (image.getFormat() == ImageFormat.RAW_SENSOR) {
//      File file = new File(basePath + ".dng");
//      DngCreator dngCreator = new DngCreator(cameraCharacteristics, lastCaptureResult);
//      try (FileOutputStream stream = new FileOutputStream(file)) {
//        dngCreator.writeImage(stream, image);
//        return file.getPath();
//      } catch (IOException e) {
//        e.printStackTrace();
//      }
//    } else if (image.getFormat() == ImageFormat.JPEG) {
    File file = new File(basePath + ".jpg");
    try (FileOutputStream outputStream = new FileOutputStream(file)) {
      ByteBuffer buffer = image.getPlanes()[0].getBuffer();
      while (0 < buffer.remaining()) {
        outputStream.getChannel().write(buffer);
      }
      return file.getPath();
    } catch (IOException e) {
      e.printStackTrace();
    }
//    }
    return null;
  }


  private List<CaptureRequest> createAeCompensationReaderSession(String basePath, @NonNull MethodChannel.Result result) throws CameraAccessException {
    List<CaptureRequest> captureList = new ArrayList<CaptureRequest>();
    List<Integer> aeCompensations = createAeCompensations();
    // first frame will be discarded
    captureList.add(createAECompensationBuilder(0).build());
    for (int aeCompensation : aeCompensations) {
      CaptureRequest.Builder captureBuilder = createAECompensationBuilder(aeCompensation);
      captureList.add(captureBuilder.build());
    }

    final AtomicInteger index = new AtomicInteger(0);
    final AtomicLong firstShot = new AtomicLong(0);
    final List<String> paths = new ArrayList<>();

    pictureImageReader.setOnImageAvailableListener(
        reader -> {
          try (Image image = reader.acquireNextImage()) {

            if (firstShot.get() == 0) {
              firstShot.set(System.currentTimeMillis());
            }

            int i = index.getAndIncrement();
            Log.d("CAMERA", System.currentTimeMillis() - firstShot.get() + "msec for " + i + " before writing");

            if (i == 0) {
              Log.d("CAMERA", "Discard the first frame to settle the AE compensation");
              return;
            }

            String path = writeToFile(image, basePath + "_" + i);
            Log.d("CAMERA", "Wrote to" + path);
            paths.add(path);

            Log.d("CAMERA", System.currentTimeMillis() - firstShot.get() + "msec for " + i + " after writing");
            if (i == captureList.size() - 1) {
              result.success(paths);
            }

          } catch (Exception e) {
            e.printStackTrace();
            result.error("IOError", "Failed saving image", null);
          }
        },
        null);

    return captureList;
  }

  private List<Integer> createAeCompensations() {
    Range<Integer> range = cameraProperties.getControlAutoExposureCompensationRange();
    final double step = cameraProperties.getControlAutoExposureCompensationStep();


    List<Integer> aeCompensations = new ArrayList<>();
    if (range.getLower() == 0 || range.getUpper() == 0) {
      aeCompensations.add(0);
    } else {
      aeCompensations.add((int) (range.getLower() * step));
      aeCompensations.add(0);
      aeCompensations.add((int) (range.getUpper() * step));
    }
    return aeCompensations;
  }

  private CaptureRequest.Builder createAECompensationBuilder(int aeCompensation) throws CameraAccessException {
    long minFrameDuration = cameraProperties.getOutputMinFrameDuration();
    CaptureRequest.Builder captureBuilder =
        cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_STILL_CAPTURE);
    captureBuilder.set(CaptureRequest.SENSOR_FRAME_DURATION, minFrameDuration);
    captureBuilder.set(CaptureRequest.LENS_OPTICAL_STABILIZATION_MODE, CaptureRequest.LENS_OPTICAL_STABILIZATION_MODE_ON);
    captureBuilder.set(CaptureRequest.JPEG_QUALITY, (byte) 100);
    captureBuilder.set(CaptureRequest.JPEG_ORIENTATION, cameraFeatures.getSensorOrientation().getValue());
    captureBuilder.set(CaptureRequest.CONTROL_AE_EXPOSURE_COMPENSATION, aeCompensation);
    captureBuilder.addTarget(pictureImageReader.getSurface());
    return captureBuilder;
  }

  private CaptureRequest.Builder createManualCompensationBuilder(int iso, long exposureTime) throws CameraAccessException {
    long minFrameDuration = cameraProperties.getOutputMinFrameDuration();
    CaptureRequest.Builder captureBuilder =
        cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_STILL_CAPTURE);
    captureBuilder.set(CaptureRequest.SENSOR_FRAME_DURATION, minFrameDuration);
    captureBuilder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_OFF);
    captureBuilder.set(CaptureRequest.SENSOR_EXPOSURE_TIME, exposureTime);
    captureBuilder.set(CaptureRequest.SENSOR_SENSITIVITY, iso);
    captureBuilder.set(CaptureRequest.LENS_OPTICAL_STABILIZATION_MODE, CaptureRequest.LENS_OPTICAL_STABILIZATION_MODE_ON);
    captureBuilder.set(CaptureRequest.JPEG_QUALITY, (byte) 100);
    captureBuilder.set(CaptureRequest.JPEG_ORIENTATION, cameraFeatures.getSensorOrientation().getValue());
    captureBuilder.addTarget(pictureImageReader.getSurface());
    return captureBuilder;
  }


}
