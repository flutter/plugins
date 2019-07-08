// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.share;

import android.content.Intent;
import android.net.Uri;
import android.os.Environment;
import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.io.*;
import java.util.Map;

/** Plugin method host for presenting a share sheet via Intent */
public class SharePlugin implements MethodChannel.MethodCallHandler {

  private static final String CHANNEL = "plugins.flutter.io/share";

  public static void registerWith(Registrar registrar) {
    MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);
    SharePlugin instance = new SharePlugin(registrar);
    channel.setMethodCallHandler(instance);
  }

  private final Registrar mRegistrar;

  private SharePlugin(Registrar registrar) {
    this.mRegistrar = registrar;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "share":
        expectMapArguments(call);
        // Android does not support showing the share sheet at a particular point on screen.
        share((String) call.argument("text"));
        result.success(null);
        break;
      case "shareFile":
        expectMapArguments(call);
        // Android does not support showing the share sheet at a particular point on screen.
        try {
          shareFile(
              (String) call.argument("path"),
              (String) call.argument("mimeType"),
              (String) call.argument("subject"),
              (String) call.argument("text"));
          result.success(null);
        } catch (IOException e) {
          result.error(e.getMessage(), null, null);
        }
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void expectMapArguments(MethodCall call) throws IllegalArgumentException {
    if (!(call.arguments instanceof Map)) {
      throw new IllegalArgumentException("Map argument expected");
    }
  }

  private void share(String text) {
    if (text == null || text.isEmpty()) {
      throw new IllegalArgumentException("Non-empty text expected");
    }

    Intent shareIntent = new Intent();
    shareIntent.setAction(Intent.ACTION_SEND);
    shareIntent.putExtra(Intent.EXTRA_TEXT, text);
    shareIntent.setType("text/plain");
    Intent chooserIntent = Intent.createChooser(shareIntent, null /* dialog title optional */);
    if (mRegistrar.activity() != null) {
      mRegistrar.activity().startActivity(chooserIntent);
    } else {
      chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      mRegistrar.context().startActivity(chooserIntent);
    }
  }

  private void shareFile(String path, String mimeType, String subject, String text)
      throws IOException {
    if (path == null || path.isEmpty()) {
      throw new IllegalArgumentException("Non-empty path expected");
    }

    File file = new File(path);
    clearExternalShareFolder();
    if (!fileIsOnExternal(file)) {
      file = copyToExternalShareFolder(file);
    }

    Uri fileUri =
        FileProvider.getUriForFile(
            mRegistrar.context(),
            mRegistrar.context().getPackageName() + ".flutter.share_provider",
            file);

    Intent shareIntent = new Intent();
    shareIntent.setAction(Intent.ACTION_SEND);
    shareIntent.putExtra(Intent.EXTRA_STREAM, fileUri);
    if (subject != null) shareIntent.putExtra(Intent.EXTRA_SUBJECT, subject);
    if (text != null) shareIntent.putExtra(Intent.EXTRA_TEXT, text);
    shareIntent.setType(mimeType != null ? mimeType : "*/*");
    shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
    Intent chooserIntent = Intent.createChooser(shareIntent, null /* dialog title optional */);
    if (mRegistrar.activity() != null) {
      mRegistrar.activity().startActivity(chooserIntent);
    } else {
      chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      mRegistrar.context().startActivity(chooserIntent);
    }
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
    return new File(mRegistrar.context().getExternalCacheDir(), "share");
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
