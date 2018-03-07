## Guide to understanding the Flutter Camera plugin for Developers

The camera app aims to be a stable plugin for flutter projects.
The code currently is enabling video capture on both platforms iOS and Android.


This guide is in 3 parts:

* Example App
* Plugin  
* Native Code


### Example App

A demo app to showcase the plugin with all its features located in `example/lib/main.dart`

#### Features

* ResolutionPreset: capture quality of the preview (low medium high) (not available in UI)
* CameraLensDirection: choose from a list of available cameras ( front back external )
* capture: save a JPEG image from the chosen camera view with the max available
  pixel for that camera
* videostart: Start video capture from the chosen camera view with the chosen `ResolutionPreset`
* videostop: Stop the video capture and output the file path of the saved video


### Plugin

The plugin essentially has one file in the `lib/camera.dart` which which provides
all the _features_


#### Channels

There are two channels communicating with the native code,

* MethodChannel: Transfer of state information, data strings, controls, triggers, calls etc..
* EventChannel: Transfer of image data stream, tagged with `textureId`

#### Method Calls

* `init` : initialise the respective native cams and reset set them to their original states
* `list` : list all available cams
* `create` : create a camera object with the selected camera and resolution preset
          also start a stream with the event channel with `textureId`. starts the
          image data stream display too
* `start` : Start the image data stream display in the UI
* `stop` :  Stops the image data stream display in the UI
* `capture` : Capture the JPEG image by sending the image path to be saved
* `videostart` : Trigger start of the video Recorder variable to capture
              video to a file ( requires work)
* `videostop` : Stop the camera from recording, send the file path of the saved file
              back and dispose the camera ( requires work)
* `dispose` : Dispose and reset the camera that was initialised



## Native Code

### iOS

Links to refer

* https://developer.apple.com/library/content/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/04_MediaCapture.html
* https://www.objc.io/issues/23-video/capturing-video/
* https://stackoverflow.com/questions/3968879/simultaneous-avcapturevideodataoutput-and-avcapturemoviefileoutput



### Android

Links to refer

* https://developer.android.com/reference/android/hardware/camera2/package-summary.html
* https://developer.android.com/reference/android/media/MediaRecorder.html
* https://github.com/googlesamples/android-Camera2Video/blob/master/Application/src/main/java/com/example/android/camera2video/Camera2VideoFragment.java






```


```
