package io.flutter.plugins.webviewflutter;

import android.Manifest;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.webkit.ValueCallback;

import androidx.core.content.ContextCompat;

import static io.flutter.plugins.webviewflutter.Constants.ACTION_FILE_CHOOSER_FINISHED;
import static io.flutter.plugins.webviewflutter.Constants.ACTION_PERMISSIONS_DENIED;
import static io.flutter.plugins.webviewflutter.Constants.ACTION_PERMISSIONS_GRANTED;
import static io.flutter.plugins.webviewflutter.Constants.EXTRA_IMAGE_URI;
import static io.flutter.plugins.webviewflutter.Constants.EXTRA_SHOW_CAMERA_OPTION;

public class FileChooserLauncher extends BroadcastReceiver {

    private Activity activity;
    private ValueCallback<Uri[]> filePathCallback;

    public FileChooserLauncher(Context context, ValueCallback<Uri[]> filePathCallback) {
        this.activity = getActivityByContext(context);
        this.filePathCallback = filePathCallback;
    }

    private Activity getActivityByContext(Context context) {
        if (context == null) {
            return null;
        } else if (context instanceof Activity){
            return (Activity)context;
        } else if (context instanceof ContextWrapper){
            return getActivityByContext(((ContextWrapper)context).getBaseContext());
        }

        return null;
    }

    private boolean hasCameraPermission() {
        return ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA)
                == PackageManager.PERMISSION_GRANTED;
    }

    public void start() {
        if (hasCameraPermission()) {
            showFileChooser(true);
        } else {
            IntentFilter intentFilter = new IntentFilter();
            intentFilter.addAction(ACTION_PERMISSIONS_GRANTED);
            intentFilter.addAction(ACTION_PERMISSIONS_DENIED);
            activity.registerReceiver(this, intentFilter);

            activity.startActivity(new Intent(activity, RequestCameraPermissionActivity.class));
        }
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent.getAction().equals(ACTION_PERMISSIONS_GRANTED)) {
            activity.unregisterReceiver(this);
            showFileChooser(true);
        } else if (intent.getAction().equals(ACTION_PERMISSIONS_DENIED)) {
            activity.unregisterReceiver(this);
            showFileChooser(false);
        } else if (intent.getAction().equals(ACTION_FILE_CHOOSER_FINISHED)) {
            String uriString = intent.getStringExtra(EXTRA_IMAGE_URI);
            Uri[] result = uriString != null ? new Uri[]{Uri.parse(uriString)} : null;
            filePathCallback.onReceiveValue(result);
            activity.unregisterReceiver(this);
            filePathCallback = null;
        }
    }

    private void showFileChooser(boolean hasCameraPermission) {
        IntentFilter intentFilter = new IntentFilter(ACTION_FILE_CHOOSER_FINISHED);
        activity.registerReceiver(this, intentFilter);

        Intent intent = new Intent(activity, FileChooserActivity.class);
        intent.putExtra(EXTRA_SHOW_CAMERA_OPTION, hasCameraPermission);
        activity.startActivity(intent);
    }
}
