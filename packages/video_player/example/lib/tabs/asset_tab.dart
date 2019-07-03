import 'package:flutter/material.dart';
import '../player.dart';
import '../player_values.dart';
import '../video_provider.dart';

class AssetTab extends StatelessWidget {
  const AssetTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    VideoControllerProvider.of(context)..setLooping(true);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: const <Widget>[
          Text('With assets mp4'),
          SizedBox(height: 20.0),
          Player(),
          SizedBox(height: 20.0),
          PlayerValues(),
        ],
      ),
    );
  }
}
