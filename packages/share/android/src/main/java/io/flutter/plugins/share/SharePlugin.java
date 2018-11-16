// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.share;

import android.content.Intent;
import android.support.v4.content.FileProvider;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import android.net.Uri;
import java.io.File;
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
    if (call.method.equals("share")) {
      expectMapArguments(call);
      // Android does not support showing the share sheet at a particular point on screen.
      share((String) call.argument("text"));
      result.success(null);
    } else if (call.method.equals("shareFile")) {
      expectMapArguments(call);
      // Android does not support showing the share sheet at a particular point on screen.
      shareFile((String) call.argument("path"), (String) call.argument("mimeType"),
              (String) call.argument("subject"), (String) call.argument("text"));
      result.success(null);
    } else {
      result.notImplemented();
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

  private void shareFile(String path, String mimeType, String subject, String text) {
    if (path == null || path.isEmpty()) {
      throw new IllegalArgumentException("Non-empty path expected");
    }

    // TODO use normal EXTRA_STREAM with Uri.fromFile()
    // TODO if file is not on external storage, then copy it to external storage into a directory
    // TODO or can we share if it is in the external-files-dir ? then we might not need any permissions!! if that is true, copy it to that cache
    // copy:
    // String fileName = Uri.parse(fileUrl).getLastPathSegment();
    // TODO if copied, make that file deleteOnExit()?
    // TODO when coming here, always clear (or even remove?) the directory on the external storage
    Uri fileUri = FileProvider.getUriForFile(
        mRegistrar.context(),
        mRegistrar.context().getPackageName() + ".flutter.share_provider",
        new File(path));

    String tempDirPath = mRegistrar.context().getExternalCacheDir()
            + File.separator + "TempFiles" + File.separator;

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
}
