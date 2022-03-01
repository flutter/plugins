// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "IosPlatformImagesPlugin.h"

#if !__has_feature(objc_arc)
#error ARC must be enabled!
#endif

@interface IosPlatformImagesPlugin ()
@end

@implementation IosPlatformImagesPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/ios_platform_images"
                                  binaryMessenger:[registrar messenger]];

  [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
    if ([@"loadImage" isEqualToString:call.method]) {
      NSString *name = call.arguments;
      UIImage *image = [UIImage imageNamed:name];
      NSData *data = UIImagePNGRepresentation(image);
      if (data) {
        result(@{
          @"scale" : @(image.scale),
          @"data" : [FlutterStandardTypedData typedDataWithBytes:data],
        });
      } else {
        result(nil);
      }
      return;
    } else if ([@"resolveURL" isEqualToString:call.method]) {
      NSArray *args = call.arguments;
      NSString *name = args[0];
      NSString *extension = (args[1] == (id)NSNull.null) ? nil : args[1];

      NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:extension];
      result(url.absoluteString);
      return;
    } else if ([@"loadSystemImage" isEqualToString:call.method]) {
      if (@available(iOS 13, *)) {
        NSString *name = call.arguments[0];
        NSNumber *pointSizeWithDouble = call.arguments[1];
        double pointSize = [pointSizeWithDouble doubleValue];
        NSNumber *weightIndex = call.arguments[2];

        // Up to 3 rgb values for primary, seconday and tertiary colors.
        // see
        // https://developer.apple.com/documentation/uikit/uiimagesymbolconfiguration/3810054-configurationwithpalettecolors
        NSArray *rgbaValuesList = call.arguments[3];

        NSMutableArray *colorArray = [[NSMutableArray alloc] init];

        for (int i = 0; i < [rgbaValuesList count]; i += 4) {
          UIColor *primaryColor = [UIColor colorWithRed:[rgbaValuesList[i] doubleValue]
                                                  green:[rgbaValuesList[i + 1] doubleValue]
                                                   blue:[rgbaValuesList[i + 2] doubleValue]
                                                  alpha:[rgbaValuesList[i + 3] doubleValue]];
          [colorArray addObject:primaryColor];
        }

        UIImageSymbolWeight weight = UIImageSymbolWeightRegular;

        switch ([weightIndex integerValue]) {
          case 0:
            weight = UIImageSymbolWeightUltraLight;
            break;
          case 1:
            weight = UIImageSymbolWeightThin;
            break;
          case 2:
            weight = UIImageSymbolWeightLight;
            break;
          // 3 is regular
          case 4:
            weight = UIImageSymbolWeightMedium;
            break;
          case 5:
            weight = UIImageSymbolWeightSemibold;
            break;
          case 6:
            weight = UIImageSymbolWeightBold;
            break;
          case 7:
            weight = UIImageSymbolWeightHeavy;
            break;
          case 8:
            weight = UIImageSymbolWeightBlack;
            break;
          default:
            weight = UIImageSymbolWeightRegular;
            break;
        }

        UIImageSymbolConfiguration *pointSizeConfig =
            [UIImageSymbolConfiguration configurationWithPointSize:pointSize
                                                            weight:weight
                                                             scale:UIImageSymbolScaleDefault];

        UIImage *finalImage;

        if (@available(iOS 15, *)) {
          NSNumber *preferMulticolor = call.arguments[4];
          UIImageSymbolConfiguration *colors;

          if ([preferMulticolor boolValue]) {
            colors = [UIImageSymbolConfiguration configurationPreferringMulticolor];
          } else {
            colors = [UIImageSymbolConfiguration configurationWithPaletteColors:colorArray];
          }

          UIImageSymbolConfiguration *final =
              [pointSizeConfig configurationByApplyingConfiguration:colors];
          finalImage = [UIImage systemImageNamed:name withConfiguration:final];
        } else {
          UIImage *image = [UIImage systemImageNamed:name withConfiguration:pointSizeConfig];
          finalImage = [image imageWithTintColor:colorArray.count > 0 ? colorArray[0] : nil];
        }

        NSData *data = UIImagePNGRepresentation(finalImage);
        if (data) {
          result(@{
            @"scale" : @(finalImage.scale),
            @"data" : [FlutterStandardTypedData typedDataWithBytes:data],
          });
        } else {
          result(nil);
        }
        return;
      }
    }
    result(FlutterMethodNotImplemented);
  }];
}

@end
