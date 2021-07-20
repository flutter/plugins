// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static io.flutter.plugins.webviewflutter.Constants.ACTION_REQUEST_CAMERA_PERMISSION_FINISHED;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;

public class RequestCameraPermissionActivity extends Activity {

  private static final int CAMERA_PERMISSION_REQUEST_CODE = 12321;

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    ActivityCompat.requestPermissions(
        this, new String[] {Manifest.permission.CAMERA}, CAMERA_PERMISSION_REQUEST_CODE);
  }

  @Override
  public void onRequestPermissionsResult(
      int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    if (requestCode == CAMERA_PERMISSION_REQUEST_CODE) {
      sendBroadcast(new Intent(ACTION_REQUEST_CAMERA_PERMISSION_FINISHED));
      finish();
    } else {
      super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }
  }
}
