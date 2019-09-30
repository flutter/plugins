import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: FlatButton(
        child: const Text('push'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<VideoCrashPlayerPage>(
                builder: (BuildContext context) => VideoCrashPlayerPage()),
          );
        },
      ),
    ));
  }
}

class VideoCrashPlayerPage extends StatefulWidget {
  @override
  _VideoCrashPlayerPageState createState() => _VideoCrashPlayerPageState();
}

class _VideoCrashPlayerPageState extends State<VideoCrashPlayerPage> {
  VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();

    _videoPlayerController =
        VideoPlayerController.asset("assets/Butterfly-209.mp4");
    _videoPlayerController.addListener(() {
      if (!_videoPlayerController.value.isPlaying) {
        Navigator.pop(context);
      }
    });
    _videoPlayerController.play();
    _videoPlayerController.initialize();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        elevation: 0,
        child: Column(
          children: <Widget>[
            Expanded(
                child: FittedBox(
              fit: BoxFit.cover,
              child: Container(
                  width: 818.0,
                  height: 864.0,
                  child: VideoPlayer(_videoPlayerController)),
            ))
          ],
        ));
  }
}

void main() {
  runApp(
    MaterialApp(
      home: MainPage(),
    ),
  );
}
