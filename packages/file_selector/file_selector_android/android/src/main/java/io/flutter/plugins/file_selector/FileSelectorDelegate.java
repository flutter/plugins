// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.file_selector;

import android.app.Activity;
import android.content.ClipData;
import android.content.Intent;
import android.net.Uri;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import io.flutter.plugin.common.PluginRegistry;
import java.util.ArrayList;
import java.util.List;

/**
 * A delegate class doing the heavy lifting for the plugin.
 *
 * <p>When invoked, all the "access file" methods go through the same steps:
 *
 * <p>1. Check for an existing {@link #pendingResult}. If a previous pendingResult exists, this
 * means that the method was called at least twice. In this case, stop executing and finish with an
 * error.
 *
 * <p>3. Launch the file explorer.
 *
 * <p>This can end up in two different outcomes:
 *
 * <p>A) User picks a file or directory.
 *
 * <p>B) User cancels picking a file or directory. Finish with null result.
 */
public class FileSelectorDelegate
    implements PluginRegistry.ActivityResultListener,
        PluginRegistry.RequestPermissionsResultListener {
  static final int REQUEST_CODE_GET_DIRECTORY_PATH = 2342;
  static final int REQUEST_CODE_OPEN_FILE = 2343;

  static String cacheFolder = "file_selector";

  Intent openFileIntent = new Intent();

  private Messages.Result pendingResult;
  private final Activity activity;

  @Override
  public boolean onRequestPermissionsResult(
      int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    return true;
  }

  public FileSelectorDelegate(final Activity activity) {
    this(activity, null);
  }

  /**
   * These constructors are used exclusively for testing; they can be used to provide mocks to final
   * fields of this class. Otherwise, those fields would have to be mutable and visible.
   */
  @VisibleForTesting
  FileSelectorDelegate() {
    this(null, null);
  }

  @VisibleForTesting
  FileSelectorDelegate(final Activity activity, final Messages.Result result) {
    this.activity = activity;
    this.pendingResult = result;
  }

  public void clearCache() {
    PathUtils.clearCache(this.activity, cacheFolder);
  }

  public void getDirectoryPath(@Nullable String initialDirectory, Messages.Result<String> result) {
    if (setPendingResult(result)) {
      finishWithAlreadyActiveError(result);
      return;
    }

    launchGetDirectoryPath(initialDirectory);
  }

  public void openFile(
      @NonNull Messages.SelectionOptions options, Messages.Result<List<String>> result) {
    if (setPendingResult(result)) {
      finishWithAlreadyActiveError(result);
      return;
    }

    Boolean multipleFiles = options.getAllowMultiple();
    List<String> acceptedTypeGroups = options.getAllowedTypes();

    launchOpenFile(multipleFiles, acceptedTypeGroups);
  }

  void launchGetDirectoryPath(@Nullable String initialDirectory) {
    Intent getDirectoryPathIntent = new Intent(Intent.ACTION_OPEN_DOCUMENT_TREE);

    if (initialDirectory != null && !initialDirectory.isEmpty()) {
      Uri uri = getDirectoryPathIntent.getParcelableExtra("android.provider.extra.INITIAL_URI");
      String scheme = uri.toString();
      scheme = scheme.replace("/root/", initialDirectory);
      uri = Uri.parse(scheme);
      getDirectoryPathIntent.putExtra("android.provider.extra.INITIAL_URI", uri);
    }
    activity.startActivityForResult(getDirectoryPathIntent, REQUEST_CODE_GET_DIRECTORY_PATH);
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
    switch (requestCode) {
      case REQUEST_CODE_GET_DIRECTORY_PATH:
        handleGetDirectoryPathResult(resultCode, data);
        break;
      case REQUEST_CODE_OPEN_FILE:
        handleOpenFileResult(resultCode, data);
        break;
      default:
        return false;
    }

    return true;
  }

  void launchOpenFile(boolean isMultipleSelection, List<String> acceptedTypeGroups) {
    openFileIntent.setAction(Intent.ACTION_GET_CONTENT);
    openFileIntent.addCategory(Intent.CATEGORY_OPENABLE);
    openFileIntent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, isMultipleSelection);

    if (acceptedTypeGroups != null && !acceptedTypeGroups.isEmpty()) {
      openFileIntent.setType(acceptedTypeGroups.get(0));

      openFileIntent.putExtra(Intent.EXTRA_MIME_TYPES, acceptedTypeGroups.toArray(new String[0]));
    }

    activity.startActivityForResult(openFileIntent, REQUEST_CODE_OPEN_FILE);
  }

  private void handleGetDirectoryPathResult(int resultCode, Intent data) {
    if (resultCode == Activity.RESULT_OK && data != null) {
      Uri path = data.getData();
      handleGetDirectoryPathResult(path.toString());
      return;
    }

    finishWithSuccess(null);
  }

  void handleOpenFileResult(int resultCode, Intent data) {
    if (resultCode != Activity.RESULT_OK || data == null) {
      finishWithSuccess(null);
      return;
    }

    ArrayList<Uri> uris = uriHandler(data);

    ArrayList<String> srcPaths =
        PathUtils.copyFilesToInternalStorage(uris, this.activity, cacheFolder);
    handleOpenFileActionResults(srcPaths);
  }

  private void handleGetDirectoryPathResult(String path) {
    finishWithSuccess(path);
  }

  void handleOpenFileActionResults(ArrayList<String> srcPaths) {
    finishWithListSuccess(srcPaths);
  }

  private <T> boolean setPendingResult(Messages.Result<T> result) {
    if (pendingResult != null) {
      return true;
    }

    pendingResult = result;

    return false;
  }

  private void finishWithSuccess(String srcPath) {
    pendingResult.success(srcPath);
    clearMethodCallAndResult();
  }

  void finishWithListSuccess(ArrayList<String> srcPaths) {
    if (pendingResult == null) {
      return;
    }
    pendingResult.success(srcPaths);
    clearMethodCallAndResult();
  }

  private void finishWithAlreadyActiveError(@NonNull Messages.Result result) {
    result.error(new Throwable("File selector is already active", null));
  }

  void clearMethodCallAndResult() {
    pendingResult = null;
  }

  ArrayList<Uri> uriHandler(Intent data) {
    ArrayList<Uri> uris = new ArrayList<>();
    ClipData clipData = data.getClipData();
    if (clipData != null) {
      int itemCount = clipData.getItemCount();
      for (int i = 0; i < itemCount; i++) {
        uris.add(clipData.getItemAt(i).getUri());
      }
    } else {
      uris.add(data.getData());
    }
    return uris;
  }
}
