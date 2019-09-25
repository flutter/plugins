package dev.flutter.plugins.camera;

import android.Manifest;
import android.content.pm.PackageManager;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry;

/* package */ class AndroidCameraPermissions implements CameraPermissions {
  private static final int CAMERA_REQUEST_ID = 9796;

  @NonNull
  private final ActivityPluginBinding activityBinding;
  private boolean ongoing = false;

  /* package */ AndroidCameraPermissions(@NonNull ActivityPluginBinding activityBinding) {
    this.activityBinding = activityBinding;
  }

  @Override
  public boolean hasCameraPermission() {
    return ContextCompat.checkSelfPermission(activityBinding.getActivity(), Manifest.permission.CAMERA)
        == PackageManager.PERMISSION_GRANTED;
  }

  @Override
  public boolean hasAudioPermission() {
    return ContextCompat.checkSelfPermission(activityBinding.getActivity(), Manifest.permission.RECORD_AUDIO)
        == PackageManager.PERMISSION_GRANTED;
  }

  public void requestPermissions(boolean enableAudio, CameraPermissions.ResultCallback callback) {
    if (ongoing) {
      callback.onResult("cameraPermission", "Camera permission request ongoing");
    }
    if (!hasCameraPermission() || (enableAudio && !hasAudioPermission())) {
      ongoing = true;

      activityBinding.addRequestPermissionsResultListener(
          new CameraRequestPermissionsListener(callback)
      );

      ActivityCompat.requestPermissions(
          activityBinding.getActivity(),
          enableAudio
              ? new String[] {Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO}
              : new String[] {Manifest.permission.CAMERA},
          CAMERA_REQUEST_ID);
    } else {
      // Permissions already exist. Call the callback with success.
      callback.onResult(null, null);
    }
  }

  @Override
  public void addRequestPermissionsResultListener(@NonNull PluginRegistry.RequestPermissionsResultListener listener) {
    activityBinding.addRequestPermissionsResultListener(listener);
  }

  private static class CameraRequestPermissionsListener implements PluginRegistry.RequestPermissionsResultListener {
    final CameraPermissions.ResultCallback callback;

    private CameraRequestPermissionsListener(CameraPermissions.ResultCallback callback) {
      this.callback = callback;
    }

    @Override
    public boolean onRequestPermissionsResult(int id, String[] permissions, int[] grantResults) {
      if (id == CAMERA_REQUEST_ID) {
        // TODO(mattcarroll): fix bug where granting 1st permission and denying 2nd crashes
        // due to submitting a reply twice.
        if (grantResults[0] != PackageManager.PERMISSION_GRANTED) {
          callback.onResult("cameraPermission", "MediaRecorderCamera permission not granted");
        } else if (grantResults.length > 1
            && grantResults[1] != PackageManager.PERMISSION_GRANTED) {
          callback.onResult("cameraPermission", "MediaRecorderAudio permission not granted");
        } else {
          callback.onSuccess();
        }
        return true;
      }
      return false;
    }
  }
}
