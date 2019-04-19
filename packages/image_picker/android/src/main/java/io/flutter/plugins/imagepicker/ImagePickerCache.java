// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.net.Uri;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.MethodCall;
import java.util.HashMap;
import java.util.Map;

class ImagePickerCache {

  static final String MAP_KEY_PATH = "path";
  static final String MAP_KEY_MAX_WIDTH = "maxWidth";
  static final String MAP_KEY_MAX_HEIGHT = "maxHeight";
  private static final String MAP_KEY_TYPE = "type";
  private static final String MAP_KEY_ERROR_CODE = "errorCode";
  private static final String MAP_KEY_ERROR_MESSAGE = "errorMessage";

  private static final String FLUTTER_IMAGE_PICKER_IMAGE_PATH_KEY =
      "flutter_image_picker_image_path";
  private static final String SHARED_PREFERENCE_ERROR_CODE_KEY = "flutter_image_picker_error_code";
  private static final String SHARED_PREFERENCE_ERROR_MESSAGE_KEY =
      "flutter_image_picker_error_message";
  private static final String SHARED_PREFERENCE_MAX_WIDTH_KEY = "flutter_image_picker_max_width";
  private static final String SHARED_PREFERENCE_MAX_HEIGHT_KEY = "flutter_image_picker_max_height";
  private static final String SHARED_PREFERENCE_TYPE_KEY = "flutter_image_picker_type";
  private static final String SHARED_PREFERENCE_PENDING_IMAGE_URI_PATH_KEY =
      "flutter_image_picker_pending_image_uri";
  private static final String SHARED_PREFERENCES_NAME = "flutter_image_picker_shared_preference";

  private static SharedPreferences getFilePref;

  static void setUpWithActivity(Activity activity) {
    getFilePref =
        activity
            .getApplicationContext()
            .getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
  }

  static void saveTypeWithMethodCallName(String methodCallName) {
    if (methodCallName.equals(ImagePickerPlugin.METHOD_CALL_IMAGE)) {
      setType("image");
    } else if (methodCallName.equals(ImagePickerPlugin.METHOD_CALL_VIDEO)) {
      setType("video");
    }
  }

  private static void setType(String type) {
    if (getFilePref == null) {
      return;
    }
    getFilePref.edit().putString(SHARED_PREFERENCE_TYPE_KEY, type).apply();
  }

  static void saveDemensionWithMethodCall(MethodCall methodCall) {
    Double maxWidth = methodCall.argument("maxWidth");
    Double maxHeight = methodCall.argument("maxHeight");
    setMaxDimension(maxWidth, maxHeight);
  }

  private static void setMaxDimension(Double maxWidth, Double maxHeight) {
    if (getFilePref == null) {
      return;
    }

    SharedPreferences.Editor editor = getFilePref.edit();
    if (maxWidth != null) {
      editor.putLong(SHARED_PREFERENCE_MAX_WIDTH_KEY, Double.doubleToRawLongBits(maxWidth));
    }
    if (maxHeight != null) {
      editor.putLong(SHARED_PREFERENCE_MAX_HEIGHT_KEY, Double.doubleToRawLongBits(maxHeight));
    }
    editor.apply();
  }

  static void savePendingCameraMediaUriPath(Uri uri) {
    if (getFilePref == null) {
      return;
    }
    getFilePref
        .edit()
        .putString(SHARED_PREFERENCE_PENDING_IMAGE_URI_PATH_KEY, uri.getPath())
        .apply();
  }

  static String retrievePendingCameraMediaUriPath() {
    if (getFilePref == null) {
      return null;
    }
    return getFilePref.getString(SHARED_PREFERENCE_PENDING_IMAGE_URI_PATH_KEY, "");
  }

  static void saveResult(
      @Nullable String path, @Nullable String errorCode, @Nullable String errorMessage) {
    if (getFilePref == null) {
      return;
    }
    SharedPreferences.Editor editor = getFilePref.edit();
    if (path != null) {
      editor.putString(FLUTTER_IMAGE_PICKER_IMAGE_PATH_KEY, path);
    }
    if (errorCode != null) {
      editor.putString(SHARED_PREFERENCE_ERROR_CODE_KEY, errorCode);
    }
    if (errorMessage != null) {
      editor.putString(SHARED_PREFERENCE_ERROR_MESSAGE_KEY, errorMessage);
    }
    editor.apply();
  }

  static void clear() {
    if (getFilePref == null) {
      return;
    }
    getFilePref.edit().clear().apply();
  }

  static Map<String, Object> getCacheMap() {
    if (getFilePref == null) {
      return new HashMap<>();
    }
    Map<String, Object> resultMap = new HashMap<>();
    Boolean hasData = false;

    if (getFilePref.contains(FLUTTER_IMAGE_PICKER_IMAGE_PATH_KEY)) {
      resultMap.put(MAP_KEY_PATH, getFilePref.getString(FLUTTER_IMAGE_PICKER_IMAGE_PATH_KEY, ""));
      hasData = true;
    }

    if (getFilePref.contains(SHARED_PREFERENCE_ERROR_CODE_KEY)) {
      resultMap.put(
          MAP_KEY_ERROR_CODE, getFilePref.getString(SHARED_PREFERENCE_ERROR_CODE_KEY, ""));
      hasData = true;
      if (getFilePref.contains(SHARED_PREFERENCE_ERROR_MESSAGE_KEY)) {
        resultMap.put(
            MAP_KEY_ERROR_MESSAGE, getFilePref.getString(SHARED_PREFERENCE_ERROR_MESSAGE_KEY, ""));
      }
    }

    if (hasData) {
      if (getFilePref.contains(SHARED_PREFERENCE_TYPE_KEY)) {
        resultMap.put(MAP_KEY_TYPE, getFilePref.getString(SHARED_PREFERENCE_TYPE_KEY, ""));
      }

      if (getFilePref.contains(SHARED_PREFERENCE_MAX_WIDTH_KEY)) {
        resultMap.put(
            MAP_KEY_MAX_WIDTH,
            Double.longBitsToDouble(getFilePref.getLong(SHARED_PREFERENCE_MAX_WIDTH_KEY, 0)));
      }

      if (getFilePref.contains(SHARED_PREFERENCE_MAX_HEIGHT_KEY)) {
        resultMap.put(
            MAP_KEY_MAX_HEIGHT,
            Double.longBitsToDouble(getFilePref.getLong(SHARED_PREFERENCE_MAX_HEIGHT_KEY, 0)));
      }
    }

    return resultMap;
  }
}
