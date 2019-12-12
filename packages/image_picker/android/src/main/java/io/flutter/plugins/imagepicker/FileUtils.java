// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2007-2008 OpenIntents.org
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * This file was modified by the Flutter authors from the following original file:
 * https://raw.githubusercontent.com/iPaulPro/aFileChooser/master/aFileChooser/src/com/ipaulpro/afilechooser/utils/FileUtils.java
 */

package io.flutter.plugins.imagepicker;

import android.annotation.SuppressLint;
import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.text.TextUtils;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

class FileUtils {

  String getPathFromUri(final Context context, final Uri uri) {
    String path = getPathFromLocalUri(context, uri);
    if (path == null) {
      path = getPathFromRemoteUri(context, uri);
    }
    return path;
  }

  @SuppressLint("NewApi")
  private String getPathFromLocalUri(final Context context, final Uri uri) {
    final boolean isKitKat = Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT;

    if (isKitKat && DocumentsContract.isDocumentUri(context, uri)) {
      if (isExternalStorageDocument(uri)) {
        final String docId = DocumentsContract.getDocumentId(uri);
        final String[] split = docId.split(":");
        final String type = split[0];

        if ("primary".equalsIgnoreCase(type)) {
          return Environment.getExternalStorageDirectory() + "/" + split[1];
        }
      } else if (isDownloadsDocument(uri)) {
        final String id = DocumentsContract.getDocumentId(uri);

        if (!TextUtils.isEmpty(id)) {
          try {
            final Uri contentUri =
                ContentUris.withAppendedId(
                    Uri.parse(Environment.DIRECTORY_DOWNLOADS), Long.valueOf(id));
            return getDataColumn(context, contentUri, null, null);
          } catch (NumberFormatException e) {
            return null;
          }
        }

      } else if (isMediaDocument(uri)) {
        final String docId = DocumentsContract.getDocumentId(uri);
        final String[] split = docId.split(":");
        final String type = split[0];

        Uri contentUri = null;
        if ("image".equals(type)) {
          contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
        } else if ("video".equals(type)) {
          contentUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
        } else if ("audio".equals(type)) {
          contentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
        }

        final String selection = "_id=?";
        final String[] selectionArgs = new String[] {split[1]};

        return getDataColumn(context, contentUri, selection, selectionArgs);
      }
    } else if ("content".equalsIgnoreCase(uri.getScheme())) {

      // Return the remote address
      if (isGooglePhotosUri(uri)) {
        return null;
      }

      return getDataColumn(context, uri, null, null);
    } else if ("file".equalsIgnoreCase(uri.getScheme())) {
      return uri.getPath();
    }

    return null;
  }

  private static String getDataColumn(
      Context context, Uri uri, String selection, String[] selectionArgs) {
    Cursor cursor = null;

    final String column = "_data";
    final String[] projection = {column};

    try {
      cursor = context.getContentResolver().query(uri, projection, selection, selectionArgs, null);
      if (cursor != null && cursor.moveToFirst()) {
        final int column_index = cursor.getColumnIndex(column);

        //yandex.disk and dropbox do not have _data column
        if (column_index == -1) {
          return null;
        }

        return cursor.getString(column_index);
      }
    } finally {
      if (cursor != null) {
        cursor.close();
      }
    }
    return null;
  }

  private static String getPathFromRemoteUri(final Context context, final Uri uri) {
    // The code below is why Java now has try-with-resources and the Files utility.
    File file = null;
    InputStream inputStream = null;
    OutputStream outputStream = null;
    boolean success = false;
    try {
      String extension = getImageExtension(uri);
      inputStream = context.getContentResolver().openInputStream(uri);
      file = File.createTempFile("image_picker", extension, context.getCacheDir());
      outputStream = new FileOutputStream(file);
      if (inputStream != null) {
        copy(inputStream, outputStream);
        success = true;
      }
    } catch (IOException ignored) {
    } finally {
      try {
        if (inputStream != null) inputStream.close();
      } catch (IOException ignored) {
      }
      try {
        if (outputStream != null) outputStream.close();
      } catch (IOException ignored) {
        // If closing the output stream fails, we cannot be sure that the
        // target file was written in full. Flushing the stream merely moves
        // the bytes into the OS, not necessarily to the file.
        success = false;
      }
    }
    return success ? file.getPath() : null;
  }

  /** @return extension of image with dot, or default .jpg if it none. */
  private static String getImageExtension(Uri uriImage) {
    String extension = null;

    try {
      String imagePath = uriImage.getPath();
      if (imagePath != null && imagePath.lastIndexOf(".") != -1) {
        extension = imagePath.substring(imagePath.lastIndexOf(".") + 1);
      }
    } catch (Exception e) {
      extension = null;
    }

    if (extension == null || extension.isEmpty()) {
      //default extension for matches the previous behavior of the plugin
      extension = "jpg";
    }

    return "." + extension;
  }

  private static void copy(InputStream in, OutputStream out) throws IOException {
    final byte[] buffer = new byte[4 * 1024];
    int bytesRead;
    while ((bytesRead = in.read(buffer)) != -1) {
      out.write(buffer, 0, bytesRead);
    }
    out.flush();
  }

  private static boolean isExternalStorageDocument(Uri uri) {
    return "com.android.externalstorage.documents".equals(uri.getAuthority());
  }

  private static boolean isDownloadsDocument(Uri uri) {
    return "com.android.providers.downloads.documents".equals(uri.getAuthority());
  }

  private static boolean isMediaDocument(Uri uri) {
    return "com.android.providers.media.documents".equals(uri.getAuthority());
  }

  private static boolean isGooglePhotosUri(Uri uri) {
    return "com.google.android.apps.photos.contentprovider".equals(uri.getAuthority());
  }
}
