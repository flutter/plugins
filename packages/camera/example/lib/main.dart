import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraStartStop extends StatefulWidget {
  final CameraController controller;

  CameraStartStop(this.controller);

  @override
  State createState() {
    return new _CameraStartStopState();
  }
}

class _CameraStartStopState extends State<CameraStartStop> {
  bool isPlaying = true;
  VoidCallback listener;

  _CameraStartStopState() {
    listener = () {
      if (!mounted) return;
      setState(() {});
    };
  }

  CameraController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void didUpdateWidget(CameraStartStop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      controller.addListener(listener);
    }
  }

  @override
  void dispose() {
    controller.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      child: new CameraPreview(controller),
      onTap: () {
        if (controller.value.isPlaying) {
          controller.stop();
        } else {
          controller.start();
        }
      },
    );
  }
}

class CameraExampleHome extends StatefulWidget {
  @override
  CameraExampleHomeState createState() {
    return new CameraExampleHomeState();
  }
}

class CameraExampleHomeState extends State<CameraExampleHome> {
  bool opening = false;
  CameraController controller;
  List<CameraConfiguration> cameras;
  String filename;
  int pictureCount = 0;

  @override
  void initState() {
    super.initState();
    availableCameras().then((List<CameraConfiguration> cameras) {
      setState(() {
        this.cameras = cameras;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> cameraList = <Widget>[];
    if (cameras == null) {
      cameraList.add(new Text("No cameras yet"));
    } else {
      for (CameraConfiguration cameraConfiguration in cameras) {
        cameraList.add(new RaisedButton(
            onPressed: () async {
                CameraController tempController = controller;
                controller = null;
                await tempController?.dispose();
                setState(() {
                controller = new CameraController(cameraConfiguration);
                controller.start();
                controller.initialize();
              });
            },
            child: new Text(
                '${cameraConfiguration.lensDirection}')));
      }
    }
    List<Widget> rowChildren = <Widget>[new Column(children: cameraList)];
    if (filename != null) {
      rowChildren.add(new SizedBox(
        child: new Image.file(new File(filename)),
        width: 64.0,
        height: 64.0,
      ));
    }

    List<Widget> columnChildren = <Widget>[];
    columnChildren.add(new Row(children: rowChildren));
    if (controller == null) {
      columnChildren.add(new Text("Tap a camera"));
    } else {
      columnChildren.add(
        new Expanded(
          child: new Center(
            child: new AspectRatio(
              aspectRatio: controller.configuration.previewSize.height /
                  controller.configuration.previewSize.width,
              child: new CameraStartStop(controller),
            ),
          ),
        ),
      );
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Camera example"),
      ),
      body: new Column(children: columnChildren),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          if (controller.value.isPlaying) {
            controller.capture("picture${pictureCount++}").then(
              (String filename) {
                setState(
                  () {
                    this.filename = filename;
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

void main() {
  runApp(
    new MaterialApp(
      home: new CameraExampleHome(),
    ),
  );
}
