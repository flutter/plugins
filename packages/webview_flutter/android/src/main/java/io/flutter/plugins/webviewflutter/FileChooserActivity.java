// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static io.flutter.plugins.webviewflutter.Constants.ACTION_FILE_CHOOSER_FINISHED;
import static io.flutter.plugins.webviewflutter.Constants.EXTRA_ACCEPT_TYPES;
import static io.flutter.plugins.webviewflutter.Constants.EXTRA_ALLOW_MULTIPLE_FILES;
import static io.flutter.plugins.webviewflutter.Constants.EXTRA_FILE_URIS;
import static io.flutter.plugins.webviewflutter.Constants.EXTRA_SHOW_IMAGE_OPTION;
import static io.flutter.plugins.webviewflutter.Constants.EXTRA_SHOW_VIDEO_OPTION;
import static io.flutter.plugins.webviewflutter.Constants.EXTRA_TITLE;
import static io.flutter.plugins.webviewflutter.Constants.WEBVIEW_STORAGE_DIRECTORY;

import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.provider.OpenableColumns;
import android.util.Log;
import androidx.annotation.Nullable;
import androidx.core.content.FileProvider;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

public class FileChooserActivity extends Activity {

  private static final int FILE_CHOOSER_REQUEST_CODE = 12322;
  private static final SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");

  // List of Uris that point to files where there MIGHT be the output of the capture. At most one of these can be valid
  private final ArrayList<Uri> potentialCaptureOutputUris = new ArrayList<>();

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    showFileChooser(
        getIntent().getBooleanExtra(EXTRA_SHOW_IMAGE_OPTION, false),
        getIntent().getBooleanExtra(EXTRA_SHOW_VIDEO_OPTION, false));
  }

  private void showFileChooser(boolean showImageIntent, boolean showVideoIntent) {
    Intent getContentIntent = createGetContentIntent();
    Intent captureImageIntent =
        showImageIntent ? createCaptureIntent(MediaStore.ACTION_IMAGE_CAPTURE, "jpg") : null;
    Intent captureVideoIntent =
        showVideoIntent ? createCaptureIntent(MediaStore.ACTION_VIDEO_CAPTURE, "mp4") : null;

    if (getContentIntent == null && captureImageIntent == null && captureVideoIntent == null) {
      // cannot open anything: cancel file chooser
      sendBroadcast(new Intent(ACTION_FILE_CHOOSER_FINISHED));
      finish();
    } else {
      ArrayList<Intent> intentList = new ArrayList<>();

      if (getContentIntent != null) {
        intentList.add(getContentIntent);
      }

      if (captureImageIntent != null) {
        intentList.add(captureImageIntent);
      }
      if (captureVideoIntent != null) {
        intentList.add(captureVideoIntent);
      }

      Intent chooserIntent = new Intent(Intent.ACTION_CHOOSER);
      chooserIntent.putExtra(Intent.EXTRA_TITLE, getIntent().getStringExtra(EXTRA_TITLE));

      chooserIntent.putExtra(Intent.EXTRA_INTENT, intentList.get(0));
      intentList.remove(0);
      if (intentList.size() > 0) {
        chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, intentList.toArray(new Intent[0]));
      }

      startActivityForResult(chooserIntent, FILE_CHOOSER_REQUEST_CODE);
    }
  }

  private Intent createGetContentIntent() {
    Intent filesIntent = new Intent(Intent.ACTION_GET_CONTENT);

    if (getIntent().getBooleanExtra(EXTRA_ALLOW_MULTIPLE_FILES, false)) {
      filesIntent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);
    }

    String[] acceptTypes = getIntent().getStringArrayExtra(EXTRA_ACCEPT_TYPES);

    if (acceptTypes.length == 0 || (acceptTypes.length == 1 && acceptTypes[0].length() == 0)) {
      // empty array or only 1 empty string? -> accept all types
      filesIntent.setType("*/*");
    } else if (acceptTypes.length == 1) {
      filesIntent.setType(acceptTypes[0]);
    } else {
      // acceptTypes.length > 1
      filesIntent.setType("*/*");
      filesIntent.putExtra(Intent.EXTRA_MIME_TYPES, acceptTypes);
    }

    return (filesIntent.resolveActivity(getPackageManager()) != null) ? filesIntent : null;
  }

  private Intent createCaptureIntent(String type, String fileFormat) {
    Intent captureIntent = new Intent(type);
    if (captureIntent.resolveActivity(getPackageManager()) == null) {
      return null;
    }

    // Create the File where the output should go
    Uri captureOutputUri = getTempUri(fileFormat);
    potentialCaptureOutputUris.add(captureOutputUri);

    captureIntent.putExtra(MediaStore.EXTRA_OUTPUT, captureOutputUri);

    return captureIntent;
  }

  private File getStorageDirectory() {
    File imageDirectory = new File(getCacheDir(), WEBVIEW_STORAGE_DIRECTORY);
    if (!imageDirectory.exists() && !imageDirectory.mkdir()) {
      Log.e("WEBVIEW", "Unable to create storage directory");
    }
    return imageDirectory;
  }

  private Uri getTempUri(String format) {
    String fileName = "CAPTURE-" + simpleDateFormat.format(new Date()) + "." + format;
    File file = new File(getStorageDirectory(), fileName);
    return FileProvider.getUriForFile(
        this, getApplicationContext().getPackageName() + ".generic.provider", file);
  }

  private String getFileNameFromUri(Uri uri) {
    Cursor returnCursor = getContentResolver().query(uri, null, null, null, null);
    assert returnCursor != null;
    int nameIndex = returnCursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
    returnCursor.moveToFirst();
    String name = returnCursor.getString(nameIndex);
    returnCursor.close();
    return name;
  }

  private Uri copyToLocalUri(Uri uri) {
    File destination = new File(getStorageDirectory(), getFileNameFromUri(uri));

    try (InputStream in = getContentResolver().openInputStream(uri);
        OutputStream out = new FileOutputStream(destination)) {
      byte[] buffer = new byte[1024];
      int len;
      while ((len = in.read(buffer)) != -1) {
        out.write(buffer, 0, len);
      }
      return FileProvider.getUriForFile(
          this, getApplicationContext().getPackageName() + ".generic.provider", destination);
    } catch (IOException e) {
      Log.e("WEBVIEW", "Unable to copy selected image", e);
      e.printStackTrace();
      return null;
    }
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    if (requestCode == FILE_CHOOSER_REQUEST_CODE) {
      Intent fileChooserFinishedIntent = new Intent(ACTION_FILE_CHOOSER_FINISHED);
      if (resultCode == Activity.RESULT_OK) {
        if (data != null && (data.getDataString() != null || data.getClipData() != null)) {
          if (data.getDataString() != null) {
            // single result from file browser OR video from camera
            Uri localUri = copyToLocalUri(data.getData());
            if (localUri != null) {
              fileChooserFinishedIntent.putExtra(
                  EXTRA_FILE_URIS, new String[] {localUri.toString()});
            }
          } else if (data.getClipData() != null) {
            // multiple results from file browser
            int uriCount = data.getClipData().getItemCount();
            String[] uriStrings = new String[uriCount];

            for (int i = 0; i < uriCount; i++) {
              Uri localUri = copyToLocalUri(data.getClipData().getItemAt(i).getUri());
              if (localUri != null) {
                uriStrings[i] = localUri.toString();
              }
            }
            fileChooserFinishedIntent.putExtra(EXTRA_FILE_URIS, uriStrings);
          }
        } else {
          // image result from camera (videos from the camera are handled above, but this if-branch could handle them too if this varies from device to device)
          for (Uri captureOutputUri : potentialCaptureOutputUris) {
            try {
              // just opening an input stream (and closing immediately) to test if the Uri points to a valid file
              // if it's not a real file, the below catch-clause gets executed and we continue with the next Uri in the loop.
              getContentResolver().openInputStream(captureOutputUri).close();
              fileChooserFinishedIntent.putExtra(
                  EXTRA_FILE_URIS, new String[] {captureOutputUri.toString()});
              // leave the loop, as only one of the potentialCaptureOutputUris is valid and we just found it
              break;
            } catch (IOException ignored) {
            }
          }
        }
      }
      sendBroadcast(fileChooserFinishedIntent);
      finish();
    } else {
      super.onActivityResult(requestCode, resultCode, data);
    }
  }
}
