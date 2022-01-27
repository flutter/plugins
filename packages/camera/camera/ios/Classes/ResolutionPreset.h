//
//  ResolutionPreset.h
//  camera
//
//  Created by Huan Lin on 1/26/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


// Mirrors ResolutionPreset in camera.dart
typedef enum {
  veryLow,
  low,
  medium,
  high,
  veryHigh,
  ultraHigh,
  max,
} ResolutionPreset;

extern ResolutionPreset getResolutionPresetForString(NSString *preset);

NS_ASSUME_NONNULL_END
