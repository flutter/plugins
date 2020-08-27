// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.share;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Environment;
import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;

/** Handles share intent. */
class Share {

  private Context context;
  private Activity activity;

  /**
   * Constructs a Share object. The {@code context} and {@code activity} are used to start the share
   * intent. The {@code activity} might be null when constructing the {@link Share} object and set
   * to non-null when an activity is available using {@link #setActivity(Activity)}.
   */
  Share(Context context, Activity activity) {
    this.context = context;
    this.activity = activity;
  }

  /**
   * Sets the activity when an activity is available. When the activity becomes unavailable, use
   * this method to set it to null.
   */
  void setActivity(Activity activity) {
    this.activity = activity;
  }

  void share(String text, String subject) {
    if (text == null || text.isEmpty()) {
      throw new IllegalArgumentException("Non-empty text expected");
    }

    Intent shareIntent = new Intent();
    shareIntent.setAction(Intent.ACTION_SEND);
    shareIntent.putExtra(Intent.EXTRA_TEXT, text);
    shareIntent.putExtra(Intent.EXTRA_SUBJECT, subject);
    shareIntent.setType("text/plain");
    Intent chooserIntent = Intent.createChooser(shareIntent, null /* dialog title optional */);
    startActivity(chooserIntent);
  }

  void shareFiles(List<String> paths, List<String> mimeTypes, String text, String subject)
      throws IOException {
    if (paths == null || paths.isEmpty()) {
      throw new IllegalArgumentException("Non-empty path expected");
    }

    clearExternalShareFolder();
    ArrayList<Uri> fileUris = getUrisForPaths(paths);

    Intent shareIntent = new Intent();
    if (fileUris.isEmpty()) {
      share(text, subject);
      return;
    } else if (fileUris.size() == 1) {
      shareIntent.setAction(Intent.ACTION_SEND);
      shareIntent.putExtra(Intent.EXTRA_STREAM, fileUris.get(0));
      shareIntent.setType(
          !mimeTypes.isEmpty() && mimeTypes.get(0) != null ? mimeTypes.get(0) : "*/*");
    } else {
      shareIntent.setAction(Intent.ACTION_SEND_MULTIPLE);
      shareIntent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, fileUris);
      shareIntent.setType(reduceMimeTypes(mimeTypes));
    }
    if (text != null) shareIntent.putExtra(Intent.EXTRA_TEXT, text);
    if (subject != null) shareIntent.putExtra(Intent.EXTRA_SUBJECT, subject);
    shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
    Intent chooserIntent = Intent.createChooser(shareIntent, null /* dialog title optional */);

    List<ResolveInfo> resInfoList =
        getContext()
            .getPackageManager()
            .queryIntentActivities(chooserIntent, PackageManager.MATCH_DEFAULT_ONLY);
    for (ResolveInfo resolveInfo : resInfoList) {
      String packageName = resolveInfo.activityInfo.packageName;
      for (Uri fileUri : fileUris) {
        getContext()
            .grantUriPermission(
                packageName,
                fileUri,
                Intent.FLAG_GRANT_WRITE_URI_PERMISSION | Intent.FLAG_GRANT_READ_URI_PERMISSION);
      }
    }

    startActivity(chooserIntent);
  }

  private void startActivity(Intent intent) {
    if (activity != null) {
      activity.startActivity(intent);
    } else if (context != null) {
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      context.startActivity(intent);
    } else {
      throw new IllegalStateException("Both context and activity are null");
    }
  }

  private ArrayList<Uri> getUrisForPaths(List<String> paths) throws IOException {
    ArrayList<Uri> uris = new ArrayList<>(paths.size());
    for (String path : paths) {
      File file = new File(path);
      if (!fileIsOnExternal(file)) {
        file = copyToExternalShareFolder(file);
      }

      uris.add(
          FileProvider.getUriForFile(
              getContext(), getContext().getPackageName() + ".flutter.share_provider", file));
    }
    return uris;
  }

  private String reduceMimeTypes(List<String> mimeTypes) {
    if (mimeTypes.size() > 1) {
      String reducedMimeType = mimeTypes.get(0);
      for (int i = 1; i < mimeTypes.size(); i++) {
        String mimeType = mimeTypes.get(i);
        if (!reducedMimeType.equals(mimeType)) {
          if (getMimeTypeBase(mimeType).equals(getMimeTypeBase(reducedMimeType))) {
            reducedMimeType = getMimeTypeBase(mimeType) + "/*";
          } else {
            reducedMimeType = "*/*";
            break;
          }
        }
      }
      return reducedMimeType;
    } else if (mimeTypes.size() == 1) {
      return mimeTypes.get(0);
    } else {
      return "*/*";
    }
  }

  @NonNull
  private String getMimeTypeBase(String mimeType) {
    if (mimeType == null || !mimeType.contains("/")) {
      return "*";
    }

    return mimeType.substring(0, mimeType.indexOf("/"));
  }

  private boolean fileIsOnExternal(File file) {
    try {
      String filePath = file.getCanonicalPath();
      File externalDir = Environment.getExternalStorageDirectory();
      return externalDir != null && filePath.startsWith(externalDir.getCanonicalPath());
    } catch (IOException e) {
      return false;
    }
  }

  @SuppressWarnings("ResultOfMethodCallIgnored")
  private void clearExternalShareFolder() {
    File folder = getExternalShareFolder();
    if (folder.exists()) {
      for (File file : folder.listFiles()) {
        file.delete();
      }
      folder.delete();
    }
  }

  @SuppressWarnings("ResultOfMethodCallIgnored")
  private File copyToExternalShareFolder(File file) throws IOException {
    File folder = getExternalShareFolder();
    if (!folder.exists()) {
      folder.mkdirs();
    }

    File newFile = new File(folder, file.getName());
    copy(file, newFile);
    return newFile;
  }

  @NonNull
  private File getExternalShareFolder() {
    return new File(getContext().getExternalCacheDir(), "share");
  }

  private Context getContext() {
    if (activity != null) {
      return activity;
    }
    if (context != null) {
      return context;
    }

    throw new IllegalStateException("Both context and activity are null");
  }

  private static void copy(File src, File dst) throws IOException {
    InputStream in = new FileInputStream(src);
    try {
      OutputStream out = new FileOutputStream(dst);
      try {
        // Transfer bytes from in to out
        byte[] buf = new byte[1024];
        int len;
        while ((len = in.read(buf)) > 0) {
          out.write(buf, 0, len);
        }
      } finally {
        out.close();
      }
    } finally {
      in.close();
    }
  }
}
