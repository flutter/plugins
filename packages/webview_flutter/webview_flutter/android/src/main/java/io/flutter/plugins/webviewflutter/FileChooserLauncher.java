// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static io.flutter.plugins.webviewflutter.Constants.ACTION_FILE_CHOOSER_FINISHED;
import static io.flutter.plugins.webviewflutter.Constants.ACTION_REQUEST_CAMERA_PERMISSION_FINISHED;
import static io.flutter.plugins.webviewflutter.Constants.EXTRA_ACCEPT_TYPES;
import static io.flutter.plugins.webviewflutter.Constants.EXTRA_ALLOW_MULTIPLE_FILES;
import static io.flutter.plugins.webviewflutter.Constants.EXTRA_FILE_URIS;
import static io.flutter.plugins.webviewflutter.Constants.EXTRA_SHOW_IMAGE_OPTION;
import static io.flutter.plugins.webviewflutter.Constants.EXTRA_SHOW_VIDEO_OPTION;
import static io.flutter.plugins.webviewflutter.Constants.EXTRA_TITLE;

import android.Manifest;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.webkit.ValueCallback;
import androidx.core.content.ContextCompat;

public class FileChooserLauncher extends BroadcastReceiver {

  private Context context;
  private String title;
  private boolean allowMultipleFiles;
  private boolean videoAcceptable;
  private boolean imageAcceptable;
  private ValueCallback<Uri[]> filePathCallback;
  private String[] acceptTypes;

  public FileChooserLauncher(
      Context context,
      boolean allowMultipleFiles,
      ValueCallback<Uri[]> filePathCallback,
      String[] acceptTypes) {
    this.context = context;
    this.allowMultipleFiles = allowMultipleFiles;
    this.filePathCallback = filePathCallback;
    this.acceptTypes = acceptTypes;

    if (acceptTypes.length == 0 || (acceptTypes.length == 1 && acceptTypes[0].length() == 0)) {
      // acceptTypes empty -> accept anything
      imageAcceptable = true;
      videoAcceptable = true;
    } else {
      for (String acceptType : acceptTypes) {
        if (acceptType.startsWith("image/")) {
          imageAcceptable = true;
        } else if (acceptType.startsWith("video/")) {
          videoAcceptable = true;
        }
      }
    }

    if (imageAcceptable && !videoAcceptable) {
      title = context.getResources().getString(R.string.webview_image_chooser_title);
    } else if (videoAcceptable && !imageAcceptable) {
      title = context.getResources().getString(R.string.webview_video_chooser_title);
    } else {
      title = context.getResources().getString(R.string.webview_file_chooser_title);
    }
  }

  private boolean canCameraProduceAcceptableType() {
    return imageAcceptable || videoAcceptable;
  }

  private boolean hasCameraPermission() {
    return ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA)
        == PackageManager.PERMISSION_GRANTED;
  }

  public void start() {
    if (!canCameraProduceAcceptableType() || hasCameraPermission()) {
      showFileChooser();
    } else {
      IntentFilter intentFilter = new IntentFilter();
      intentFilter.addAction(ACTION_REQUEST_CAMERA_PERMISSION_FINISHED);
      context.registerReceiver(this, intentFilter);

      Intent intent = new Intent(context, RequestCameraPermissionActivity.class);
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      context.startActivity(intent);
    }
  }

  private void showFileChooser() {
    IntentFilter intentFilter = new IntentFilter(ACTION_FILE_CHOOSER_FINISHED);
    context.registerReceiver(this, intentFilter);

    Intent intent = new Intent(context, FileChooserActivity.class);
    intent.putExtra(EXTRA_TITLE, title);
    intent.putExtra(EXTRA_ACCEPT_TYPES, acceptTypes);
    intent.putExtra(EXTRA_SHOW_IMAGE_OPTION, imageAcceptable && hasCameraPermission());
    intent.putExtra(EXTRA_SHOW_VIDEO_OPTION, videoAcceptable && hasCameraPermission());
    intent.putExtra(EXTRA_ALLOW_MULTIPLE_FILES, allowMultipleFiles);
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    context.startActivity(intent);
  }

  @Override
  public void onReceive(Context context, Intent intent) {
    if (intent.getAction().equals(ACTION_REQUEST_CAMERA_PERMISSION_FINISHED)) {
      context.unregisterReceiver(this);
      showFileChooser();
    } else if (intent.getAction().equals(ACTION_FILE_CHOOSER_FINISHED)) {
      String[] uriStrings = intent.getStringArrayExtra(EXTRA_FILE_URIS);
      Uri[] result = null;

      if (uriStrings != null) {
        int uriStringCount = uriStrings.length;
        result = new Uri[uriStringCount];

        for (int i = 0; i < uriStringCount; i++) {
          result[i] = Uri.parse(uriStrings[i]);
        }
      }

      filePathCallback.onReceiveValue(result);
      context.unregisterReceiver(this);
      filePathCallback = null;
    }
  }
}
