package dev.flutter.plugins.camera;

import android.content.Context;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraManager;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.view.TextureRegistry;

/* package */ class AndroidCameraFactory implements CameraFactory {
  @NonNull
  private final FlutterPlugin.FlutterPluginBinding pluginBinding;
  @NonNull
  private final ActivityPluginBinding activityBinding;

  /* package */ AndroidCameraFactory(
      @NonNull FlutterPlugin.FlutterPluginBinding pluginBinding,
      @NonNull ActivityPluginBinding activityBinding
  ) {
    this.pluginBinding = pluginBinding;
    this.activityBinding = activityBinding;
  }

  @NonNull
  @Override
  public Camera createCamera(
      @NonNull String cameraName,
      @NonNull String resolutionPreset,
      boolean enableAudio
  ) throws CameraAccessException {
    TextureRegistry.SurfaceTextureEntry textureEntry = pluginBinding
        .getFlutterEngine()
        .getRenderer()
        .createSurfaceTexture();

    return new Camera(
        activityBinding.getActivity(),
        (CameraManager) activityBinding.getActivity().getSystemService(Context.CAMERA_SERVICE),
        textureEntry,
        cameraName,
        resolutionPreset,
        enableAudio
    );
  }
}
