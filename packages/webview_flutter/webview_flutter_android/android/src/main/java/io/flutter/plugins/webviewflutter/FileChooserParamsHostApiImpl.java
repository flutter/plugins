// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.webkit.WebChromeClient;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.annotation.VisibleForTesting;
import io.flutter.plugin.common.PluginRegistry;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/**
 * Host api implementation for {@link android.webkit.WebChromeClient.FileChooserParams}.
 *
 * <p>Handles creating {@link android.webkit.WebChromeClient.FileChooserParams}s that
 * intercommunicate with a paired Dart object.
 */
@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public class FileChooserParamsHostApiImpl
    implements GeneratedAndroidWebView.FileChooserParamsHostApi {
  private static final int SHOW_FILE_CHOOSER_REQUEST = 0;

  private final InstanceManager instanceManager;
  private final FileChooserParamsProxy fileChooserParamsProxy;

  @Nullable private Activity activity;
  @Nullable private GeneratedAndroidWebView.Result<List<String>> pendingFileChooserResult;

  private final PluginRegistry.ActivityResultListener activityResultListener =
      new PluginRegistry.ActivityResultListener() {
        @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
        @Override
        public boolean onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
          if (requestCode == SHOW_FILE_CHOOSER_REQUEST) {
            final Uri[] result = fileChooserParamsProxy.parseResult(resultCode, data);

            if (result != null) {
              final List<String> filePaths = new ArrayList<>();
              for (Uri uri : result) {
                filePaths.add(uri.toString());
              }
              pendingFileChooserResult.success(filePaths);
            } else {
              pendingFileChooserResult.error(new Exception("Request cancelled or failed."));
            }

            pendingFileChooserResult = null;
            return true;
          }

          return false;
        }
      };

  /**
   * Proxy for {@link android.webkit.WebChromeClient.FileChooserParams} static methods.
   */
  @VisibleForTesting
  public static class FileChooserParamsProxy {
    public Uri[] parseResult(int resultCode, Intent data) {
      return WebChromeClient.FileChooserParams.parseResult(resultCode, data);
    }
  }

  /**
   * Creates a host API that handles method calls from Dart for {@link
   * android.webkit.WebChromeClient.FileChooserParams}s.
   *
   * @param instanceManager maintains instances stored to communicate with Dart objects
   */
  public FileChooserParamsHostApiImpl(InstanceManager instanceManager) {
    this(instanceManager, new FileChooserParamsProxy());
  }

  /**
   * Creates a test host API that handles method calls from Dart for {@link
   * android.webkit.WebChromeClient.FileChooserParams}s.
   *
   * @param instanceManager maintains instances stored to communicate with Dart objects
   * @param fileChooserParamsProxy handles static methods for {@link
   *     android.webkit.WebChromeClient.FileChooserParams}.
   */
  @VisibleForTesting
  public FileChooserParamsHostApiImpl(
      InstanceManager instanceManager, FileChooserParamsProxy fileChooserParamsProxy) {
    this.instanceManager = instanceManager;
    this.fileChooserParamsProxy = fileChooserParamsProxy;
  }

  @Override
  public void openFilePickerForResult(
      @NonNull Long instanceId, GeneratedAndroidWebView.Result<List<String>> result) {
    if (activity == null) {
      result.error(new IllegalStateException("Activity has not been set."));
      return;
    } else if (pendingFileChooserResult != null) {
      result.error(new IllegalStateException("A file picker result is already pending."));
      return;
    }

    final WebChromeClient.FileChooserParams instance =
        Objects.requireNonNull(instanceManager.getInstance(instanceId));

    pendingFileChooserResult = result;
    activity.startActivityForResult(instance.createIntent(), SHOW_FILE_CHOOSER_REQUEST);
  }

  /**
   * The listener that handles returned values from activities opened for results.
   *
   * @return the result listener of this Flutter API
   */
  public PluginRegistry.ActivityResultListener getActivityResultListener() {
    return activityResultListener;
  }

  /**
   * Sets the activity to handle intents.
   *
   * @param activity the desired activity to handle intents
   */
  public void setActivity(@Nullable Activity activity) {
    this.activity = activity;
  }
}
