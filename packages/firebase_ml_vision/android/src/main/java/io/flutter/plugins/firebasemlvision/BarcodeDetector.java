package io.flutter.plugins.firebasemlvision;

import android.graphics.Rect;
import android.support.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.barcode.FirebaseVisionBarcode;
import com.google.firebase.ml.vision.barcode.FirebaseVisionBarcodeDetector;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.common.FirebaseVisionImageMetadata;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.firebasemlvision.util.DetectedItemUtils;

import static io.flutter.plugins.firebasemlvision.constants.VisionBarcodeConstants.*;

class BarcodeDetector implements Detector {
  public static final BarcodeDetector instance = new BarcodeDetector();
  private static FirebaseVisionBarcodeDetector barcodeDetector;

  @Override
  public void handleDetection(FirebaseVisionImage image, final MethodChannel.Result result) {
    if (barcodeDetector == null) barcodeDetector = FirebaseVision.getInstance().getVisionBarcodeDetector();
    barcodeDetector
      .detectInImage(image)
      .addOnSuccessListener(new OnSuccessListener<List<FirebaseVisionBarcode>>() {
        @Override
        public void onSuccess(List<FirebaseVisionBarcode> firebaseVisionBarcodes) {
          List<Map<String, Object>> barcodes = new ArrayList<>();
          for (FirebaseVisionBarcode barcode : firebaseVisionBarcodes) {
            Map<String, Object> barcodeData = new HashMap<>();
            addBarcodeData(barcodeData, barcode);
            barcodes.add(barcodeData);
          }
          result.success(barcodes);
        }
      })
      .addOnFailureListener(new OnFailureListener() {
        @Override
        public void onFailure(@NonNull Exception e) {
          result.error("barcodeDetectorError", e.getLocalizedMessage(), null);
        }
      });
  }

  @Override
  public void close(MethodChannel.Result result) {
    if (barcodeDetector != null) {
      try {
        barcodeDetector.close();
        result.success(null);
      } catch (IOException e) {
        result.error("barcodeDetectorError", e.getLocalizedMessage(), null);
      }
    }
    barcodeDetector = null;
  }

  private void addBarcodeData(Map<String, Object> addTo, FirebaseVisionBarcode barcode) {
    Rect boundingBox = barcode.getBoundingBox();
    if (boundingBox != null) {
      addTo.putAll(DetectedItemUtils.rectToFlutterMap(boundingBox));
    }
    addTo.put(BARCODE_VALUE_TYPE, barcode.getValueType());
    addTo.put(BARCODE_DISPLAY_VALUE, barcode.getDisplayValue());
    addTo.put(BARCODE_RAW_VALUE, barcode.getRawValue());
  }
}
