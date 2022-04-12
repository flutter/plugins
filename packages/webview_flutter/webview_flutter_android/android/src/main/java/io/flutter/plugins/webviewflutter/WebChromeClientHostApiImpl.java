// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static io.flutter.plugins.webviewflutter.WebViewFlutterPlugin.application;

import android.app.Application;
import android.os.Build;
import android.os.Message;
import android.webkit.GeolocationPermissions;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.annotation.Size;
import androidx.annotation.VisibleForTesting;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.WebChromeClientHostApi;

import android.net.Uri;
import android.util.Log;
import android.Manifest;
import android.annotation.TargetApi;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.ClipData;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.hardware.display.DisplayManager;
import util.FileUtil;
import android.widget.Toast;
import android.content.ClipData;
import android.webkit.ValueCallback;
import android.provider.MediaStore;
import java.io.File;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;
import androidx.core.app.ActivityCompat;

/**
 * Host api implementation for {@link WebChromeClient}.
 *
 * <p>Handles creating {@link WebChromeClient}s that intercommunicate with a paired Dart object.
 */
public class WebChromeClientHostApiImpl implements WebChromeClientHostApi {
  private static final String TAG = "WebChromeClientHostApiI";
  private final InstanceManager instanceManager;
  private final WebChromeClientCreator webChromeClientCreator;
  private final WebChromeClientFlutterApiImpl flutterApi;

  private static ValueCallback<Uri> uploadMessage;
  private static ValueCallback<Uri[]> uploadMessageAboveL;
  private final static int FILE_CHOOSER_RESULT_CODE = 10000;
  public static final int RESULT_OK = -1;

  private static final String[] perms = {Manifest.permission.CAMERA};
  private static final int REQUEST_CAMERA = 1;

  private static Uri cameraUri;

  /**
   * Implementation of {@link WebChromeClient} that passes arguments of callback methods to Dart.
   */
  public static class WebChromeClientImpl extends WebChromeClient implements Releasable {
    @Nullable private WebChromeClientFlutterApiImpl flutterApi;
    private WebViewClient webViewClient;

    /**
     * Creates a {@link WebChromeClient} that passes arguments of callbacks methods to Dart.
     *
     * @param flutterApi handles sending messages to Dart
     * @param webViewClient receives forwarded calls from {@link WebChromeClient#onCreateWindow}
     */
    public WebChromeClientImpl(
        @NonNull WebChromeClientFlutterApiImpl flutterApi, WebViewClient webViewClient) {
      this.flutterApi = flutterApi;
      this.webViewClient = webViewClient;
    }

    @Override
    public boolean onCreateWindow(
        final WebView view, boolean isDialog, boolean isUserGesture, Message resultMsg) {
      return onCreateWindow(view, resultMsg, new WebView(view.getContext()));
    }

    /**
     * Verifies that a url opened by `Window.open` has a secure url.
     *
     * @param view the WebView from which the request for a new window originated.
     * @param resultMsg the message to send when once a new WebView has been created. resultMsg.obj
     *     is a {@link WebView.WebViewTransport} object. This should be used to transport the new
     *     WebView, by calling WebView.WebViewTransport.setWebView(WebView)
     * @param onCreateWindowWebView the temporary WebView used to verify the url is secure
     * @return this method should return true if the host application will create a new window, in
     *     which case resultMsg should be sent to its target. Otherwise, this method should return
     *     false. Returning false from this method but also sending resultMsg will result in
     *     undefined behavior
     */
    @VisibleForTesting
    boolean onCreateWindow(
        final WebView view, Message resultMsg, @Nullable WebView onCreateWindowWebView) {
      final WebViewClient windowWebViewClient =
          new WebViewClient() {
            @RequiresApi(api = Build.VERSION_CODES.N)
            @Override
            public boolean shouldOverrideUrlLoading(
                @NonNull WebView windowWebView, @NonNull WebResourceRequest request) {
              if (!webViewClient.shouldOverrideUrlLoading(view, request)) {
                view.loadUrl(request.getUrl().toString());
              }
              return true;
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView windowWebView, String url) {
              if (!webViewClient.shouldOverrideUrlLoading(view, url)) {
                view.loadUrl(url);
              }
              return true;
            }
          };

      if (onCreateWindowWebView == null) {
        onCreateWindowWebView = new WebView(view.getContext());
      }
      onCreateWindowWebView.setWebViewClient(windowWebViewClient);

      final WebView.WebViewTransport transport = (WebView.WebViewTransport) resultMsg.obj;
      transport.setWebView(onCreateWindowWebView);
      resultMsg.sendToTarget();

      return true;
    }

    @Override
    public void onProgressChanged(WebView view, int progress) {
      if (flutterApi != null) {
        flutterApi.onProgressChanged(this, view, (long) progress, reply -> {});
      }
    }

    //For Android  >= 4.1
    public void openFileChooser(ValueCallback<Uri> valueCallback, String acceptType, String capture) {
      Log.v(TAG, "openFileChooser Android  >= 4.1");
      uploadMessage = valueCallback;
      takePhotoOrOpenGallery();
    }

    // For Android >= 5.0
    @Override
    public boolean onShowFileChooser(WebView webView, ValueCallback<Uri[]> filePathCallback, FileChooserParams fileChooserParams) {
      Log.v(TAG, "openFileChooser Android >= 5.0");
      uploadMessageAboveL = filePathCallback;
      takePhotoOrOpenGallery();
      return true;
    }

    /**
     * Set the {@link WebViewClient} that calls to {@link WebChromeClient#onCreateWindow} are passed
     * to.
     *
     * @param webViewClient the forwarding {@link WebViewClient}
     */
    public void setWebViewClient(WebViewClient webViewClient) {
      this.webViewClient = webViewClient;
    }

    @Override
    public void onGeolocationPermissionsShowPrompt(String origin, GeolocationPermissions.Callback callback) {
      callback.invoke(origin, true, false);
      super.onGeolocationPermissionsShowPrompt(origin, callback);
    }

    @Override
    public void release() {
      if (flutterApi != null) {
        flutterApi.dispose(this, reply -> {});
      }
      flutterApi = null;
    }
  }

  /** Handles creating {@link WebChromeClient}s for a {@link WebChromeClientHostApiImpl}. */
  public static class WebChromeClientCreator {
    /**
     * Creates a {@link DownloadListenerHostApiImpl.DownloadListenerImpl}.
     *
     * @param flutterApi handles sending messages to Dart
     * @param webViewClient receives forwarded calls from {@link WebChromeClient#onCreateWindow}
     * @return the created {@link DownloadListenerHostApiImpl.DownloadListenerImpl}
     */
    public WebChromeClientImpl createWebChromeClient(
        WebChromeClientFlutterApiImpl flutterApi, WebViewClient webViewClient) {
      return new WebChromeClientImpl(flutterApi, webViewClient);
    }
  }

  /**
   * Creates a host API that handles creating {@link WebChromeClient}s.
   *
   * @param instanceManager maintains instances stored to communicate with Dart objects
   * @param webChromeClientCreator handles creating {@link WebChromeClient}s
   * @param flutterApi handles sending messages to Dart
   */
  public WebChromeClientHostApiImpl(
      InstanceManager instanceManager,
      WebChromeClientCreator webChromeClientCreator,
      WebChromeClientFlutterApiImpl flutterApi) {
    this.instanceManager = instanceManager;
    this.webChromeClientCreator = webChromeClientCreator;
    this.flutterApi = flutterApi;
  }

  @Override
  public void create(Long instanceId, Long webViewClientInstanceId) {
    final WebViewClient webViewClient =
        (WebViewClient) instanceManager.getInstance(webViewClientInstanceId);
    final WebChromeClient webChromeClient =
        webChromeClientCreator.createWebChromeClient(flutterApi, webViewClient);
    instanceManager.addInstance(webChromeClient, instanceId);
  }

  private static void openImageChooserActivity() {
    Log.v(TAG, "openImageChooserActivity");
    if (WebViewFlutterPlugin.activity == null) {
      Log.v(TAG, "activity is null");
      return;
    }
    Intent intent1 = new Intent(Intent.ACTION_GET_CONTENT);
    intent1.addCategory(Intent.CATEGORY_OPENABLE);
    intent1.setType("*/*");

    Intent chooser = new Intent(Intent.ACTION_CHOOSER);
    chooser.putExtra(Intent.EXTRA_TITLE, WebViewFlutterPlugin.activity.getString(R.string.select_picture));
    chooser.putExtra(Intent.EXTRA_INTENT, intent1);
    WebViewFlutterPlugin.activity.startActivityForResult(chooser, FILE_CHOOSER_RESULT_CODE);
  }

  private static void takePhotoOrOpenGallery() {
    if (WebViewFlutterPlugin.activity==null||!FileUtil.checkSDcard(WebViewFlutterPlugin.activity)) {
      return;
    }
    String[] selectPicTypeStr = {WebViewFlutterPlugin.activity.getString(R.string.take_photo),
            WebViewFlutterPlugin.activity.getString(R.string.photo_library)};
    new AlertDialog.Builder(WebViewFlutterPlugin.activity, AlertDialog.THEME_DEVICE_DEFAULT_DARK)
            .setOnCancelListener(new ReOnCancelListener())
            .setItems(selectPicTypeStr,
                    new DialogInterface.OnClickListener() {
                      @Override
                      public void onClick(DialogInterface dialog, int which) {
                        switch (which) {
                          // 相机拍摄
                          case 0:
                            openCamera();
                            break;
                          // 手机相册
                          case 1:
                            openImageChooserActivity();
                            break;
                          default:
                            break;
                        }
                      }
                    }).show();
  }

  /**
   * dialog监听类
   */
  private static class ReOnCancelListener implements DialogInterface.OnCancelListener {
    @Override
    public void onCancel(DialogInterface dialogInterface) {
      if (uploadMessage != null) {
        uploadMessage.onReceiveValue(null);
        uploadMessage = null;
      }

      if (uploadMessageAboveL != null) {
        uploadMessageAboveL.onReceiveValue(null);
        uploadMessageAboveL = null;
      }
    }
  }

  /**
   * 打开照相机
   */
  private static void openCamera() {
    if (WebViewFlutterPlugin.activity == null) {
      android.widget.Toast.makeText(application, "activity can not null", Toast.LENGTH_SHORT).show();
      return;
    }
    if (hasPermissions(WebViewFlutterPlugin.activity, perms)) {
      try {
        //创建File对象，用于存储拍照后的照片
        File outputImage = FileUtil.createImageFile(WebViewFlutterPlugin.activity);
        if (outputImage.exists()) {
          outputImage.delete();
        }
        outputImage.createNewFile();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
          cameraUri = FileProvider.getUriForFile(WebViewFlutterPlugin.activity, WebViewFlutterPlugin.activity.getPackageName() + ".fileprovider", outputImage);
        } else {
          Uri.fromFile(outputImage);
        }
        //启动相机程序
        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        intent.putExtra(MediaStore.EXTRA_OUTPUT, cameraUri);
        WebViewFlutterPlugin.activity.startActivityForResult(intent, REQUEST_CAMERA);
      } catch (Exception e) {
        Toast.makeText(application, e.getMessage(), Toast.LENGTH_SHORT).show();
        if (uploadMessageAboveL != null) {
          uploadMessageAboveL.onReceiveValue(null);
          uploadMessageAboveL = null;
        }
      }
    } else {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        ActivityCompat.requestPermissions(WebViewFlutterPlugin.activity, perms, REQUEST_CAMERA);
      }
    }
  }

  /**
   * Check if the calling context has a set of permissions.
   *
   * @param context the calling context.
   * @param perms   one ore more permissions, such as {@link Manifest.permission#CAMERA}.
   * @return true if all permissions are already granted, false if at least one permission is not
   * yet granted.
   * @see Manifest.permission
   */
  public static boolean hasPermissions(@NonNull Context context,
                                       @Size(min = 1) @NonNull String... perms) {
    // Always return true for SDK < M, let the system deal with the permissions
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
      Log.w(TAG, "hasPermissions: API version < M, returning true by default");

      // DANGER ZONE!!! Changing this will break the library.
      return true;
    }

    // Null context may be passed if we have detected Low API (less than M) so getting
    // to this point with a null context should not be possible.
    if (context == null) {
      throw new IllegalArgumentException("Can't check permissions for null context");
    }

    for (String perm : perms) {
      if (ContextCompat.checkSelfPermission(context, perm)
              != PackageManager.PERMISSION_GRANTED) {
        return false;
      }
    }

    return true;
  }

  public boolean requestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    if (requestCode == REQUEST_CAMERA) {
      if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
        openCamera();
      } else {
        Toast.makeText(application, application.getString(R.string.take_pic_need_permission), Toast.LENGTH_SHORT).show();
        if (uploadMessage != null) {
          uploadMessage.onReceiveValue(null);
          uploadMessage = null;
        }
        if (uploadMessageAboveL != null) {
          uploadMessageAboveL.onReceiveValue(null);
          uploadMessageAboveL = null;
        }
      }
    }
    return false;
  }

  public boolean activityResult(int requestCode, int resultCode, Intent data) {
    Log.v(TAG, "activityResult: " );
    if (null == uploadMessage && null == uploadMessageAboveL) {
      return false;
    }
    Uri result = null;
    if (requestCode == REQUEST_CAMERA && resultCode == RESULT_OK) {
      result = cameraUri;
    }
    if (requestCode == FILE_CHOOSER_RESULT_CODE) {
      result = data == null || resultCode != RESULT_OK ? null : data.getData();
    }
    if (uploadMessageAboveL != null) {
      onActivityResultAboveL(requestCode, resultCode, data);
    }
    else if (uploadMessage != null && result != null) {
      uploadMessage.onReceiveValue(result);
      uploadMessage = null;
    }
    return false;
  }

  @TargetApi(Build.VERSION_CODES.LOLLIPOP)
  private void onActivityResultAboveL(int requestCode, int resultCode, Intent intent) {
    if (requestCode != FILE_CHOOSER_RESULT_CODE && requestCode != REQUEST_CAMERA || uploadMessageAboveL == null) {
      return;
    }
    Uri[] results = null;
    if (requestCode == REQUEST_CAMERA && resultCode == RESULT_OK) {
      results = new Uri[]{cameraUri};
    }

    if (requestCode == FILE_CHOOSER_RESULT_CODE && resultCode == Activity.RESULT_OK) {
      if (intent != null) {
        String dataString = intent.getDataString();
        ClipData clipData = intent.getClipData();
        if (clipData != null) {
          results = new Uri[clipData.getItemCount()];
          for (int i = 0; i < clipData.getItemCount(); i++) {
            ClipData.Item item = clipData.getItemAt(i);
            results[i] = item.getUri();
          }
        }
        if (dataString != null) {
          results = new Uri[]{Uri.parse(dataString)};
        }
      }
    }
    uploadMessageAboveL.onReceiveValue(results);
    uploadMessageAboveL = null;
  }

}
