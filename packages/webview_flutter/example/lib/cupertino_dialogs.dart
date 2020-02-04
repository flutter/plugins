import 'package:flutter/cupertino.dart';

/// An example for cupertino style alert dialog.
class MyCupertinoAlertDialog extends StatelessWidget {
  /// Dialog message.
  final String message;

  /// Constructs an instance with a message.
  MyCupertinoAlertDialog({this.message = ''});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content: Text(message),
      actions: <Widget>[
        CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ],
    );
  }
}

/// An example for cupertino style confirm dialog.
class CupertinoConfirmDialog extends StatelessWidget {
  /// Dialog message.
  final String message;

  /// Constructs an instance with a message.
  CupertinoConfirmDialog({this.message = ''});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content: Text(message),
      actions: <Widget>[
        CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false);
            }),
        CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(true);
            }),
      ],
    );
  }
}

/// An example for cupertino style prompt dialog.
class CupertinoPromptDialog extends StatefulWidget {
  /// Dialog message.
  final String message;
  /// Dialog default text.
  final String defaultText;

  /// Constructs an instance with a message and default text.
  CupertinoPromptDialog({Key key, this.message, this.defaultText}) : super(key: key);

  @override
  _PromptDialogState createState() => _PromptDialogState();
}

class _PromptDialogState extends State<CupertinoPromptDialog> {
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
    return CupertinoAlertDialog(
      content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(widget.message),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: CupertinoTextField(
                controller: _controller,
                cursorColor: CupertinoColors.inactiveGray,
                style: const TextStyle(
                  fontSize: 16,
                ),
                maxLines: 1,
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(
                    width: 1.2,
                    color: CupertinoColors.inactiveGray,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            )
          ]),
      actions: <Widget>[
        CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop('');
            }),
        CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(_controller.text);
            }),
      ],
    );
  }
}
