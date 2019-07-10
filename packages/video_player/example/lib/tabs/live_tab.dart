import 'package:flutter/material.dart';
import '../player.dart';
import '../player_values.dart';

class LiveTab extends StatelessWidget {
  const LiveTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: const <Widget>[
          Text('HLS Live stream'),
          SizedBox(height: 20.0),
          Player(isLive: true),
          SizedBox(height: 20.0),
          PlayerValues(),
        ],
      ),
    );
  }
}
