//
//  Copyright (c) 2018 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "UIUtilities.h"

static CGFloat const circleViewAlpha = 0.7;
static CGFloat const rectangleViewAlpha = 0.3;
static CGFloat const shapeViewAlpha = 0.3;
static CGFloat const rectangleViewCornerRadius = 10.0;

@implementation UIUtilities

+ (void)imageOrientation {
  [self imageOrientationFromDevicePosition:AVCaptureDevicePositionBack];
}

+ (UIImageOrientation) imageOrientationFromDevicePosition:(AVCaptureDevicePosition)devicePosition {
  UIDeviceOrientation deviceOrientation = UIDevice.currentDevice.orientation;
  if (deviceOrientation == UIDeviceOrientationFaceDown || deviceOrientation == UIDeviceOrientationFaceUp || deviceOrientation == UIDeviceOrientationUnknown) {
    deviceOrientation = [self currentUIOrientation];
  }
  switch (deviceOrientation) {
    case UIDeviceOrientationPortrait:
      return devicePosition == AVCaptureDevicePositionFront ? UIImageOrientationLeftMirrored : UIImageOrientationRight;
    case UIDeviceOrientationLandscapeLeft:
      return devicePosition == AVCaptureDevicePositionFront ? UIImageOrientationDownMirrored : UIImageOrientationUp;
    case UIDeviceOrientationPortraitUpsideDown:
      return devicePosition == AVCaptureDevicePositionFront ? UIImageOrientationRightMirrored : UIImageOrientationLeft;
    case UIDeviceOrientationLandscapeRight:
      return devicePosition == AVCaptureDevicePositionFront ? UIImageOrientationUpMirrored : UIImageOrientationDown;
    case UIDeviceOrientationFaceDown:
    case UIDeviceOrientationFaceUp:
    case UIDeviceOrientationUnknown:
      return UIImageOrientationUp;
  }
}

+ (FIRVisionDetectorImageOrientation) visionImageOrientationFromImageOrientation:(UIImageOrientation)imageOrientation {
  switch (imageOrientation) {
    case UIImageOrientationUp:
      return FIRVisionDetectorImageOrientationTopLeft;
    case UIImageOrientationDown:
      return FIRVisionDetectorImageOrientationBottomRight;
    case UIImageOrientationLeft:
      return FIRVisionDetectorImageOrientationLeftBottom;
    case UIImageOrientationRight:
      return FIRVisionDetectorImageOrientationRightTop;
    case UIImageOrientationUpMirrored:
      return FIRVisionDetectorImageOrientationTopRight;
    case UIImageOrientationDownMirrored:
      return FIRVisionDetectorImageOrientationBottomLeft;
    case UIImageOrientationLeftMirrored:
      return FIRVisionDetectorImageOrientationLeftTop;
    case UIImageOrientationRightMirrored:
      return FIRVisionDetectorImageOrientationRightBottom;
  }
}

+ (UIDeviceOrientation) currentUIOrientation {
  UIDeviceOrientation (^deviceOrientation)(void) = ^UIDeviceOrientation(void) {
    switch (UIApplication.sharedApplication.statusBarOrientation) {
      case UIInterfaceOrientationLandscapeLeft:
        return UIDeviceOrientationLandscapeRight;
      case UIInterfaceOrientationLandscapeRight:
        return UIDeviceOrientationLandscapeLeft;
      case UIInterfaceOrientationPortraitUpsideDown:
        return UIDeviceOrientationPortraitUpsideDown;
      case UIInterfaceOrientationPortrait:
      case UIInterfaceOrientationUnknown:
        return UIDeviceOrientationPortrait;
    }
  };
  
  if (NSThread.isMainThread) {
    return deviceOrientation();
  } else {
    __block UIDeviceOrientation currentOrientation = UIDeviceOrientationPortrait;
    dispatch_sync(dispatch_get_main_queue(), ^{
      currentOrientation = deviceOrientation();
    });
    return currentOrientation;
  }
}
@end
