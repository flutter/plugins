// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
#import "CameraPermissionUtils.h"

void FLTRequestCameraPermissionWithCompletionHandler(
    FLTCameraPermissionRequestCompletionHandler handler) {
  switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
    case AVAuthorizationStatusAuthorized:
      handler(nil);
      break;
    case AVAuthorizationStatusDenied:
      handler([FlutterError errorWithCode:@"CameraAccessDeniedWithoutPrompt"
                                  message:@"User has previously denied the camera access request. "
                                          @"Go to Settings to enable camera access."
                                  details:nil]);
      break;
    case AVAuthorizationStatusRestricted:
      handler([FlutterError errorWithCode:@"CameraAccessRestricted"
                                  message:@"Camera access is restricted. "
                                  details:nil]);
      break;
    case AVAuthorizationStatusNotDetermined: {
      [AVCaptureDevice
          requestAccessForMediaType:AVMediaTypeVideo
                  completionHandler:^(BOOL granted) {
                    // handler can be invoked on an arbitrary dispatch queue.
                    handler(granted ? nil
                                    : [FlutterError
                                          errorWithCode:@"CameraAccessDenied"
                                                message:@"User denied the camera access request."
                                                details:nil]);
                  }];
      break;
    }
  }
}
