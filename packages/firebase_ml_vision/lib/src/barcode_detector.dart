// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_vision;

const String barcodeValueType = "barcode_value_type";
const String barcodeDisplayValue = "barcode_display_value";
const String barcodeRawValue = "barcode_raw_value";

class BarcodeDetector extends FirebaseVisionDetector {
  BarcodeDetector._(BarcodeDetectorOptions options);

  @override
  Future<void> close() async {
    return FirebaseVision.channel.invokeMethod('BarcodeDetector#close');
  }

  @override
  Future<List<BarcodeContainer>> detectInImage(
      FirebaseVisionImage visionImage) async {
    final List<dynamic> reply = await FirebaseVision.channel.invokeMethod(
        'BarcodeDetector#detectInImage', visionImage.imageFile.path);
    final List<BarcodeContainer> barcodes = <BarcodeContainer>[];
    reply.forEach((dynamic barcodeMap) {
      barcodes.add(new BarcodeContainer(barcodeMap));
    });
    return barcodes;
  }
}

class BarcodeContainer {
  final Rectangle<int> boundingBox;
  final int valueType;
  final String displayValue;
  final String rawValue;

  BarcodeContainer(Map<dynamic, dynamic> data)
      : boundingBox = VisionModelUtils.mlRectToRectangle(data),
        valueType = data[barcodeValueType],
        displayValue = data[barcodeDisplayValue],
        rawValue = data[barcodeRawValue];

  @override
  String toString() {
    return 'BarcodeContainer{boundingBox: $boundingBox,'
        ' valueType: $valueType,'
        ' displayValue: $displayValue,'
        ' rawValue: $rawValue}';
  }
}

class BarcodeDetectorOptions {}
