# IOS Platform Images

A Flutter plugin to share images between Flutter and iOS.

This allows Flutter to load images from Images.xcassets and iOS code to load
Flutter images.

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

### Flutter->iOS Example

```objc
#import <ios_platform_images/UIImage+ios_platform_images.h>

static UIImageView* MakeImage() {
  UIImage* image = [UIImage flutterImageWithName:@"assets/foo.png"];
  return [[UIImageView alloc] initWithImage:image];
}
```
