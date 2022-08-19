#import "FLTPlatformImagesPlugin.h"
#import "PlatformImagesApi.g.h"

@implementation FLTPlatformImagesPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FLTPlatformImagesPlugin *instance = [[FLTPlatformImagesPlugin alloc] init];
  [registrar publish:instance];
  FLTPlatformImagesApiSetup(registrar.messenger, instance);
}

- (nullable FLTPlatformImage *)getSystemImageName:(NSString *)name size:(NSNumber *)size weight:(FLTFontWeight)weight colorsRGBA:(NSArray<NSNumber *> *)colorsRGBA preferMulticolor:(NSNumber *)preferMulticolor error:(FlutterError *_Nullable *_Nonnull)error {
    if (@available(iOS 13, *)) { 
        // iOS adds ~15% padding to the outside of the image so we scale down to match the requested
        // size.
        double pointSize = [size doubleValue] * 0.85;

        // Up to 3 rgb values for primary, seconday and tertiary colors.
        // see
        // https://developer.apple.com/documentation/uikit/uiimagesymbolconfiguration/3810054-configurationwithpalettecolors

        NSMutableArray *colorArray = [[NSMutableArray alloc] init];

        for (int i = 0; i < [colorsRGBA count]; i += 4) {
            UIColor *primaryColor = [UIColor colorWithRed:[colorsRGBA[i] doubleValue]
                                                    green:[colorsRGBA[i + 1] doubleValue]
                                                    blue:[colorsRGBA[i + 2] doubleValue]
                                                    alpha:[colorsRGBA[i + 3] doubleValue]];
            [colorArray addObject:primaryColor];
        }

        UIImageSymbolWeight uiWeight = [ self weightFromFLTFontWeight: weight ];

        UIImageSymbolConfiguration *pointSizeConfig =
            [UIImageSymbolConfiguration configurationWithPointSize:pointSize
                                                            weight:uiWeight
                                                            scale:UIImageSymbolScaleDefault];

        UIImage *finalImage;

        if (@available(iOS 15, *)) {
            UIImageSymbolConfiguration *colors =
                [preferMulticolor boolValue]
                    ? [UIImageSymbolConfiguration configurationPreferringMulticolor]
                    : [UIImageSymbolConfiguration configurationWithPaletteColors:colorArray];

            UIImageSymbolConfiguration *final =
                [pointSizeConfig configurationByApplyingConfiguration:colors];
            finalImage = [UIImage systemImageNamed:name withConfiguration:final];
        } else {
            UIImage *image = [UIImage systemImageNamed:name withConfiguration:pointSizeConfig];
            finalImage = [image
                imageWithTintColor:colorArray.count > 0 ? colorArray[0] : [UIColor blackColor]];
        }

        NSData *data = UIImagePNGRepresentation(finalImage);
        return [ FLTPlatformImage makeWithScale:@(finalImage.scale) bytes:data ];
    }
    return nil;
}

- (nullable FLTPlatformImage *)getPlatformImageName:(NSString *)name error:(FlutterError *_Nullable *_Nonnull)error {
    UIImage *image = [UIImage imageNamed:name];
    NSData *data = UIImagePNGRepresentation(image);

    return [ FLTPlatformImage makeWithScale:@(image.scale) bytes:data ];
}

- (nullable NSString *)resolveURLName:(NSString *)name extension:(nullable NSString *)extension error:(FlutterError *_Nullable *_Nonnull)error {
      NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:extension];
      return url.absoluteString;
}


- (UIImageSymbolWeight) weightFromFLTFontWeight:(FLTFontWeight) flutterFontWeight API_AVAILABLE(ios(13)) {
    switch (flutterFontWeight) {
        case FLTFontWeightUltraLight: return UIImageSymbolWeightUltraLight;
        case FLTFontWeightThin: return UIImageSymbolWeightThin;
        case FLTFontWeightLight: return UIImageSymbolWeightLight;
        case FLTFontWeightRegular: return UIImageSymbolWeightRegular;
        case FLTFontWeightMedium: return UIImageSymbolWeightMedium;
        case FLTFontWeightSemibold: return UIImageSymbolWeightSemibold;
        case FLTFontWeightBold: return UIImageSymbolWeightBold;
        case FLTFontWeightHeavy: return UIImageSymbolWeightHeavy;
        case FLTFontWeightBlack: return UIImageSymbolWeightBlack;
    }
}

@end
