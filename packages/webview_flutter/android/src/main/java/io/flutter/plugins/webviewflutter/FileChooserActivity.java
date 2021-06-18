package io.flutter.plugins.webviewflutter;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.view.WindowManager;

import androidx.annotation.Nullable;
import androidx.core.content.FileProvider;

import java.io.File;
import java.text.SimpleDateFormat;

import static io.flutter.plugins.webviewflutter.Constants.ACTION_FILE_CHOOSER_FINISHED;
import static io.flutter.plugins.webviewflutter.Constants.EXTRA_IMAGE_URI;
import static io.flutter.plugins.webviewflutter.Constants.EXTRA_SHOW_CAMERA_OPTION;
import static io.flutter.plugins.webviewflutter.Constants.WEBVIEW_CAMERA_IMAGE_DIRECTORY;
import static io.flutter.plugins.webviewflutter.Constants.WEBVIEW_CAMERA_IMAGE_FILE_NAME;

public class FileChooserActivity extends Activity {

    private static final int FILE_CHOOSER_REQUEST_CODE = 12322;

    private Uri cameraImageUri;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            getWindow().setStatusBarColor(Color.TRANSPARENT);
        }

        showFileChooser(getIntent().getBooleanExtra(EXTRA_SHOW_CAMERA_OPTION, false));
    }

    private void showFileChooser(boolean enableCamera) {
        Intent galleryIntent = createGalleryIntent();
        Intent takePictureIntent = enableCamera ? createCameraIntent() : null;
        if (galleryIntent == null && takePictureIntent == null) {
            // cannot open anything: cancel file chooser
            sendBroadcast(new Intent(ACTION_FILE_CHOOSER_FINISHED));
            finish();
        } else {
            Intent[] intentArray = takePictureIntent != null ? new Intent[] { takePictureIntent } : new Intent[]{};

            Intent chooserIntent = new Intent(Intent.ACTION_CHOOSER);
            chooserIntent.putExtra(Intent.EXTRA_INTENT, galleryIntent != null ? galleryIntent : takePictureIntent);
            chooserIntent.putExtra(Intent.EXTRA_TITLE, "Choose file");
            chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, intentArray);

            startActivityForResult(chooserIntent, FILE_CHOOSER_REQUEST_CODE);
        }
    }

    private Intent createGalleryIntent() {
        Intent filesIntent = new Intent(Intent.ACTION_GET_CONTENT);
        filesIntent.setType("image/*");
        return (filesIntent.resolveActivity(getPackageManager()) != null) ? filesIntent : null;
    }

    private Intent createCameraIntent() {
        Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        if (takePictureIntent.resolveActivity(getPackageManager()) == null) {
            return null;
        }
        // Create the File where the photo should go
        cameraImageUri = getTempImageUri();
        takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, cameraImageUri);

        return takePictureIntent;
    }

    private Uri getTempImageUri() {
        File imageDirectory = new File(getCacheDir(), WEBVIEW_CAMERA_IMAGE_DIRECTORY);
        if (!imageDirectory.exists() && !imageDirectory.mkdir()) {
            Log.e("WEBVIEW", "Unable to create image directory");
        }
        File imageFile = new File(imageDirectory, WEBVIEW_CAMERA_IMAGE_FILE_NAME);
        return FileProvider.getUriForFile(this, getApplicationContext().getPackageName() + ".generic.provider", imageFile);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == FILE_CHOOSER_REQUEST_CODE) {
            Intent intent = new Intent(ACTION_FILE_CHOOSER_FINISHED);
            if (resultCode == Activity.RESULT_OK) {
                if (data != null && data.getDataString() != null) {
                    // result from file browser
                    intent.putExtra(EXTRA_IMAGE_URI, data.getDataString());
                } else {
                    // result from camera
                    intent.putExtra(EXTRA_IMAGE_URI, cameraImageUri.toString());
                }
            }
            sendBroadcast(intent);
            finish();
        } else {
            super.onActivityResult(requestCode, resultCode, data);
        }
    }
}
