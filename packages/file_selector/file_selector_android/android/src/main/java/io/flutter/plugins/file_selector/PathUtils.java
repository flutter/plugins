// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.file_selector;

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.provider.OpenableColumns;
import androidx.annotation.NonNull;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.ArrayList;

public class PathUtils {

  static String cacheFolder = "file_selector";

  /**
   * Given a projection, returns the file name for the uri using the content resolver to avoid
   * unwanted parsing.
   */
  public static String getFileName(Uri uri, @NonNull Context context, String[] projection) {
    Cursor returnCursor = context.getContentResolver().query(uri, projection, null, null, null);

    int nameIndex = returnCursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
    returnCursor.moveToFirst();
    String name = returnCursor.getString(nameIndex);
    returnCursor.close();
    return name;
  }

  @NonNull
  public static ArrayList<String> copyFilesToInternalStorage(
      ArrayList<Uri> uris, Context context, String cacheFolderName) {
    ArrayList<String> absolutePaths = new ArrayList<>();

    String newDirPath = context.getFilesDir() + "/" + cacheFolderName;
    createDirectoryIfNotExists(newDirPath);

    for (Uri uri : uris) {
      String name =
          getFileName(
              uri, context, new String[] {OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE});
      File output = getFile(context, newDirPath, uri, name);
      absolutePaths.add(output.getAbsolutePath());
    }

    return absolutePaths;
  }

  private static File getFile(Context context, String newDirPath, Uri uri, String name) {
    File output;
    output = new File(newDirPath + "/" + name);
    try {
      InputStream inputStream = context.getContentResolver().openInputStream(uri);
      FileOutputStream outputStream = new FileOutputStream(output);
      int read;
      int bufferSize = 1024;
      final byte[] buffers = new byte[bufferSize];
      while ((read = inputStream.read(buffers)) != -1) {
        outputStream.write(buffers, 0, read);
      }

      inputStream.close();
      outputStream.close();

    } catch (Exception e) {
      System.out.println("There was an error adding a file to the application cache");
    }
    return output;
  }

  private static void createDirectoryIfNotExists(String newDirPath) {
    File dir = new File(newDirPath);
    if (!dir.exists()) {
      dir.mkdir();
    }
  }

  public static void clearCache(Context context, String cacheFolderName) {
    File cacheDir = new File(context.getFilesDir() + "/" + cacheFolderName + "/");
    File[] files = cacheDir.listFiles();

    if (files != null) {
      for (File file : files) {
        file.delete();
      }
    }
  }
}
