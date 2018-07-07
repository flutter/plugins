// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_vision;

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
      barcodes.add(new BarcodeContainer._(barcodeMap));
    });
    return barcodes;
  }
}

class BarcodeContainer {
  final Rectangle<int> boundingBox;
  final int valueType;
  final String displayValue;
  final String rawValue;

  BarcodeContainer._(Map<dynamic, dynamic> data)
      : boundingBox = VisionModelUtils.mlRectToRectangle(data),
        valueType = data[barcodeValueType],
        displayValue = data[barcodeDisplayValue],
        rawValue = data[barcodeRawValue];
}

class BarcodeDetectorOptions {}
