package io.flutter.plugins.webviewflutter;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;

import static io.flutter.plugins.webviewflutter.Constants.ACTION_PERMISSIONS_DENIED;
import static io.flutter.plugins.webviewflutter.Constants.ACTION_PERMISSIONS_GRANTED;

public class RequestCameraPermissionActivity extends Activity {

    private static final int CAMERA_PERMISSION_REQUEST_CODE = 12321;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ActivityCompat.requestPermissions(
                this,
                new String[]{Manifest.permission.CAMERA},
                CAMERA_PERMISSION_REQUEST_CODE
        );
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode == CAMERA_PERMISSION_REQUEST_CODE) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                sendBroadcast(new Intent(ACTION_PERMISSIONS_GRANTED));
            } else {
                sendBroadcast(new Intent(ACTION_PERMISSIONS_DENIED));
            }
            finish();
        } else {
            super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        }
    }
}
