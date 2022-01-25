//
//  FlashMode.h
//  camera
//
//  Created by Huan Lin on 1/25/22.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Mirrors FlashMode in flash_mode.dart
typedef enum {
  FlashModeOff,
  FlashModeAuto,
  FlashModeAlways,
  FlashModeTorch,
} FlashMode;

FlashMode getFlashModeForString(NSString *mode);
AVCaptureFlashMode getAVCaptureFlashModeForFlashMode(FlashMode mode);

NS_ASSUME_NONNULL_END
