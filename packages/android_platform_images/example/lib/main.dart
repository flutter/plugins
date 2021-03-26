import 'package:android_platform_images/android_platform_images.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(MyApp());
}

///
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: CustomScrollView(
            slivers: <Widget>[
              // test custom alias
              SliverGrid.count(
                crossAxisCount: 2,
                children: const <Widget>[
                  Image(image: AndroidPlatformImage('launch_icon')),
                  Image(image: AndroidPlatformImage('max_1_alias')),
                ],
              ),

              // test find bit drawable res
              SliverGrid.count(
                crossAxisCount: 3,
                children: <Widget>[
                  ...List<Widget>.generate(3, (int index) => Image(image: AndroidPlatformImage('max_${index+1}'),)),
                ],
              ),

              // test assets
              SliverGrid.count(
                crossAxisCount: 3,
                children: <Widget>[
                  ...List<Widget>.generate(3, (int index) => Image(image: AndroidPlatformImage('max_${index+1}', quality: 40),)),
                ],
              ),

              // test find small drawable res
              SliverGrid.count(
                crossAxisCount: 3,
                children: <Widget>[
                  ...List<Widget>.generate(9, (int index) => Image(image: AndroidPlatformImage('min_${index+1}'),)),
                ],
              ),
            ],
          )
      ),
    );
  }
}
