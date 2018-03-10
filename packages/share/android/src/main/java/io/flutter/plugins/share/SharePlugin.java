// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.share;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.StrictMode;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.io.*;
import java.net.URL;
import java.net.URLConnection;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

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
    if (call.method.equals("share")) {

      if (Build.VERSION.SDK_INT > 9) {
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
      }

      System.out.println("Share Arg:" + call.arguments);

      Map<String, String> arguments = (Map<String, String>) call.arguments;

      final String text = arguments.get("text");
      final String title = arguments.get("title");
      final String media = arguments.get("media");
      final String dialogTitle = arguments.get("dialogTitle");

      share(text, title, media, dialogTitle);
      result.success(null);
    } else {
      result.error("UNKNOWN_METHOD", "Unknown share method called", null);
    }
  }

  private void share(String text, String title, String media, String dialogTitle) {
    Intent shareIntent = new Intent();
    shareIntent.setAction(Intent.ACTION_SEND);
    shareIntent.putExtra(Intent.EXTRA_TEXT, text);

    if (title != null) {
      shareIntent.putExtra(Intent.EXTRA_SUBJECT, title);
    }

    if (media != null) {
      String dir = getDownloadDir();

      Uri fileUri = getFileUri(shareIntent, dir, media);

      if (fileUri != null) {
        shareIntent.putExtra(Intent.EXTRA_STREAM, fileUri);
        shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
      }

    } else {
      shareIntent.setType("text/plain");
    }

    Intent chooserIntent = Intent.createChooser(shareIntent, dialogTitle);
    if (mRegistrar.activity() != null) {
      mRegistrar.activity().startActivity(chooserIntent);
    } else {
      chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      mRegistrar.context().startActivity(chooserIntent);
    }
  }

  private Uri getFileUri(Intent sendIntent, String dir, String image) {
    String localImage = image;

    if (localImage.endsWith("mp4") || localImage.endsWith("mov") || localImage.endsWith("3gp")) {
      sendIntent.setType("video/*");
    } else if (localImage.endsWith("mp3")) {
      sendIntent.setType("audio/x-mpeg");
    } else {
      sendIntent.setType("image/*");
    }

    if (image.startsWith("http")) {
      String filename = getFileName(image);
      localImage = "file://" + dir + "/" + filename;

      try {
        URLConnection connection = new URL(image).openConnection();
        saveFile(getBytes(connection.getInputStream()), dir, filename);
      } catch (Exception e) {
        e.printStackTrace();
      }
    } else {
      throw new IllegalArgumentException("URL_NOT_SUPPORTED");
    }

    return Uri.parse(localImage);
  }

  private String getDownloadDir() {
    if (Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState())) {
      // we need to use external storage since we need to share to another app
      final String dir = this.mRegistrar.context().getExternalFilesDir(null) + "/silkthread";
      createOrCleanDir(dir);
      return dir;
    } else {
      return null;
    }
  }

  private void createOrCleanDir(final String downloadDir) {
    final File dir = new File(downloadDir);
    if (!dir.exists()) {
      dir.mkdirs();
    } else {
      for (File f : dir.listFiles()) {
        f.delete();
      }
    }
  }

  private static String getFileName(String url) {
    if (url.endsWith("/")) {
      url = url.substring(0, url.length() - 1);
    }

    final String pattern = ".*/([^?#]+)?";
    Pattern r = Pattern.compile(pattern);
    Matcher m = r.matcher(url);

    if (m.find()) {
      return m.group(1);
    } else {
      return "file";
    }
  }

  private void saveFile(byte[] bytes, String dirName, String fileName) throws IOException {
    final File dir = new File(dirName);
    final FileOutputStream fos = new FileOutputStream(new File(dir, fileName));
    fos.write(bytes);
    fos.flush();
    fos.close();
  }

  private byte[] getBytes(InputStream is) throws IOException {
    ByteArrayOutputStream buffer = new ByteArrayOutputStream();
    int nRead;
    byte[] data = new byte[16384];
    while ((nRead = is.read(data, 0, data.length)) != -1) {
      buffer.write(data, 0, nRead);
    }
    buffer.flush();
    return buffer.toByteArray();
  }
}
