import 'package:flutter/material.dart';

/// An example for material style alert dialog.
class MyAlertDialog extends StatelessWidget {
  /// dialog message
  final String message;

  /// Constructs an instance with a message.
  MyAlertDialog({this.message = ''});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(message),
      actions: <Widget>[
        FlatButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ],
    );
  }
}

/// An example for material style confirm dialog.
class ConfirmDialog extends StatelessWidget {
  /// dialog message
  final String message;

  /// Constructs an instance with a message.
  ConfirmDialog({this.message = ''});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(message),
      actions: <Widget>[
        FlatButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false);
            }),
        FlatButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(true);
            }),
      ],
    );
  }
}

/// An example for material style prompt dialog.
class PromptDialog extends StatefulWidget {
  /// dialog message
  final String message;
  /// dialog default text
  final String defaultText;

  /// Constructs an instance with a message and default text.
  PromptDialog({Key key, this.message, this.defaultText = ''})
      : super(key: key);

  @override
  _PromptDialogState createState() => _PromptDialogState();
}

class _PromptDialogState extends State<PromptDialog> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.text = widget.defaultText;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(widget.message),
            TextField(controller: _controller),
          ]),
      actions: <Widget>[
        FlatButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop('');
            }),
        FlatButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(_controller.text);
            }),
      ],
    );
  }
}
