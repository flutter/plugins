# IOS Platform Images

A Flutter plugin to share images between Flutter and iOS.

This allows Flutter to load images from Images.xcassets and iOS code to load
Flutter images.

When loading images from Image.xcassets the device specific variant is chosen
([iOS documentation](https://developer.apple.com/design/human-interface-guidelines/ios/icons-and-images/image-size-and-resolution/)).

|             | iOS  |
|-------------|------|
| **Support** | 9.0+ |

## Usage

### iOS->Flutter Example

``` dart
// Import package
import 'package:ios_platform_images/ios_platform_images.dart';

Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Image(image: IosPlatformImages.load("flutter")),
      ),
      //..
    ),
  );
}
```

`IosPlatformImages.load` functions like [[UIImage imageNamed:]](https://developer.apple.com/documentation/uikit/uiimage/1624146-imagenamed).

### Flutter->iOS Example

```objc
#import <ios_platform_images/UIImage+ios_platform_images.h>

static UIImageView* MakeImage() {
  UIImage* image = [UIImage flutterImageWithName:@"assets/foo.png"];
  return [[UIImageView alloc] initWithImage:image];
}
```
