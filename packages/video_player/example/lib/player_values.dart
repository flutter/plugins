import 'package:flutter/material.dart';
import './video_provider.dart';

class PlayerValues extends StatefulWidget {
  const PlayerValues({Key key});

  @override
  _PlayerValuesState createState() => _PlayerValuesState();
}

class _PlayerValuesState extends State<PlayerValues> {
  VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoControllerProvider.of(context);
    controller.addListener(_listener);
  }

  @override
  void dispose() {
    controller.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerValue v = controller.value;

    if (!v.initialized) {
      return const SizedBox();
    }

    if (v.errorDescription != null) {
      return Text(v.errorDescription, style: TextStyle(color: Colors.red));
    }

    final List<Widget> children = <Widget>[
      _row('Status:', Icon(v.isPlaying ? Icons.play_arrow : Icons.pause)),
      _row('Size: ', Text('${v.size.width} x ${v.size.height}')),
      _row('Volume: ', Text(v.volume.toString())),
      _row('Looping? ', Text(v.isLooping.toString())),
      _row('Buffering? ', Text(v.isBuffering.toString())),
      _row('Position: ', Text(v.position.toString())),
      _row('Duration: ', Text(v.duration.toString())),
    ];

    if (v.buffered.isEmpty) {
      children.add(_row('Buffered: ', const Text('[]')));
    } else {
      children.add(_row('Buffered: ',
          Text('[${v.buffered.last.start}, ${v.buffered.last.end}]')));
    }

    return Column(children: children);
  }

  Widget _row(String title, Widget child) {
    return Row(
      children: <Widget>[
        Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        child,
      ],
    );
  }
}
