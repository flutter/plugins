import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

//import 'video.dart';


class CameraExampleHome extends StatefulWidget {
  @override
  _CameraExampleHomeState createState() {
    return new _CameraExampleHomeState();
  }
}

// function to select a suitable icon depending on the lens selected
IconData cameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw new ArgumentError('Unknown lens direction');
}

class _CameraExampleHomeState extends State<CameraExampleHome> {

  bool opening = false;

  //initiate the controller to be used
  CameraController controller;

  //test second controller to save currently used controller
  CameraController currentcontroller;

  // image and video file that is saved
  String imagePath;
  String videofile;

  // recording bool for UI triggers
  bool recording = false;

  // to enable different filenames
  int pictureCount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    // List Widget to build the UI controls of the camera
    final List<Widget> controlsChildren = <Widget>[];

    // For UI to add the the available camers selector
    final List<Widget> cameraList = <Widget>[];

    if (cameras.isEmpty) {
      cameraList.add(const Text('No cameras found'));
    } else {
      // Adding cams to the widget
      for (CameraDescription cameraDescription in cameras) {
        cameraList.add(
          new SizedBox(
            width: 90.0,
            child: new RadioListTile<CameraDescription>(
              title: new Icon(cameraLensIcon(cameraDescription.lensDirection)),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged: (CameraDescription newValue) async {
                final CameraController tempController = controller;
                controller = null;
                await tempController?.dispose();
                controller =
                    new CameraController(newValue, ResolutionPreset.high);
                currentcontroller = new CameraController(newValue, ResolutionPreset.high);
                await controller.initialize();
                setState(() {});
              },
            ),
          ),
        );
      }
    }

    // adding the cameras to the main controls widget
    controlsChildren.add(new Row(children: cameraList));

    // adding the play/pause button && thumb of image capture to the controls widget
    if (controller != null) {
      controlsChildren.add(playPauseButton());
    }
    if (imagePath != null) {
      controlsChildren.add(imageWidget());
    }

    // initialize the preview window
    final List<Widget> previewChildren = <Widget>[];

    //depending on controller state display a message or the camera preview
    if (controller == null || !controller.value.initialized) {
      previewChildren.add(new Text('Tap a camera',
      style: new TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),));
    } else if (controller.value.hasError) {
      previewChildren.add(
        new Text('Camera error ${controller.value.errorDescription}'),
      );
    } else {
      previewChildren.add(
        new Container(
        // handle the preview depending on the aspect ratio of the camera view
        // This may need work to display correctly
        child: new AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: new CameraPreview(controller),
              ),
              height: (MediaQuery.of(context).size.height - 230.0),
              color: Colors.black,
            ),



      );
    }

    // the main scaffoling of the app
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Camera example'),
      ),
      body: new Column(
        children: <Widget>[
          new Container(
           child: new Padding(
                padding: const EdgeInsets.all(1.0),
                child: new Center(
                child: new Column(

                  mainAxisAlignment: MainAxisAlignment.center ,

                  // add the preview to the app
                  children: previewChildren
                ),
              ),
            ),
            // size of the container as wide  as the device screen
          width: MediaQuery.of(context).size.width ,
          decoration: new BoxDecoration(
          color: Colors.black,
          border: new Border.all(
              color: Colors.redAccent,
              width: controller != null && controller.value.isStarted && recording ? 3.0 : 0.0,
            ),
          ),

        ),


          new Padding(
            padding: const EdgeInsets.all(5.0),
            child: new Row(
            mainAxisAlignment: MainAxisAlignment.start ,

            // add the controls to the app
            children: controlsChildren

          ),
        ),

        // Add the message to the user depending on the camera controller state.
        vidMsg(),


        ]
        ),

        // Bottom bar with the capture controls image and video
        bottomNavigationBar: (controller == null)
            ? null
            : new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
              mainAxisSize: MainAxisSize.max ,
          children: <Widget>[
              new IconButton(
              icon: new Icon( Icons.camera_alt ),
              color: Colors.blue,
              onPressed: controller.value.isStarted ? capture : null,
            ),
              new IconButton(
              icon: new Icon( Icons.videocam ),
              color: Colors.blue ,
              onPressed: controller.value.isStarted && !recording ? videoStart : null, //videoStart //
            ),
              new IconButton(
              icon: new Icon( Icons.stop ) ,
              color: Colors.red ,
              onPressed: controller.value.isStarted && recording ? videoStop : null, //videoStop //

            ),

          ]),

    );
  }


// start video capture *need improvement*
  void videoStart() {

    videostart();

      setState(
        () {
          if (!controller.value.videoOn) {
            recording = true;
          }
        },
      );
  }

  // stop video capture *need improvement*

  void videoStop() {

     videostop();

      setState(
        () {
           if (controller.value.videoOn) {
            recording = false;
          }
        },
      );
  }

// widget to display the thumb of the captured image in the UI
  Widget imageWidget() {
    return new Expanded(
      child: new Align(
        alignment: Alignment.centerRight,
        child: new SizedBox(
          child: new Image.file(new File(imagePath)),
          width: 64.0,
          height: 64.0,
        ),
      ),
    );
  }

// display message depending on camera app state
  Widget vidMsg() {
    if (videofile == null && controller == null){
      return const Padding(
        padding: const EdgeInsets.all(1.0),
        child:
        const Text( 'Choose a camera'),
      );
    }
    else if (videofile != null && controller == null){
      return new Padding(
        padding: const EdgeInsets.all(1.0),
        child:
        new Text( 'Saved: $videofile ')
      );
    }
    else if (videofile == null && controller != null){
      return const Padding(
        padding: const EdgeInsets.all(1.0),
        child:
        const Text( 'Take a video / photo '),
      );
    }
    else {
      return const Padding(
        padding: const EdgeInsets.all(1.0),
        child:
        const Text( 'Take a video / photo'),
      );

    }

  }

  // UI for pause/play button
  Widget playPauseButton() {
    return new FlatButton(
      onPressed: () {
        setState(
          () {
            if (controller.value.isStarted) {
              controller.stop();
            } else {
              controller.start();
            }
          },
        );
      },
      child:
          new Icon(controller.value.isStarted ? Icons.pause : Icons.play_arrow),
    );
  }

// actual videostart
  Future<Null> videostart() async {
    if (controller.value.isStarted) {

// at the moment this section of filename is dummy and not used in the final output
     final Directory tempDir = await getTemporaryDirectory();
     if (!mounted) {
       return;
     }
     final String tempPath = tempDir.path;
     final String path = '$tempPath/movie${pictureCount++}.mp4';

     // call the controller to start capture
      await controller.videostart(path);


    }
  }


// after the videostop is called reset the camera to the initial state
// This is similar to the code when the camera is switched from front / back /
// external. This section of code needs work
  Future<Null> restartcam() async {
   final CameraController tempController2 = controller;
   controller = null;
   await tempController2?.dispose();
   controller = currentcontroller ;
   await controller.initialize();
   //setState(() {});
 }


// videostop call to the camera controller
// this code may need work
  Future<Null> videostop() async {
    if (controller.value.isStarted) {

     final String vfile =  await controller.videostop();

      setState(() {
        videofile = vfile;
      });
      await restartcam();

    }
  }

// capture call to save a JPEG image
  Future<Null> capture() async {
    if (controller.value.isStarted) {
      final Directory tempDir = await getTemporaryDirectory();
      if (!mounted) {
        return;
      }
      final String tempPath = tempDir.path;
      final String path = '$tempPath/picture${pictureCount++}.jpg';
      await controller.capture(path);
      if (!mounted) {
        return;
      }
      setState(
        () {
          imagePath = path;
        },
      );
    }
  }
}

class CameraApp extends StatelessWidget {

@override
Widget build(BuildContext context){
  return new MaterialApp(
    home: new CameraExampleHome(),
    // routes: <String, WidgetBuilder> {
    //     //"/Video": (BuildContext context) => new CameraExampleVideo(),
    //
    //   }
  );

}

}

// initialze a list of cameras
List<CameraDescription> cameras;

Future<Null> main() async {

  //save the available cameras in this variable first before initializing the app
  cameras = await availableCameras();
  runApp( new CameraApp());
}
