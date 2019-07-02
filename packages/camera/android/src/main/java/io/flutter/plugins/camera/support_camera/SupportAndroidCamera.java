package io.flutter.plugins.camera.support_camera;

import android.hardware.Camera;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.camera.CameraPlugin;
import io.flutter.plugins.camera.common.NativeTexture;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class SupportAndroidCamera implements MethodChannel.MethodCallHandler {
  private final Camera camera;
  private final Integer handle;

  private SupportAndroidCamera(Camera camera, Integer handle) {
    this.camera = camera;
    this.handle = handle;
  }

  public static int getNumberOfCameras() {
    return Camera.getNumberOfCameras();
  }

  public static SupportAndroidCamera open(MethodCall call) {
    final Integer cameraId = call.argument("cameraId");
    final Integer cameraHandle = call.argument("cameraHandle");
    return new SupportAndroidCamera(Camera.open(cameraId), cameraHandle);
  }

  public static Map<String, Object> getCameraInfo(MethodCall call) {
    final Integer cameraId = call.argument("cameraId");
    final Camera.CameraInfo info = new Camera.CameraInfo();
    Camera.getCameraInfo(cameraId, info);

    final Map<String, Object> data = new HashMap<>();

    switch (info.facing) {
      case Camera.CameraInfo.CAMERA_FACING_FRONT:
        data.put("facing", "Facing.front");
        break;
      case Camera.CameraInfo.CAMERA_FACING_BACK:
        data.put("facing", "Facing.back");
        break;
    }

    data.put("orientation", info.orientation);
    data.put("id", cameraId);

    return data;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "SupportAndroidCamera#previewTexture":
        previewTexture(call, result);
        break;
      case "SupportAndroidCamera#startPreview":
        startPreview(result);
        break;
      case "SupportAndroidCamera#stopPreview":
        stopPreview(result);
        break;
      case "SupportAndroidCamera#release":
        release(result);
        break;
      default:
        result.notImplemented();
    }
  }

  private void previewTexture(MethodCall call, MethodChannel.Result result) {
    final Map<String, Object> textureData = call.argument("nativeTexture");
    final Integer textureHandle = (Integer) textureData.get("handle");

    try {
      if (textureHandle == null) {
        camera.setPreviewTexture(null);
      } else {
        final NativeTexture texture = (NativeTexture) CameraPlugin.getHandler(textureHandle);
        camera.setPreviewTexture(texture.textureEntry.surfaceTexture());
      }
    } catch (IOException e) {
      result.error(e.getClass().getSimpleName(), e.getLocalizedMessage(), null);
      return;
    }

    result.success(null);
  }

  private void startPreview(MethodChannel.Result result) {
    camera.startPreview();
    result.success(null);
  }

  private void stopPreview(MethodChannel.Result result) {
    camera.stopPreview();
    result.success(null);
  }

  private void release(MethodChannel.Result result) {
    camera.release();
    CameraPlugin.removeHandler(handle);
    result.success(null);
  }
}
