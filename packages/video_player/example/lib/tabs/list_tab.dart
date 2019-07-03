import 'package:flutter/material.dart';
import '../player.dart';
import '../video_provider.dart';

class ListTab extends StatelessWidget {
  const ListTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    VideoControllerProvider.of(context)..setLooping(true);

    return ListView(
      children: <Widget>[
        _buildCard("Item a"),
        _buildCard("Item b"),
        _buildCard("Item c"),
        _buildCard("Item d"),
        _buildCard("Item e"),
        _buildCard("Item f"),
        _buildCard("Item g"),
        Card(
          child: Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  const ListTile(
                    leading: Icon(Icons.cake),
                    title: Text("Video video"),
                  ),
                  Stack(
                    alignment: FractionalOffset.bottomRight +
                        const FractionalOffset(-0.1, -0.1),
                    children: <Widget>[
                      const Player(),
                      Image.asset('assets/flutter-mark-square-64.png'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildCard("Item h"),
        _buildCard("Item i"),
        _buildCard("Item j"),
        _buildCard("Item k"),
        _buildCard("Item l"),
      ],
    );
  }

  /// A filler card to show the video in a list of scrolling contents.
  Widget _buildCard(String title) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.airline_seat_flat_angled),
            title: Text(title),
          ),
          ButtonTheme.bar(
            child: ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: const Text('BUY TICKETS'),
                  onPressed: () {
                    /* ... */
                  },
                ),
                FlatButton(
                  child: const Text('SELL TICKETS'),
                  onPressed: () {
                    /* ... */
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
