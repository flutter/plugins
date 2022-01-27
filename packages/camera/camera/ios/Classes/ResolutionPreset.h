//
//  ResolutionPreset.h
//  camera
//
//  Created by Huan Lin on 1/26/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents camera's resolution present. Mirrors ResolutionPreset in camera.dart.
 */
typedef NS_ENUM(NSInteger, ResolutionPreset) {
  veryLow,
  low,
  medium,
  high,
  veryHigh,
  ultraHigh,
  max,
};

/**
 * Gets ResolutionPreset from its string representation.
 * @param preset a string representation of ResolutionPreset.
 */
extern ResolutionPreset FLTGetResolutionPresetForString(NSString *preset);

NS_ASSUME_NONNULL_END
