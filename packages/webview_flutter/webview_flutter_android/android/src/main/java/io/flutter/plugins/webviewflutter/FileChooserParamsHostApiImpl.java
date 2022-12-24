package io.flutter.plugins.webviewflutter;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.webkit.WebChromeClient;
import android.webkit.WebViewClient;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import io.flutter.plugin.common.PluginRegistry;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/**
 * Host api implementation for {@link android.webkit.WebChromeClient.FileChooserParams}.
 *
 * <p>Handles creating {@link android.webkit.WebChromeClient.FileChooserParams}s that
 * intercommunicate with a paired Dart object.
 */
@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public class FileChooserParamsHostApiImpl
    implements GeneratedAndroidWebView.FileChooserParamsHostApi {
  private static final int SHOW_FILE_CHOOSER_REQUEST = 0;

  private final InstanceManager instanceManager;

  @Nullable private Activity activity;
  @Nullable private GeneratedAndroidWebView.Result<List<String>> pendingResult;

  private final PluginRegistry.ActivityResultListener activityResultListener =
      new PluginRegistry.ActivityResultListener() {
        @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
        @Override
        public boolean onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
          if (requestCode == SHOW_FILE_CHOOSER_REQUEST) {
            final Uri[] result = WebChromeClient.FileChooserParams.parseResult(resultCode, data);

            if (result != null) {
              final List<String> filePaths = new ArrayList<>();
              for (Uri uri : result) {
                filePaths.add(uri.toString());
              }
              pendingResult.success(filePaths);
            } else {
              pendingResult.error(new Exception("Request cancelled or failed."));
            }

            pendingResult = null;
            return true;
          }

          return false;
        }
      };

  /**
   * Creates a host API that handles creating {@link WebViewClient}s.
   *
   * @param instanceManager maintains instances stored to communicate with Dart objects
   */
  public FileChooserParamsHostApiImpl(InstanceManager instanceManager) {
    this.instanceManager = instanceManager;
  }

  @Override
  public void openFilePickerForResult(
      @NonNull Long instanceId, GeneratedAndroidWebView.Result<List<String>> result) {
    if (activity == null) {
      throw new IllegalStateException("Activity has not been set.");
    } else if (pendingResult != null) {
      throw new IllegalStateException("A file picker result is already pending.");
    }

    final WebChromeClient.FileChooserParams instance =
        Objects.requireNonNull(instanceManager.getInstance(instanceId));

    pendingResult = result;
    activity.startActivityForResult(instance.createIntent(), SHOW_FILE_CHOOSER_REQUEST);
  }

  /**
   * The listener that handles returned values from activities opened for results.
   *
   * @return the result listener of this Flutter API
   */
  public PluginRegistry.ActivityResultListener getActivityResultListener() {
    return activityResultListener;
  }

  /**
   * Sets the activity to handle intents.
   *
   * @param activity the desired activity to handle intents
   */
  public void setActivity(@Nullable Activity activity) {
    this.activity = activity;
  }
}
