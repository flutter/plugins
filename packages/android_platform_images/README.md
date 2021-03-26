# android_platform_images

A Flutter plugin to get images from Android Platform.

This allows Flutter to load images from drawable & mipmap & assets.

## usage

```
// Import package
Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Image(image: AndroidPlatformImage('flutter')),
      ),
      //..
    ),
  );
}
```


