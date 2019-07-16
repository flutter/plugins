package io.flutter.plugins.imagepicker;

import android.content.Intent;
import android.net.Uri;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;
import java.io.File;

interface PickerDelegate extends ActivityResultListener,
                                   RequestPermissionsResultListener {
  void chooseVideoFromGallery(@NonNull MethodCall methodCall, @NonNull Result result);

  void takeVideoWithCamera(@NonNull MethodCall methodCall, @NonNull Result result);

  void chooseImageFromGallery(@NonNull MethodCall methodCall, @NonNull Result result);

  void takeImageWithCamera(@NonNull MethodCall methodCall, @NonNull Result result);
}

interface PermissionManager {
  boolean isPermissionGranted(@NonNull String permissionName);

  void askForPermission(@NonNull String permissionName, int requestCode);

  boolean needRequestCameraPermission();
}

interface IntentResolver {
  boolean resolveActivity(@NonNull Intent intent);
}

interface FileUriResolver {
  Uri resolveFileProviderUriForFile(@NonNull String fileProviderName, @NonNull File imageFile);

  void getFullImagePath(@Nullable Uri imageUri, @NonNull OnPathReadyListener listener);
}

interface OnPathReadyListener {
  void onPathReady(@NonNull String path);
}
